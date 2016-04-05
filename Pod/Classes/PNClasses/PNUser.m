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

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
    [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationUserLogout object:nil];
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
    [self reloadFormServerWithBlockSuccess:nil failure:nil];
}

- (void) reloadFormServerWithBlockSuccess:(nullable void (^)(PNUser * _Nullable currentUser))success
                                  failure:(nullable void (^)(NSError * _Nonnull error))failure {
    [self autoLoginWithBlockSuccess:^(BOOL loginSuccess) {
        [[self class] GETWithEndpointAction:@"user/profile"
                                   progress:nil
                                    success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {

                                        NSLogDebug(@"%@",[responseObject objectForKey:@"user"]);

                                        [[[self class] currentUser] populateObjectFromJSON:[responseObject objectForKey:@"user"]];
                                        [[[self class] currentUser] saveLocally];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationUserReloadFromServerSuccess object:[[self class] currentUser]];
                                        
                                        if (success) {
                                            success([[self class] currentUser]);
                                        }
                                        

                                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                        NSLogDebug(@"%@",error);
                                        if (failure) {
                                            failure(error);
                                        }
                                    }];
    } failure:^(NSError * _Nonnull error) {
        NSLogDebug(@"error : %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void) registerWithBlockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                          failure:(nullable void (^)(NSError * _Nonnull error))failure {

    [[self class] POSTWithEndpointAction:@"registration/register" parameters:[self JSONFormObject]
                                progress:nil
                                 success:^(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject) {
                                     NSLog(@"response %@",responseObject);
                                     if(success){
                                         [[[self class] currentUser] saveLocally];
                                         success([[self class] currentUser]);
                                         
                                     }
                                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                     NSLogDebug(@"error : %ld",(long)[error code]);
                                     if (failure) {
                                         failure(error);
                                     }
                                 }];
}


+ (void) socialLoginFromViewController:(UIViewController* _Nullable) viewController
                          blockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                               failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    if (!viewController) {
        viewController = [PNObjectUtilities topViewController];
    }
    
    if ([FBSDKAccessToken currentAccessToken]) {
        //FBSDKProfile *user = [FBSDKProfile currentProfile];
        
        [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            else {
                
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
                        [[PNObjectConfig sharedInstance] refreshTokenForUserWithFacebookID:[result objectForKey:@"id"] facebookToken:[FBSDKAccessToken currentAccessToken].tokenString withBlockSuccess:^(BOOL refreshSuccess) {
                            
                            PNUser *user = [[self class] new];
                            
                            [user setFacebookId:[result objectForKey:@"id"]];
                            [user setAuthenticated:YES];
                            [user saveLocally];
                            [user reloadFormServer];
                            
                            USER = user;
                            
                            if (success) {
                                success(user);
                            }
                            
                        } failure:^(NSError * _Nonnull error) {
                            if (failure) {
                                failure(error);
                            }
                        }];
                    }
                }];
                
            }
        }];
    }
    else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions: @[@"public_profile",@"email",@"user_birthday"] fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                NSLog(@"Process error");
                if (failure) {
                    failure(error);
                }
            } else if (result.isCancelled) {
                NSLog(@"Cancelled");
                if (failure) {
                    NSError *error = [NSError errorWithDomain:NSLocalizedString(@"Request cancelled", @"") code:kHTTPStatusCodeMethodNotAllowed userInfo:nil];
                    failure(error);
                }
            } else {
                NSLog(@"Logged in");
                [self socialLoginFromViewController:viewController blockSuccess:success failure:failure];
            }
        }];
    }
}

;


+ (void) socialLoginWithBlockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                             failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    [self socialLoginFromViewController:nil blockSuccess:success failure:failure];
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
            [user reloadFormServer];
            
            USER = user;

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
                             [[self currentUser] setProfileImage:avatar];
                             [[self currentUser] reloadFormServer];
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
