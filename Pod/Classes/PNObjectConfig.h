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

#pragma mark LocalNotification Keys

extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenClientCredentialSuccess;
extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenClientCredentialFail;
extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenUserSuccess;
extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenUserFail;
extern NSString* _Nonnull const PNObjectLocalNotificationUserReloadFromServerSuccess;
#pragma mark -

extern NSString* _Nonnull const EnvironmentProduction;
extern NSString* _Nonnull const EnvironmentStage;
extern NSString* _Nonnull const EnvironmentDevelopment;

extern NSString* _Nonnull const Client_ID;
extern NSString* _Nonnull const Client_Secret;

@interface PNObjectConfig : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (instancetype _Nonnull) sharedInstance;

/**
 *	Oauth is NO by default
 *
 *  @param endpointUrlsForEnvironments
 *  For example,
 *  @{   PNObjectConfigDevelopment : @"https://development.it/api/v1",
 *       PNObjectConfigEnvStage : @"ttps://stage.it/api/v1",
 *       PNObjectConfigEnvProduction : @"ttps://production.it/api/v1"
 *   }
 *
 *  @return singleton
 */
+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments;

/**
 *  <#Description#>
 *
 *  @param endpointUrlsForEnvironments
 *  For example,
 *  @{   PNObjectConfigDevelopment : @"https://development.it/api/v1",
 *       PNObjectConfigEnvStage : @"ttps://stage.it/api/v1",
 *       PNObjectConfigEnvProduction : @"ttps://production.it/api/v1"
 *   }
 *  @param userSubClass                <#userSubClass description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments andUserSubclass:(Class _Nonnull) userSubClass;

/**
 *
 *
 *  @param endpointUrlsForEnvironments
 *  For example,
 *  @{   PNObjectConfigDevelopment : @"https://development.it/api/v1",
 *       PNObjectConfigEnvStage : @"ttps://stage.it/api/v1",
 *       PNObjectConfigEnvProduction : @"ttps://production.it/api/v1"
 *   }
 *  @param oauthEnabled                <#oauthEnabled description#>
 *
 *  @return singleton
 */
+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments withOauth:(BOOL) oauthEnabled;

/**
 *  <#Description#>
 *
 *  @param endpointUrlsForEnvironments
 *  For example,
 *  @{   PNObjectConfigDevelopment : @"https://development.it/api/v1",
 *       PNObjectConfigEnvStage : @"ttps://stage.it/api/v1",
 *       PNObjectConfigEnvProduction : @"ttps://production.it/api/v1"
 *   }
 *  @param userSubClass                <#userSubClass description#>
 *  @param oauthEnabled                <#oauthEnabled description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments userSubclass:(Class _Nonnull) userSubClass withOauth:(BOOL) oauthEnabled;
/**
 *  <#Description#>
 *
 *  @param env <#env description#>
 */
- (void) setEnvironment:(NSString * _Nonnull) environment;

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
 *  @param value EnvironmentProduction, EnvironmentStage, EnvironmentDevelopment
 *  @param key   <#key description#>
 */
- (void) removeHTTPHeaderValueForKey:(NSString * _Nonnull) key;

- (void) setClientID:(NSString * _Nonnull) clientID clientSecret:(NSString* _Nonnull) clientSecret forEnv:(NSString * _Nonnull) environment;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSString * _Nonnull) baseUrl;

/**
 *  <#Description#>
 *
 *  @param passLenght <#passLenght description#>
 */
- (void) setAcceptablePasswordLenght:(NSUInteger) passLenght;

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
/**
 *  <#Description#>
 */
- (BOOL) resetToken;

///--------------------------------------
#pragma mark - PNObjectConfig Properties
///--------------------------------------

/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) AFHTTPSessionManager *manager;

/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) AFJSONRequestSerializer *jsonSerializer;

/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) AFHTTPRequestSerializer *httpSerializer;

/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable, readonly) AFOAuthCredential *currentOauthCredential;

/**
 *  <#Description#>
 */
@property (nonatomic) NSInteger minPasswordLenght;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull, readonly) NSString *encrypKey;

@property (nonatomic, strong, nonnull, readonly) NSString *nonce;

@end