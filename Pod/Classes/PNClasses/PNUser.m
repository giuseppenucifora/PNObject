//
//  PNUser.m
//  Pods
//
//  Created by Giuseppe Nucifora on 15/01/16.
//
//

#import "PNUser.h"
#import "NSString+Helper.h"
#import "PNObjectConstants.h"
#import "PNObject+Protected.h"
#import "PNObject+PNObjectConnection.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "PNObjcPassword.h"


@interface PNUser() <PNObjectSubclassing>

@property (nonatomic) BOOL authenticated;

@end

@implementation PNUser

@synthesize password = _password;

static id USER = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (instancetype) currentUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;

        USER = [[super allocWithZone:NULL] initForCurrentUser];
    });

    return USER;
}

+ (instancetype)resetUser {
    [USER autoRemoveLocally];
    USER = nil;
    return [self currentUser];
}

#pragma mark - Life Cycle

- (instancetype)copy
{
    return [[PNUser alloc] init];
}

- (instancetype)mutableCopy
{
    return [[PNUser alloc] init];
}

- (instancetype) initForCurrentUser
{
    if(USER){
        return USER;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }

    NSDictionary *savedUser = [[PNObjectModel sharedInstance] fetchObjectsWithClass:[self class]];

    if (savedUser) {
        Class objectClass = NSClassFromString([[self class] PNObjClassName]);

        USER = [[objectClass alloc] initWithLocalJSON:savedUser];
    }

    if (USER) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self autoLogin];
        });
    }

    return USER;
}

- (void) setEmail:(NSString *)email {
    if ([email isValidEmail]) {
        _email = email;
    }
    else {
        NSLogDebug(@"insertedEmail is not valid.");
    }
}

- (void)logout {
    [self autoRemoveLocally];
    [self resetObject];
}

- (BOOL) hasValidEmailAndPasswordData {
    if(self.email && [self.email isValidEmail] && self.password && [self.password isValid]){
        return YES;
    }

    return NO;
}

+ (BOOL) isValidPassword:(NSString* _Nonnull) password {
    return [PNObjcPassword validateMinimumRequirenment:password];
}

- (void) autoLogin {
    [self autoLoginWithBlockSuccess:nil failure:nil];
}

- (void) autoLoginWithBlockSuccess:(nullable void (^)(BOOL loginSuccess))success
                           failure:(nullable void (^)(NSError * _Nonnull error))failure {
    [[PNObjectConfig sharedInstance] refreshTokenForUserWithBlockSuccess:^(BOOL refreshSuccess) {
        if (success) {
            success(refreshSuccess);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void) reloadFormServer {
    ///api/v1/user/profile

    [self autoLoginWithBlockSuccess:^(BOOL loginSuccess) {
        [[self class] GETWithEndpointAction:@"user/profile"
                                   progress:nil
                                    success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {

                                        NSLogDebug(@"%@",[responseObject objectForKey:@"user"]);

                                        [self populateObjectFromJSON:[responseObject objectForKey:@"user"]];
                                        [self saveLocally];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationUserReloadFromServerSuccess object:nil];

                                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                        NSLogDebug(@"%@",error);
                                    }];
    } failure:^(NSError * _Nonnull error) {
        NSLogDebug(@"error : %@",error);
    }];
}

- (void) registerWithBlockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                          failure:(nullable void (^)(NSError * _Nonnull error))failure {

    [[self class] POSTWithEndpointAction:@"registration/register" parameters:[self JSONFormObject]
                                progress:nil
                                 success:^(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject) {
                                     NSLog(@"response %@",responseObject);
                                     if(success){
                                         success(self);
                                         [self saveLocally];
                                     }
                                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                     NSLogDebug(@"error : %ld",[error code]);
                                     if (failure) {
                                         failure(error);
                                     }
                                 }];
}


- (void) socialLoginWithBlockSuccessFromViewController:(UIViewController* _Nonnull) viewController
                                          blockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                                               failure:(nullable void (^)(NSError * _Nonnull error))failure {
    if ([FBSDKAccessToken currentAccessToken]) {
        //FBSDKProfile *user = [FBSDKProfile currentProfile];

        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name, last_name, link, birthday, email, gender"}];

        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            NSLogDebug(@"%@",result);
            NSLogDebug(@"%@",error);

            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            else {
                [self setFacebookAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
                [self setFirstName:[result objectForKey:@"first_name"]];
                [self setLastName:[result objectForKey:@"last_name"]];
                [self setEmail:[result objectForKey:@"email"]];
                [self setFacebookId:[result objectForKey:@"id"]];

                NSString *gender = [[result objectForKey:@"gender"] isEqualToString:@"male"] ? @"M" : @"F";

                [self setSex:gender];

                NSArray *birthArray = [[result objectForKey:@"birthday" ] componentsSeparatedByString: @"/"];

                //NSMutableString *birthString = [NSMutableString stringWithString:[[[[[birthArray objectAtIndex:1] stringByAppendingString:@"/"] stringByAppendingString:[birthArray objectAtIndex:0]] stringByAppendingString:@"/"] stringByAppendingString:[birthArray objectAtIndex:2]]];

            }

            /*[UserDataManager setParameter:DEF_PROFILE_FIRSTNAME withValue:user.firstName];
             [UserDataManager setParameter:DEF_PROFILE_LASTNAME withValue:user.lastName];

             NSArray *birthArray = [[result objectForKey:@"birthday" ] componentsSeparatedByString: @"/"];

             NSMutableString *birthString = [NSMutableString stringWithString:[[[[[birthArray objectAtIndex:1] stringByAppendingString:@"/"] stringByAppendingString:[birthArray objectAtIndex:0]] stringByAppendingString:@"/"] stringByAppendingString:[birthArray objectAtIndex:2]]];

             NSString *gender = [[result objectForKey:@"gender"] isEqualToString:@"male"] ? @"M" : @"F";

             [UserDataManager setParameter:DEF_PROFILE_BIRTH withValue:birthString];
             [UserDataManager setParameter:DEF_PROFILE_GENDER withValue:gender];

             [UserDataManager setParameter:DEF_PROFILE_EMAIL withValue:[result objectForKey:@"email"]];
             [UserDataManager setParameter:DEF_PROFILE_AVATAR withValue:[NSNumber numberWithInt:1]];
             [UserDataManager setParameter:DEF_PROFILE_FB_ID withValue:[result objectForKey:@"id"]];*/


            //[self setFacebookId:[user userID]];
        }];


    }
    else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions: @[@"public_profile",@"email"] fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                NSLog(@"Process error");
            } else if (result.isCancelled) {
                NSLog(@"Cancelled");
            } else {
                NSLog(@"Logged in");


            }
        }];
    }
}

