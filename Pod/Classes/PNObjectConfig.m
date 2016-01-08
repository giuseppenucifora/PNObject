//
//  PNObjectConfig.m
//  Pods
//
//  Created by Giuseppe Nucifora on 08/01/16.
//
//

#import "PNObjectConfig.h"

NSString* const EnvironmentProduction = @"PNObjectConfigEnvProduction";
NSString* const EnvironmentStage = @"PNObjectConfigEnvStage";
NSString* const EnvironmentDevelopment = @"PNObjectConfigDevelopment";


@interface PNObjectConfig()

@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic) BOOL devEnabled;
@property (nonatomic) BOOL stageEnabled;
@property (nonatomic) BOOL productionEnabled;

@end

@implementation PNObjectConfig



static PNObjectConfig *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (instancetype) sharedInstanceForEnvironments:(NSDictionary *) endpointUrlsForEnvironments {
    SINGLETON = [self sharedInstance];
    
    if (SINGLETON) {
        for (NSString *key in [endpointUrlsForEnvironments allKeys]) {
            
            ((void (^)())@{
                           EnvironmentDevelopment : ^{
                NSURL * endpointUrl = [NSURL URLWithString:[endpointUrlsForEnvironments objectForKey:key]];
                if (endpointUrl) {
                    [SINGLETON.configuration setValue:endpointUrl forKey:key];
                    SINGLETON.devEnabled = YES;
                }
                
            },
                           EnvironmentStage : ^{
                NSURL * endpointUrl = [NSURL URLWithString:[endpointUrlsForEnvironments objectForKey:key]];
                if (endpointUrl) {
                    [SINGLETON.configuration setValue:endpointUrl forKey:key];
                    SINGLETON.stageEnabled = YES;
                }
            },
                           EnvironmentProduction : ^{
                NSURL * endpointUrl = [NSURL URLWithString:[endpointUrlsForEnvironments objectForKey:key]];
                if (endpointUrl) {
                    [SINGLETON.configuration setValue:endpointUrl forKey:key];
                    SINGLETON.productionEnabled = YES;
                }
            }
                           }[key] ?: ^{
                               
                           })();
        }
        NSAssert(SINGLETON.productionEnabled, @"EnvironmentProduction must be valid endpoint url");
        
        NSLog(@"Config : %@",SINGLETON.configuration);
    }
    return SINGLETON;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return [[PNObjectConfig alloc] init];
}

- (id)mutableCopy
{
    return [[PNObjectConfig alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    
    if (self) {
        _configuration = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) enableEnvironment:(Environment) env {
    
    switch (env) {
        case Development:{
            
        }
            break;
        case Stage:{
            
        }
            break;
        case Production:
        default:
            break;
    }
}

@end
