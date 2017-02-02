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
#import "AFJSONResponseSerializerWithData.h"
#import "NSString+Helper.h"
#import "PNObject+Protected.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <NSDataAES/NSData+AES.h>
#import <DDDKeychainWrapper/DDDKeychainWrapper.h>
#import "HTTPStatusCodes.h"

NSString * const PNObjectLocalNotificationRefreshTokenClientCredentialSuccess = @"PNObjectLocalNotificationRefreshTokenClientCredentialSuccess";
NSString * const PNObjectLocalNotificationRefreshTokenClientCredentialFail = @"PNObjectLocalNotificationRefreshTokenClientCredentialFail";


NSString * const PNObjectLocalNotificationRefreshTokenUserSuccess = @"PNObjectLocalNotificationRefreshTokenUserSuccess";
NSString * const PNObjectLocalNotificationRefreshTokenUserFail = @"PNObjectLocalNotificationRefreshTokenUserFail";

NSString * const PNObjectLocalNotificationUserReloadFromServerSuccess = @"PNObjectLocalNotificationUserReloadFromServerSuccess";
NSString * const PNObjectLocalNotificationUserReloadFromServerFailure = @"PNObjectLocalNotificationUserReloadFromServerFailure";

NSString * const PNObjectLocalNotificationUserWillLogout = @"PNObjectLocalNotificationUserLogout";
NSString * const PNObjectLocalNotificationUserEndLogout = @"PNObjectLocalNotificationUserLogout";

NSString * const PNObjectLocalNotificationPNInstallationUserNew = @"PNObjectLocalNotificationPNInstallationUserNew";
NSString * const PNObjectLocalNotificationPNInstallationUserChange = @"PNObjectLocalNotificationPNInstallationUserChange";
NSString * const PNObjectLocalNotificationPNInstallationUserDelete = @"PNObjectLocalNotificationPNInstallationUserDelete";

NSInteger const minPassLenght = 4;

NSString * const PNObjectEncryptionKey = @"PNObjectConfigEncryptionKey";

NSString * const PNObjectServiceClientCredentialIdentifier = @"PNObjectServiceClientCredentialIdentifier";
NSString * const PNObjectServiceUserCredentialIdentifier = @"PNObjectServiceUserCredentialIdentifier";

NSString* const EnvironmentProduction = @"PNObjectConfigEnvProduction";
NSString* const EnvironmentStage = @"PNObjectConfigEnvStage";
NSString* const EnvironmentDevelopment = @"PNObjectConfigDevelopment";

NSString*  const BaseUrl = @"base_url";
NSString*  const EndpointPath = @"endpoint_path";
NSString*  const Client_ID = @"client_id";
NSString*  const Client_Secret = @"client_secret";
NSString*  const Client_Username = @"client_username";
NSString*  const Client_Password = @"client_password";

@interface PNObjectConfig()

@property (nonatomic) OAuthMode oauthMode;

@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic, strong) NSMutableDictionary *headerFields;
@property (nonatomic, strong) NSString *currentEnv;
@property (nonatomic, strong) NSString *currentBaseUrl;
@property (nonatomic, strong) NSString *currentEndPointPath;
@property (nonatomic, strong) NSString *currentEndPointUrl;
@property (nonatomic, strong) NSString *currentOAuthClientID;
@property (nonatomic, strong) NSString *currentOAuthClientSecret;
@property (nonatomic, strong) NSString *currentOAuthUserName;
@property (nonatomic, strong) NSString *currentOAuthPassword;

@property (nonatomic, strong) AFOAuth2Manager *authManager;



@end

@implementation PNObjectConfig

@synthesize manager = _manager;


static PNObjectConfig *SINGLETON_PNObjectConfig = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (instancetype _Nullable)sharedInstance
{
    return SINGLETON_PNObjectConfig;
}

#pragma mark - Life Cycle

+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary *) endpointUrlsForEnvironments {
    return [self initSharedInstanceForEnvironments:endpointUrlsForEnvironments userSubclass:[PNUser class] withOauthMode:OAuthModeClientCredential];
}

+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary *)endpointUrlsForEnvironments andUserSubclass:(Class)userSubClass {
    return [self initSharedInstanceForEnvironments:endpointUrlsForEnvironments userSubclass:userSubClass withOauthMode:OAuthModeClientCredential];
}


