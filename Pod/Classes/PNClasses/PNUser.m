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


@interface PNUser() <PNObjectSubclassing>

@end

@implementation PNUser

@synthesize password = _password;

static PNUser *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (instancetype) currentUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;

        SINGLETON = [[super allocWithZone:NULL] initForCurrentUser];
    });

    return SINGLETON;
}

+ (instancetype)resetUser {
    [SINGLETON autoRemoveLocally];
    SINGLETON = nil;
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
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }

    NSDictionary *savedUser = [[PNObjectModel sharedInstance] fetchObjectsWithClass:[self class]];

    if (savedUser) {
        SINGLETON = [super initWithJSON:savedUser];
    }
    else {
        SINGLETON = [super init];
    }

    if (SINGLETON) {
    }
    return SINGLETON;
}

- (void) setEmail:(NSString *)email {
    if ([email isValidEmail]) {
        _email = email;
    }
    else {
        NSLogDebug(@"insertedEmail is not valid.");
    }
}

- (void) setPassword:(NSString *)password {
    if ([self isValidPassword:password]) {
        _password = password;
    }
    else {
        NSLogDebug(@"Inserted Passord is not valid.Lenght must be >= %ld",(long)[[PNObjectConfig sharedInstance] minPasswordLenght]);
    }
}

- (void) setConfirmPassword:(NSString *)confirmPassword {
    if ([self isValidPassword:confirmPassword]) {
        if ([confirmPassword isEqualToString:_password]) {
            _confirmPassword = confirmPassword;
        }
        else {
            NSLogDebug(@"Inserted Passord is not same password.");
        }
    }
    else {
        NSLogDebug(@"Inserted Passord is not valid.Lenght must be >= %ld",(long)[[PNObjectConfig sharedInstance] minPasswordLenght]);
    }
}

- (BOOL) isValidPassword:(NSString* _Nonnull) password {
    if ([password length] >= [[PNObjectConfig sharedInstance] minPasswordLenght]) {
        return YES;
    }
    return NO;
}

+ (BOOL) isValidPassword:(NSString* _Nonnull) password {
    if ([password length] >= [[PNObjectConfig sharedInstance] minPasswordLenght]) {
        return YES;
    }
    return NO;
}

- (void)logout {
    [self autoRemoveLocally];
    [self resetObject];
}

- (BOOL) hasValidEmailAndPasswordData {
    if(self.email && [self.email isValidEmail] && self.password && [self isValidPassword:[self password]]){
        return YES;
    }

    return NO;
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
        [self GETWithEndpointAction:@"user/profile"
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {

                                NSLogDebug(@"%@",responseObject);
                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                NSLogDebug(@"%@",error);
                            }];
    } failure:^(NSError * _Nonnull error) {
        NSLogDebug(@"error : %@",error);
    }];
}

- (void) registerWithBlockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                          failure:(nullable void (^)(NSError * _Nonnull error))failure {

    [self POSTWithEndpointAction:@"registration/register" parameters:[self JSONFormObject]
                        progress:nil
                         success:^(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject) {
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

- (void) loginCurrentUserWithEmail:(NSString * _Nonnull) email
                          password:(NSString * _Nonnull) password
                  withBlockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                           failure:(nullable void (^)(NSError * _Nonnull error))failure {

    [[PNObjectConfig sharedInstance] refreshTokenForUserWithEmail:email password:password withBlockSuccess:^(BOOL refreshSuccess) {

        if (refreshSuccess) {
            if (success) {
                success([PNUser currentUser]);
            }
        }
    } failure:failure];

}

#pragma mark PNObjectSubclassing Protocol

+ (NSDictionary *)objcetMapping {

    NSDictionary *mapping = @{
                              @"userId":@"id",
                              @"userUUID":@"uuid",
                              @"firstName":@"firstName",
                              @"lastName":@"lastName",
                              @"profileImage":@"profileImage",
                              @"sex":@"sex",
                              @"birthDate":@"birthDate",
                              @"phone":@"phone",
                              @"password":@"plainPassword[first]",
                              @"confirmPassword":@"plainPassword[second]",
                              @"hasAcceptedPrivacy":@"hasAcceptedPrivacy",
                              @"hasAcceptedNewsletter":@"hasAcceptedNewsletter",
                              @"hasVerifiedEmail":@"hasVerifiedEmail",
                              @"emailVerifiedDate":@"emailVerifiedDate",
                              @"email":@"email",
                              @"username":@"username",
                              @"publicProfile":@"publicProfile",
                              @"loginCount":@"login_count",
                              @"facebookId":@"facebookId",
                              @"facebookAccessToken":@"facebookAccessToken",
                              @"isFacebookUser":@"isFacebookUser",
                              @"registeredAt":@"registeredAt",
                              };
    return mapping;
}

+ (NSString *)objectClassName {
    return  @"User";
}

+ (NSString *) objectEndPoint {
    return @"User";
}

+ (BOOL) singleInstance {
    return YES;
}

#pragma mark -


@end
