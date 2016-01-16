//
//  PNObjectConfig.m
//  Pods
//
//  Created by Giuseppe Nucifora on 08/01/16.
//
//

#import "PNObjectConfig.h"
#import "PNObjectConstants.h"

NSString* const EnvironmentProduction = @"PNObjectConfigEnvProduction";
NSString* const EnvironmentStage = @"PNObjectConfigEnvStage";
NSString* const EnvironmentDevelopment = @"PNObjectConfigDevelopment";


@interface PNObjectConfig()

@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic, strong) NSString *currentEnvironment;
@property (nonatomic) BOOL devEnabled;
@property (nonatomic) BOOL stageEnabled;
@property (nonatomic) BOOL productionEnabled;


@end

@implementation PNObjectConfig



static PNObjectConfig *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (instancetype) initSharedInstanceForEnvironments:(NSDictionary *) endpointUrlsForEnvironments {
    SINGLETON = [self sharedInstance];
    
    if (SINGLETON) {
        for (NSString *key in [endpointUrlsForEnvironments allKeys]) {
            
            ((void (^)())@{
                           EnvironmentDevelopment : ^{
                NSURL * endpointUrl = [NSURL URLWithString:[endpointUrlsForEnvironments objectForKey:key]];
                if (endpointUrl) {
                    [SINGLETON.configuration setValue:[endpointUrl absoluteString] forKey:key];
                    SINGLETON.devEnabled = YES;
                }
                
            },
                           EnvironmentStage : ^{
                NSURL * endpointUrl = [NSURL URLWithString:[endpointUrlsForEnvironments objectForKey:key]];
                if (endpointUrl) {
                    [SINGLETON.configuration setValue:[endpointUrl absoluteString] forKey:key];
                    SINGLETON.stageEnabled = YES;
                }
            },
                           EnvironmentProduction : ^{
                NSURL * endpointUrl = [NSURL URLWithString:[endpointUrlsForEnvironments objectForKey:key]];
                if (endpointUrl) {
                    [SINGLETON.configuration setValue:[endpointUrl absoluteString] forKey:key];
                    SINGLETON.productionEnabled = YES;
                }
            }
                           }[key] ?: ^{
                               
                           })();
        }
        NSAssert(SINGLETON.productionEnabled, @"EnvironmentProduction must be valid endpoint url");
        SINGLETON.currentEnvironment = [[SINGLETON configuration] objectForKey:EnvironmentProduction];
        
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

- (void) setEnvironment:(Environment) env {
    
    _currentEnvironment = nil;
    
    switch (env) {
        case Development:{
            if (_devEnabled) {
                _currentEnvironment = [_configuration objectForKey:EnvironmentDevelopment];
            }
        }
            break;
        case Stage:{
            if (_stageEnabled) {
                _currentEnvironment = [_configuration objectForKey:EnvironmentStage];
            }
        }
            break;
        case Production:
        default:
            if (_productionEnabled) {
                _currentEnvironment = [_configuration objectForKey:EnvironmentProduction];
            }
            break;
    }
    
    NSAssert(_currentEnvironment,@"Selected environment generate error. Please check configuration");
    
}

- (NSString *) PNObjEndpoint {
    return _currentEnvironment;
}

@end
