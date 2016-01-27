//
//  PNObjectConfig.h
//  Pods
//
//  Created by Giuseppe Nucifora on 08/01/16.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSInteger, Environment) {
	Development,
	Stage,
	Production
};

extern NSString* const EnvironmentProduction;
extern NSString* const EnvironmentStage;
extern NSString* const EnvironmentDevelopment;


@interface PNObjectConfig : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (instancetype) sharedInstance;

/**
 *
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
+ (instancetype) initSharedInstanceForEnvironments:(NSDictionary *) endpointUrlsForEnvironments;

/**
 *  <#Description#>
 *
 *  @param env <#env description#>
 */
- (void) setEnvironment:(Environment) env;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSString *) PNObjEndpoint;

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
@property (nonatomic, strong) AFHTTPSessionManager *manager;
/**
 *  <#Description#>
 */
@property (nonatomic) NSInteger minPasswordLenght;

@end