//
//  PNObjectConfig.h
//  Pods
//
//  Created by Giuseppe Nucifora on 08/01/16.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
//#import "HTTPStatusCodes"

#import "AFOAuth2Manager.h"
#import "AFHTTPRequestSerializer+OAuth2.h"
#import "AFOAuthCredential.h"

extern NSString* _Nonnull const PNObjectEncryptionKey;
extern NSString* _Nonnull const PNObjectEncryptionNonce;

extern NSString* _Nonnull const PNObjectServiceClientCredentialIdentifier;
extern NSString* _Nonnull const PNObjectServiceUserCredentialIdentifier;

#pragma mark LocalNotification Keys

extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenClientCredentialSuccess;
extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenClientCredentialFail;

extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenUserSuccess;
extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenUserFail;

extern NSString* _Nonnull const PNObjectLocalNotificationUserReloadFromServerSuccess;
extern NSString* _Nonnull const PNObjectLocalNotificationUserReloadFromServerFailure;

extern NSString* _Nonnull const PNObjectLocalNotificationUserWillLogout;
extern NSString* _Nonnull const PNObjectLocalNotificationUserEndLogout;

extern NSString* _Nonnull const PNObjectLocalNotificationPNInstallationUserNew;
extern NSString* _Nonnull const PNObjectLocalNotificationPNInstallationUserChange;
extern NSString* _Nonnull const PNObjectLocalNotificationPNInstallationUserDelete;

#pragma mark -

extern NSString* _Nonnull const BaseUrl;
extern NSString* _Nonnull const EndpointPath;

extern NSString* _Nonnull const EnvironmentProduction;
extern NSString* _Nonnull const EnvironmentStage;
extern NSString* _Nonnull const EnvironmentDevelopment;

extern NSString* _Nonnull const Client_ID;
extern NSString* _Nonnull const Client_Secret;

extern NSString* _Nonnull const Client_Credential_ID;
extern NSString* _Nonnull const Client_Credential_Secret;

extern NSString* _Nonnull const Client_Username;
extern NSString* _Nonnull const Client_Password;

typedef NS_ENUM(NSInteger, OAuthMode) {
    OAuthModeNo = 0,
    OAuthModeClientCredential,
    OAuthModePassword
};

@interface PNObjectConfig : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (instancetype _Nullable) sharedInstance;

/**
 *	Oauth is NO by default
 *
 *  @param endpointUrlsForEnvironments
 *  For example,
 *  @{   PNObjectConfigDevelopment : @"https://development.it/api/v1",
 *       PNObjectConfigEnvStage : @"https://stage.it/api/v1",
 *       PNObjectConfigEnvProduction : @"https://production.it/api/v1"
 *   }
 *
 *  @return singleton
 */
+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments andStoreClientIdentifier:(NSString* _Nonnull) identifier;

/**
 *  <#Description#>
 *
 *  @param endpointUrlsForEnvironments
 *  For example,
 *  @{   PNObjectConfigDevelopment : @"https://development.it/api/v1",
 *       PNObjectConfigEnvStage : @"https://stage.it/api/v1",
 *       PNObjectConfigEnvProduction : @"https://production.it/api/v1"
 *   }
 *  @param userSubClass                <#userSubClass description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments userSubclass:(Class _Nonnull) userSubClass andStoreClientIdentifier:(NSString* _Nonnull) identifier;

/**
 *  <#Description#>
 *
 *  @param environment <#env description#>
 */
- (void) setEnvironment:(NSString * _Nonnull) environment;


- (NSString * _Nonnull) getEnvironment;

/**
 *  <#Description#>
 *
 *  @param value <#value description#>
 *  @param key   <#key description#>
 */
- (void) setHTTPHeaderValue:(NSString * _Nonnull)value forKey:(NSString * _Nonnull) key;

/**
 *  <#Description#>
 *
 *  @param key   <#key description#>
 */
- (void) removeHTTPHeaderValueForKey:(NSString * _Nonnull) key;


/**
 *
 *
 *  @param clientID Client ID for selected environment
 *  @param clientSecret Client Secret for selected environment
 *  @param oAuthEndpointAction endpoint action. You can pass specia string "%@" to autoset EndpointPath to Oauth endpointPath
 *  @param oauthMode OauthMode
 *  @param environment environment
 *
 */
