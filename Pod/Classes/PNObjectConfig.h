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

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic) NSInteger minPasswordLenght;

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

- (void) setEnvironment:(Environment) env;

- (NSString *) PNObjEndpoint;

- (NSString *) minPasswordLenght:(NSUInteger) passLenght;

@end