+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary *) endpointUrlsForEnvironments withOauthMode:(OAuthMode) oauthMode {
    return [self initSharedInstanceForEnvironments:endpointUrlsForEnvironments userSubclass:[PNUser class] withOauthMode:oauthMode];
}

+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments userSubclass:(Class _Nonnull) userSubClass withOauthMode:(OAuthMode) oauthMode {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON_PNObjectConfig = [[super allocWithZone:NULL] initWithUserSubclass:userSubClass withOauthMode:oauthMode];
        
        if (SINGLETON_PNObjectConfig) {
            
            for (NSString *key in [endpointUrlsForEnvironments allKeys]) {
                
                if ([[endpointUrlsForEnvironments objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                    
                    NSURL * baseUrl = [NSURL URLWithString:[[endpointUrlsForEnvironments objectForKey:key] objectForKey:BaseUrl]];
                    NSString * endPointUrl = [[endpointUrlsForEnvironments objectForKey:key] objectForKey:EndpointPath];
                    if (baseUrl) {
                        [SINGLETON_PNObjectConfig.configuration setValue:[NSDictionary dictionaryWithObjectsAndKeys:[baseUrl absoluteString],BaseUrl,endPointUrl,EndpointPath, nil] forKey:key];
                    }
                }
                else if ([[endpointUrlsForEnvironments objectForKey:key] isKindOfClass:[NSString class]]) {
                    NSURL * baseUrl = [NSURL URLWithString:[endpointUrlsForEnvironments objectForKey:key]];
                    if (baseUrl) {
                        [SINGLETON_PNObjectConfig.configuration setValue:[NSDictionary dictionaryWithObjectsAndKeys:[baseUrl absoluteString],BaseUrl,@"",EndpointPath, nil] forKey:key];
                    }
                }
            }
            NSAssert([SINGLETON_PNObjectConfig.configuration objectForKey:EnvironmentProduction], @"EnvironmentProduction must be valid endpoint url");
            
        }
    });
    
    return SINGLETON_PNObjectConfig;
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

- (id) initWithUserSubclass:(Class _Nonnull) userSubClass withOauthMode:(OAuthMode) oauthMode
{
    if(SINGLETON_PNObjectConfig){
        return SINGLETON_PNObjectConfig;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    
    if (self) {
        _oauthMode = oauthMode;
        _userSubClass = userSubClass;
        _configuration = [[NSMutableDictionary alloc] init];
        _minPasswordLenght = minPassLenght;
        _currentEnv = EnvironmentProduction;
        _jsonSerializer = [AFJSONRequestSerializer serializer];
        _httpSerializer = [AFHTTPRequestSerializer serializer];
        
        _headerFields = [[NSMutableDictionary alloc] init];
        
        if(![DDDKeychainWrapper dataForKey:PNObjectEncryptionKey]){
            
            NSData *key = [[NSString getRandString:256] dataUsingEncoding:NSUTF8StringEncoding];
            
            [DDDKeychainWrapper setData:key forKey:PNObjectEncryptionKey];
            
        }
        
        
        switch (_oauthMode) {
            case OAuthModePassword:
            case OAuthModeClientCredential:
            default: {
                
                AFOAuthCredential *clientCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:PNObjectServiceClientCredentialIdentifier];
                
                if (clientCredential) {
                    _currentOauthCredential = clientCredential;
                }
                
                AFOAuthCredential *userCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:PNObjectServiceUserCredentialIdentifier];
                
                if (userCredential) {
                    _currentOauthCredential = userCredential;
                }
            }
                break;
        }
    }
    return self;
}

