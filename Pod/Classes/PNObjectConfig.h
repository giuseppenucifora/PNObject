//
//  PNObjectConfig.h
//  Pods
//
//  Created by Giuseppe Nucifora on 08/01/16.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "AFOAuth2Manager.h"
#import "AFHTTPRequestSerializer+OAuth2.h"
#import "AFOAuthCredential.h"

typedef NS_ENUM(NSInteger, Environment) {
    Development = 0,
    Stage = 1,
    Production = 2
};


#pragma mark LocalNotification Keys

extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenClientCredentialSuccess;
extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenClientCredentialFail;
extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenUserSuccess;
extern NSString* _Nonnull const PNObjectLocalNotificationRefreshTokenUserFail;

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
 *  @param clientIdsForEnvironments
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
 *
 *
 *  @param clientIdsForEnvironments
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
 *  @param env <#env description#>
 */
- (void) setEnvironment:(Environment) env;

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
 *  @param value <#value description#>
 *  @param key   <#key description#>
 */
- (void) removeHTTPHeaderValueForKey:(NSString * _Nonnull) key;

- (void) setClientID:(NSString * _Nonnull) clientID clientSecret:(NSString* _Nonnull) clientSecret forEnv:(Environment) environment;

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


///--------------------------------------
#pragma mark - PNObjectConfig Properties
///--------------------------------------
/**
 *  <#Description#>
 */
@property (nonatomic, strong) AFOAuth2Manager *manager;

/**
 *  <#Description#>
 */
@property (nonatomic) NSInteger minPasswordLenght;

@end