- (void) setClientID:(NSString * _Nonnull) clientID clientSecret:(NSString* _Nonnull) clientSecret oAuthEndpointAction:(NSString* _Nonnull) oAuthEndpointAction oauthMode:(OAuthMode) oauthMode refreshTokenEnabled:(BOOL) refreshTokenEnabled forEnv:(NSString * _Nonnull) environment;

- (void) setOauthUserName:(NSString * _Nonnull)oauthUserName oauthPassword:(NSString* _Nonnull) oauthPassword forEnv:(NSString * _Nonnull) environment;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSString * _Nonnull) baseUrl;

- (NSString * _Nonnull) endPointPath;

- (NSString * _Nonnull) endPointUrl;

/**
 *  <#Description#>
 *
 *  @param passLenght <#passLenght description#>
 */
- (void) setAcceptablePasswordLenght:(NSUInteger) passLenght;


/**
 *  This method refresh current token and automanage if token type is client credential or user token
 */
- (void) refreshToken;

/**
 *  This method refresh current token and automanage if token type is client credential or user token and returns block success and failure
 *
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
- (void) refreshTokenWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                              failure:(nullable void (^)(NSError * _Nonnull error))failure;

/**
 *  <#Description#>
 */
- (void) refreshTokenForClientCredential;

/**
 *  <#Description#>
 *
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
- (void) refreshTokenForClientCredentialWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                                 failure:(nullable void (^)(NSError * _Nonnull error))failure;

/**
 *  <#Description#>
 */
- (void) refreshTokenForUser;

/**
 *  <#Description#>
 *
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
- (void) refreshTokenForUserWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                     failure:(nullable void (^)(NSError * _Nonnull error))failure;

/**
 *  <#Description#>
 *
 *  @param email    <#email description#>
 *  @param password <#password description#>
 *  @param success  <#success description#>
 *  @param failure  <#failure description#>
 */
- (void) refreshTokenForUserWithEmail:(NSString * _Nonnull) email
                             password:(NSString * _Nonnull) password
                     withBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                              failure:(nullable void (^)(NSError * _Nonnull error))failure;


- (void) refreshTokenForUserWithUsername:(NSString * _Nonnull) username
                                password:(NSString * _Nonnull) password
                        withBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                 failure:(nullable void (^)(NSError * _Nonnull error))failure;
/**
 *  <#Description#>
 */
- (void) refreshTokenForUserWithFacebookId:(NSString * _Nonnull) facebookId
                             facebookToken:(NSString * _Nonnull) facebookToken
                          withBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                   failure:(nullable void (^)(NSError * _Nonnull error))failure;

/**
 *  <#Description#>
 */
- (void) refreshTokenForOauthMode:(OAuthMode) oauthMode
                          retries:(NSUInteger) retries
                 WithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                          failure:(nullable void (^)(NSError * _Nonnull error))failure;

/**
 *  <#Description#>
 */
- (BOOL) resetTokenForOauthMode:(OAuthMode) oauthMode;

/**
 *  <#Description#>
 */
- (void) resetAllTokens;

/**
 *  <#Description#>
 */
- (BOOL) setCredentialTokenForOauthMode:(OAuthMode) oauthMode;

- (void) loadManagersWithCredentials;

- (AFOAuthCredential * _Nullable) currentOauthClientCredential;

- (AFOAuthCredential * _Nullable) currentOauthUserCredential;

///--------------------------------------
#pragma mark - PNObjectConfig Properties
///--------------------------------------

@property (nonatomic, readonly, nonnull)  Class userSubClass;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) AFHTTPSessionManager *manager;

/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) AFJSONRequestSerializer *managerJsonRequestSerializer;

/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) AFHTTPRequestSerializer *managerHttpRequestSerializer;

/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) AFJSONRequestSerializer *oauthJsonRequestSerializer;

/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) AFHTTPRequestSerializer *oauthHttpRequestSerializer;

/**
 *  <#Description#>
 */
@property (nonatomic) NSInteger minPasswordLenght;

@end