- (void) setEnvironment:(NSString * _Nonnull) environment {
    
    _currentEnv = environment;
    _currentBaseUrl = nil;
    _currentEndPointPath = nil;
    _currentEndPointUrl = nil;
    _currentOAuthClientID = nil;
    _currentOAuthClientSecret = nil;
    _currentOAuthUserName = nil;
    _currentOAuthPassword = nil;
    
    if ([_configuration objectForKey:environment]) {
        _currentBaseUrl = [[_configuration objectForKey:_currentEnv] objectForKey:BaseUrl];
        _currentEndPointPath = ([[_configuration objectForKey:_currentEnv] objectForKey:EndpointPath] ? [[_configuration objectForKey:_currentEnv] objectForKey:EndpointPath] : @"");
        _currentEndPointUrl = [_currentBaseUrl stringByAppendingString:_currentEndPointPath];
        _currentOAuthClientID = [[_configuration objectForKey:_currentEnv] objectForKey:Client_ID];
        _currentOAuthClientSecret = [[_configuration objectForKey:_currentEnv] objectForKey:Client_Secret];
        if ([[_configuration objectForKey:_currentEnv] objectForKey:Client_Username] && [[_configuration objectForKey:_currentEnv] objectForKey:Client_Password]) {
            _currentOAuthUserName = [[_configuration objectForKey:_currentEnv] objectForKey:Client_Username];
            _currentOAuthPassword = [[_configuration objectForKey:_currentEnv] objectForKey:Client_Password];
        }
    }
    
    NSLogDebug(@"%@",[[_configuration objectForKey:_currentEnv] objectForKey:BaseUrl]);
    
    NSAssert(_currentEndPointUrl,@"Selected environment generate error. Please check configuration");
    
    if (_currentOAuthClientID && _currentOAuthClientSecret) {
        [self authManager];
        
        [self manager];
    }
}

- (NSString *) baseUrl {
    return _currentBaseUrl;
}

- (NSString *) endPointPath {
    return _currentEndPointPath;
}

- (NSString *) endPointUrl {
    return _currentEndPointUrl;
}