- (void) socialLoginWithBlockSuccess:(void (^)(PNUser * _Nullable))success
                             failure:(void (^)(NSError * _Nonnull))failure {


    /*[self POSTWithEndpointAction:@"registration/register" progress:nil success:^(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject) {
     NSLog(@"response %@",responseObject);
     if(success){
     success(self);
     [self saveLocally];
     }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     NSLogDebug(@"error : %ld",[error code]);
     if (failure) {
     failure(error);
     }
     }];*/
}

+ (void) loginCurrentUserWithEmail:(NSString * _Nonnull) email
                          password:(NSString * _Nonnull) password
                  withBlockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                           failure:(nullable void (^)(NSError * _Nonnull error))failure {

    [[PNObjectConfig sharedInstance] refreshTokenForUserWithEmail:email password:password withBlockSuccess:^(BOOL refreshSuccess) {
        if (refreshSuccess) {


            PNUser *user = [[self class] new];

            PNObjcPassword *objectPassword = [PNObjcPassword new];
            [objectPassword setPassword:password];
            [objectPassword setConfirmPassword:password];

            [user setAuthenticated:YES];
            [user setEmail:email];
            [user setPassword:objectPassword];
            [user saveLocally];

            if (success) {
                success(user);
            }
        }
    } failure:failure];

}

+ (void) uploadAvatar:(UIImage * _Nonnull) avatar
             Progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
              Success:(nullable void (^)(NSDictionary * _Nullable responseObject))success
              failure:(nullable void (^)(NSError * _Nonnull error))failure {

    PNObjectFormData *formData = [PNObjectFormData formDataFromUIImage:avatar compression:1 name:@"file" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];

    [self POSTWithEndpointAction:@"user/avatar"
                        formData:@[formData]
                      parameters:nil
                        progress:uploadProgress
                         success:^(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject) {
                             if (success) {
                                 success(responseObject);
                             }
                             [[PNUser currentUser] setProfileImage:avatar];
                             [[PNUser currentUser] reloadFormServer];
                         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                             if (failure) {
                                 failure(error);
                             }
                         }];
}

- (BOOL) isAuthenticated {
    return self.authenticated;
}

- (UIImage* _Nonnull) userProfileImage {
    return [self userProfileImage:NO];
}


- (UIImage* _Nonnull) userProfileImage:(BOOL) forceReload {

    if (!_profileImage || forceReload) {

        if (_profileImageUrl) {

            NSError* error = nil;
            NSData* data = [NSData dataWithContentsOfURL:_profileImageUrl options:NSDataReadingUncached error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
                return [UIImage imageNamed:@"userProfileAvatar"];
            } else {
                NSLog(@"Data has loaded successfully.");
                return [UIImage imageWithData:data];
            }
        }
        else {
			return [UIImage imageNamed:@"userProfileAvatar"];
        }
    }
    else {
		return _profileImage;
    }
}

#pragma mark PNObjectSubclassing Protocol

+ (NSDictionary *)objcetMapping {

    NSDictionary *mapping = @{
                              @"userId":@"uuid",
                              @"firstName":@"firstName",
                              @"lastName":@"lastName",
                              @"profileImageUrl":@"profileImage",
                              @"sex":@"sex",
                              @"birthDate":@"birthYear",
                              @"phone":@"phone",
                              @"password":@{@"key":@"password",@"type":@"PNObjcPassword"},
                              @"hasAcceptedPrivacy":@"hasAcceptedPrivacy",
                              @"hasAcceptedNewsletter":@"hasAcceptedNewsletter",
                              @"hasVerifiedEmail":@"hasVerifiedEmail",
                              @"hasVerifiedPhone":@"hasVerifiedPhone",
                              @"emailVerifiedDate":@"emailVerifiedDate",
                              @"email":@"email",
                              @"username":@"username",
                              @"publicProfile":@"publicProfile",
                              @"loginCount":@"loginCount",
                              @"facebookId":@"facebookId",
                              @"facebookAccessToken":@"facebookAccessToken",
                              @"isFacebookUser":@"isFacebookUser",
                              @"registeredAt":@"registeredAt",
                              @"authenticated":@"authenticated"
                              };
    return mapping;
}

+ (NSString *)objectClassName {
    return  @"PNUser";
}

+ (NSString *) objectEndPoint {
    return @"User";
}

+ (BOOL) singleInstance {
    return YES;
}

#pragma mark -


@end
