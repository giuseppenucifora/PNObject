//
//  PNObjectConfig.h
//  Pods
//
//  Created by Giuseppe Nucifora on 08/01/16.
//
//

#import <Foundation/Foundation.h>

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
+ (instancetype) sharedInstanceForEnvironments:(NSDictionary *) endpointUrlsForEnvironments;

- (void) enableEnvironment:(Environment) env;



@end