- (AFHTTPSessionManager *) manager {
    
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        
        for (NSString *key in [_headerFields allKeys]) {
            
            [_httpSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
            [_jsonSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
        }
        
        if (_currentOauthCredential && ![_currentOauthCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
            
            [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        }
        else {
            [self refreshToken];
        }
        
        _manager.responseSerializer = [AFJSONResponseSerializerWithData serializer];
        _manager.requestSerializer = _jsonSerializer;
    }
    
    return _manager;
}

- (AFOAuth2Manager *) authManager {
    
    BOOL canTryRefreh = NO;
    
    if (!_authManager) {
        _authManager = [AFOAuth2Manager manager];
        
        switch (_oauthMode) {
            case OAuthModeClientCredential:{
                if (_currentOAuthClientID && _currentOAuthClientSecret) {
                    
                    
                    if (![_authManager clientID]) {
                        _authManager = [AFOAuth2Manager  managerWithBaseURL:[NSURL URLWithString:_currentEndPointUrl] clientID:_currentOAuthClientID secret:_currentOAuthClientSecret];
                    }
                    
                    [_authManager setUseHTTPBasicAuthentication:NO];
                    
                    canTryRefreh = YES;
                }
            }
                break;
            case OAuthModePassword:{
                if (_currentOAuthClientID && _currentOAuthClientSecret && _currentOAuthUserName && _currentOAuthPassword) {
                    
                    if (![_authManager clientID]) {
                        _authManager = [AFOAuth2Manager  managerWithBaseURL:[NSURL URLWithString:_currentEndPointUrl] clientID:_currentOAuthClientID secret:_currentOAuthClientSecret];
                    }
                    
                    [_authManager setUseHTTPBasicAuthentication:NO];
                    
                    canTryRefreh = YES;
                }
            }
                break;
            case OAuthModeNo:
            default:{
                
            }
                break;
        }
        
        
        for (NSString *key in [_headerFields allKeys]) {
            
            [_httpSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
            [_jsonSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
        }
        
        if (canTryRefreh) {
            
            if (_currentOauthCredential && ![_currentOauthCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
                
                [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                [_authManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            }
            else {
                [self refreshToken];
            }
        }
        
        _authManager.responseSerializer = [AFJSONResponseSerializerWithData serializer];
    }
    
    return _authManager;
}

- (BOOL) resetToken {
    if (_currentOauthCredential) {
        _currentOauthCredential = nil;
        [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceClientCredentialIdentifier];
        return [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceUserCredentialIdentifier];
    }
    return NO;
}

- (void) refreshToken {
    
    [self refreshTokenWithBlockSuccess:nil failure:nil];
    
}

- (void) refreshTokenWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                              failure:(nullable void (^)(NSError * _Nonnull error))failure {
    if([SINGLETON_PNObjectConfig.userSubClass currentUser] && ([[SINGLETON_PNObjectConfig.userSubClass currentUser] hasValidEmailAndPasswordData] || [[SINGLETON_PNObjectConfig.userSubClass currentUser] facebookId])) {
        [self refreshTokenForUserWithBlockSuccess:success failure:failure];
    }
    else {
        [self refreshTokenForClientCredentialWithBlockSuccess:success failure:failure];
    }
}

- (void) refreshTokenForUser {
    
    [self refreshTokenForUserWithBlockSuccess:nil failure:nil];
}

- (void) refreshTokenForUserWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                     failure:(nullable void (^)(NSError * _Nonnull error))failure {
    if (_currentOauthCredential) {
        
        [_authManager authenticateUsingOAuthWithURLString:[_currentEndPointUrl stringByAppendingString:@"oauth-token"] refreshToken:[_currentOauthCredential refreshToken] success:^(AFOAuthCredential * _Nonnull credential) {
            _currentOauthCredential = credential;
            
            
            [AFOAuthCredential storeCredential:_currentOauthCredential withIdentifier:PNObjectServiceUserCredentialIdentifier];
            
            [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            [_authManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenUserSuccess object:nil];
            if (success) {
                success(YES);
            }
            return;
            
        } failure:^(NSError * _Nonnull error) {
            [self resetToken];
            
            [self refreshTokenForUserWithBlockSuccess:success failure:failure];
            return;
        }];
        
    }
    else {
        if([SINGLETON_PNObjectConfig.userSubClass currentUser] && [[SINGLETON_PNObjectConfig.userSubClass currentUser] hasValidEmailAndPasswordData]) {
            
            [self refreshTokenForUserWithEmail:[[SINGLETON_PNObjectConfig.userSubClass currentUser] email]  password:[[(PNUser*)[SINGLETON_PNObjectConfig.userSubClass currentUser] password] password]  withBlockSuccess:success failure:failure];
            return;
        }
        else if ([SINGLETON_PNObjectConfig.userSubClass currentUser] && [[SINGLETON_PNObjectConfig.userSubClass currentUser] facebookId]){
            [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    if (failure) {
                        failure(error);
                    }
                }
                else {
                    [self refreshTokenForUserWithFacebookID:[[SINGLETON_PNObjectConfig.userSubClass currentUser] facebookId] facebookToken:[[FBSDKAccessToken currentAccessToken] tokenString] withBlockSuccess:success failure:failure];
                }
            }];
        }
        else {
            if (failure) {
                
                NSError *error = [NSError errorWithDomain:@"" code:kHTTPStatusCodeBadRequest userInfo:nil];
                failure(error);
                [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenUserFail object:nil];
            }
        }
    }
}

- (void) refreshTokenForUserWithEmail:(NSString * _Nonnull) email
                             password:(NSString * _Nonnull) password
                     withBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                              failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    if (![email isValidEmail]) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:NSLocalizedString(@"Email is not valid", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
            failure(error);
            return;
        }
    }
    if (![SINGLETON_PNObjectConfig.userSubClass isValidPassword:password]) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:NSLocalizedString(@"Password is not valid", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
            failure(error);
            return;
        }
    }
    [_authManager authenticateUsingOAuthWithURLString:[_currentEndPointUrl stringByAppendingString:@"oauth-token"] username:email password:password scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
        _currentOauthCredential = credential;
        
        
        [AFOAuthCredential storeCredential:_currentOauthCredential withIdentifier:PNObjectServiceUserCredentialIdentifier];
        
        [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        [_authManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenUserSuccess object:nil];
        if (success) {
            success(YES);
        }
    } failure:^(NSError * _Nonnull error) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenUserFail object:nil];
        if (failure) {
            failure(error);
        }
    }];
}

- (void) refreshTokenForUserWithFacebookID:(NSString * _Nonnull) facebookID
                             facebookToken:(NSString * _Nonnull) facebookToken
                          withBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                   failure:(nullable void (^)(NSError * _Nonnull error))failure {
    if (!facebookID || [facebookID length] == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:NSLocalizedString(@"Facebook id is not valid", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
            failure(error);
            return;
        }
    }
    if (!facebookToken || [facebookToken length] == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:NSLocalizedString(@"Facebook token is not valid", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
            failure(error);
            return;
        }
    }
    
    [_authManager authenticateUsingFacebookOAuthWithURLString:[_currentEndPointUrl stringByAppendingString:@"oauth-token"] facebookID:facebookID facebookToken:facebookToken scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
        _currentOauthCredential = credential;
        
        [AFOAuthCredential storeCredential:_currentOauthCredential withIdentifier:PNObjectServiceUserCredentialIdentifier];
        
        [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        [_authManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenUserSuccess object:nil];
        if (success) {
            success(YES);
        }
    } failure:^(NSError * _Nonnull error) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenUserFail object:nil];
        if (failure) {
            failure(error);
        }
    }];
}

