    //
    //  PNObjectConfig.m
    //  Pods
    //
    //  Created by Giuseppe Nucifora on 08/01/16.
    //
    //

#import "PNObjectConfig.h"
#import "PNObjectConstants.h"
#import "PNUser.h"


NSString * const PNObjectLocalNotificationRefreshTokenClientCredentialSuccess = @"PNObjectLocalNotificationRefreshTokenClientCredentialSuccess";
NSString * const PNObjectLocalNotificationRefreshTokenClientCredentialFail = @"PNObjectLocalNotificationRefreshTokenClientCredentialFail";


NSString * const PNObjectLocalNotificationRefreshTokenUserSuccess = @"PNObjectLocalNotificationRefreshTokenUserSuccess";
NSString * const PNObjectLocalNotificationRefreshTokenUserFail = @"PNObjectLocalNotificationRefreshTokenUserFail";


NSInteger const minPassLenght = 4;

NSString * const PNObjectServiceCredentialIdentifier = @"PNObjectServiceCredentialIdentifier";

NSString* const EnvironmentProduction = @"PNObjectConfigEnvProduction";
NSString* const EnvironmentStage = @"PNObjectConfigEnvStage";
NSString* const EnvironmentDevelopment = @"PNObjectConfigDevelopment";

NSString*  const BaseUrl = @"base_url";
NSString*  const Client_ID = @"client_id";
NSString*  const Client_Secret = @"client_secret";

@interface PNObjectConfig()

@property (nonatomic) BOOL oauthEnabled;

@property (nonatomic, strong) AFOAuthCredential *currentOauthCredential;

@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic, strong) NSMutableDictionary *headerFields;
@property (nonatomic) Environment currentEnv;
@property (nonatomic, strong) NSString *currentEndPointBaseUrl;
@property (nonatomic, strong) NSString *currentOAuthClientID;
@property (nonatomic, strong) NSString *currentOAuthClientSecret;
@property (nonatomic, strong) NSMutableArray *environments;

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
    return [self initSharedInstanceForEnvironments:endpointUrlsForEnvironments withOauth:NO];
}

+ (instancetype) initSharedInstanceForEnvironments:(NSDictionary *) endpointUrlsForEnvironments withOauth:(BOOL) oauthEnabled {
    SINGLETON = [self sharedInstance];
    
    if (SINGLETON) {
        SINGLETON.oauthEnabled = oauthEnabled;
        for (NSString *key in [endpointUrlsForEnvironments allKeys]) {
            
            if ([SINGLETON.environments containsObject:key]) {
                
                NSURL * endpointUrl = [NSURL URLWithString:[endpointUrlsForEnvironments objectForKey:key]];
                if (endpointUrl) {
                    [SINGLETON.configuration setValue:[NSDictionary dictionaryWithObjectsAndKeys:[endpointUrl absoluteString],BaseUrl, nil] forKey:key];
                }
            }
        }
        NSAssert([SINGLETON.configuration objectForKey:EnvironmentProduction], @"EnvironmentProduction must be valid endpoint url");
        [SINGLETON setEnvironment:Production];
        
        
        
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
        if (_oauthEnabled) {
            _currentOauthCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:PNObjectServiceCredentialIdentifier];
        }
        
        _environments = [[NSMutableArray alloc] initWithArray:@[EnvironmentDevelopment,EnvironmentStage,EnvironmentProduction]];
        
        _configuration = [[NSMutableDictionary alloc] init];
        _minPasswordLenght = minPassLenght;
        
        _headerFields = [[NSMutableDictionary alloc] init];
        
        
    }
    return self;
}