- (void) refreshTokenForClientCredential {
    [self refreshTokenForClientCredentialWithBlockSuccess:nil failure:nil];
}


- (void) refreshTokenForClientCredentialWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                                 failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    if (_currentOauthCredential) {
        
        [_authManager authenticateUsingOAuthWithURLString:[_currentEndPointUrl stringByAppendingString:@"oauth-token"] refreshToken:[_currentOauthCredential refreshToken] success:^(AFOAuthCredential * _Nonnull credential) {
            _currentOauthCredential = credential;
            
            [AFOAuthCredential storeCredential:_currentOauthCredential withIdentifier:PNObjectServiceClientCredentialIdentifier];
            
            [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            [_authManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialSuccess object:nil];
            if (success) {
                success(YES);
            }
            return;
            
        } failure:^(NSError * _Nonnull error) {
            [self resetToken];
            
            [self refreshTokenForClientCredentialWithBlockSuccess:success failure:failure];
            return;
        }];
    }
    else {
        switch (_oauthMode) {
            case OAuthModeClientCredential:{
                [_authManager authenticateUsingOAuthWithURLString:[_currentEndPointUrl stringByAppendingString:@"oauth-token"] scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
                    _currentOauthCredential = credential;
                    
                    [AFOAuthCredential storeCredential:_currentOauthCredential withIdentifier:PNObjectServiceClientCredentialIdentifier];
                    
                    [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                    [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                    [_authManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                    [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialSuccess object:nil];
                    if (success) {
                        success(YES);
                    }
                    
                } failure:^(NSError * _Nonnull error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialFail object:nil];
                    if (failure) {
                        failure(error);
                    }
                }];
            }
                break;
            case OAuthModePassword:{
                
                [_authManager authenticateUsingOAuthWithURLString:[_currentEndPointUrl stringByAppendingString:@"oauth-token"] username:_currentOAuthUserName password:_currentOAuthPassword scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
                    _currentOauthCredential = credential;
                    
                    [AFOAuthCredential storeCredential:_currentOauthCredential withIdentifier:PNObjectServiceClientCredentialIdentifier];
                    
                    [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                    [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                    [_authManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                    [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialSuccess object:nil];
                    if (success) {
                        success(YES);
                    }
                    
                } failure:^(NSError * _Nonnull error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialFail object:nil];
                    if (failure) {
                        failure(error);
                    }
                }];
            }
                break;
            case OAuthModeNo:
            default:
                
                break;
        }
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

- (void) setClientID:(NSString * _Nonnull) clientID clientSecret:(NSString* _Nonnull) clientSecret forEnv:(NSString *) environment {
    
    if ([_configuration objectForKey:environment]) {
        
        NSMutableDictionary *currentConfigurationDict = [[NSMutableDictionary alloc] initWithDictionary:[_configuration objectForKey:environment]];
        [currentConfigurationDict setObject:clientID forKey:Client_ID];
        [currentConfigurationDict setObject:clientSecret forKey:Client_Secret];
        
        [_configuration setObject:currentConfigurationDict forKey:environment];
        
        if (_currentEnv == environment) {
            [self setEnvironment:environment];
        }
    }
}

- (void) setOauthUserName:(NSString * _Nonnull)oauthUserName oauthPassword:(NSString* _Nonnull) oauthPassword forEnv:(NSString *) environment {
    
    if ([_configuration objectForKey:environment]) {
        
        NSMutableDictionary *currentConfigurationDict = [[NSMutableDictionary alloc] initWithDictionary:[_configuration objectForKey:environment]];
        [currentConfigurationDict setObject:oauthUserName forKey:Client_Username];
        [currentConfigurationDict setObject:oauthPassword forKey:Client_Password];
        
        [_configuration setObject:currentConfigurationDict forKey:environment];
        
        if (_currentEnv == environment) {
            [self setEnvironment:environment];
        }
    }
}

@end