- (void) setEnvironment:(Environment) env {
    
    _currentEnv = env;
    _currentEndPointBaseUrl = nil;
    _currentOAuthClientID = nil;
    _currentOAuthClientSecret = nil;
    
    if (env < [_environments count]) {
        if ([_configuration objectForKey:[_environments objectAtIndex:env]]) {
            _currentEndPointBaseUrl = [[_configuration objectForKey:[_environments objectAtIndex:env]] objectForKey:BaseUrl];
            _currentOAuthClientID = [[_configuration objectForKey:[_environments objectAtIndex:env]] objectForKey:Client_ID];
            _currentOAuthClientSecret = [[_configuration objectForKey:[_environments objectAtIndex:env]] objectForKey:Client_Secret];
        }
    }
    else {
        _currentEndPointBaseUrl = [[_configuration objectForKey:EnvironmentProduction] objectForKey:BaseUrl];
        if ([[_configuration objectForKey:EnvironmentProduction] objectForKey:Client_ID]) {
            _currentOAuthClientID = [[_configuration objectForKey:EnvironmentProduction] objectForKey:Client_ID];
        }
        if ([[_configuration objectForKey:EnvironmentProduction] objectForKey:Client_Secret]) {
            _currentOAuthClientSecret = [[_configuration objectForKey:EnvironmentProduction] objectForKey:Client_Secret];
        }
    }
    NSLog(@"%@",[[_configuration objectForKey:[_environments objectAtIndex:env]] objectForKey:BaseUrl]);
    
    NSAssert(_currentEndPointBaseUrl,@"Selected environment generate error. Please check configuration");
    
    [self manager];
    
}

- (NSString *) baseUrl {
    return _currentEndPointBaseUrl;
}

- (AFOAuth2Manager *) manager {
    
    BOOL canTryRefreh = NO;
    
    if (!_manager) {
        _manager = [AFOAuth2Manager manager];
    }
    
    if (_oauthEnabled && _currentOAuthClientID && _currentOAuthClientSecret) {
        
        if (![_manager clientID]) {
            _manager = [AFOAuth2Manager  managerWithBaseURL:[NSURL URLWithString:_currentEndPointBaseUrl] clientID:_currentOAuthClientID secret:_currentOAuthClientSecret];
        }
        
        [_manager setUseHTTPBasicAuthentication:NO];
        
        canTryRefreh = YES;
    }
    
    for (NSString *key in [_headerFields allKeys]) {
        
        [[_manager requestSerializer] setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
    }
    
    if (canTryRefreh) {
        
        if (!_currentOauthCredential) {
            
            [self tryRefreshToken];
        }
        else {
            [[_manager requestSerializer] setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        }
    }
    
    return _manager;
}

- (void) tryRefreshToken {
    if ([PNUser currentUser]) {
        [_manager authenticateUsingOAuthWithURLString:[_currentEndPointBaseUrl stringByAppendingString:@"oauth-token"] username:[[PNUser currentUser] username] password:[[PNUser currentUser] password] scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
            _currentOauthCredential = credential;
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        } failure:^(NSError * _Nonnull error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenUserFail object:error];
        }];
    }
    else {
        
        [_manager authenticateUsingOAuthWithURLString:[_currentEndPointBaseUrl stringByAppendingString:@"oauth-token"] scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
            _currentOauthCredential = credential;
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        } failure:^(NSError * _Nonnull error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialFail object:error];
        }];
    }
}

- (void) setAcceptablePasswordLenght:(NSUInteger) passLenght {
    _minPasswordLenght = passLenght;
}

- (void) setHTTPHeaderValue:(NSString * _Nonnull)value forKey:(NSString * _Nonnull) key {
    [_headerFields setObject:value forKey:key];
}

- (void) removeHTTPHeaderValueForKey:(NSString * _Nonnull) key {
    if ([_headerFields objectForKey:key]) {
        [_headerFields removeObjectForKey:key];
    }
}

- (void) setClientID:(NSString * _Nonnull) clientID clientSecret:(NSString* _Nonnull) clientSecret forEnv:(Environment) environment {
    
    if ([_configuration objectForKey:[_environments objectAtIndex:environment]]) {
        
        NSMutableDictionary *currentConfigurationDict = [[NSMutableDictionary alloc] initWithDictionary:[_configuration objectForKey:[_environments objectAtIndex:environment]]];
        [currentConfigurationDict setObject:clientID forKey:Client_ID];
        [currentConfigurationDict setObject:clientSecret forKey:Client_Secret];
        
        [_configuration setObject:currentConfigurationDict forKey:[_environments objectAtIndex:environment]];
        
        if (_currentEnv == environment) {
            [self setEnvironment:environment];
        }
    }
}

@end
