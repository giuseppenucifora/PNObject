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

NSString*  const Client_ID = @"oauth_user_credential_client_id";
NSString*  const Client_Secret = @"oauth_user_credential_client_secret";
NSString*  const Client_EndpointAction  = @"oauth_user_credential_endpoint_action";

NSString*  const Client_Credential_ID = @"oauth_client_credential_client_id";
NSString*  const Client_Credential_Secret = @"oauth_client_credential_client_secret";
NSString*  const Client_CredentialEndpointAction  = @"oauth_client_credential_endpoint_action";

NSString*  const Client_Username = @"client_username";
NSString*  const Client_Password = @"client_password";

@interface PNObjectConfig()

@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic, strong) NSMutableDictionary *headerFields;
@property (nonatomic, strong) NSString *currentEnv;
@property (nonatomic, strong) NSString *currentBaseUrl;
@property (nonatomic, strong) NSString *currentEndPointPath;
@property (nonatomic, strong) NSString *currentEndPointUrl;

/* Client credential configurations */
@property (nonatomic, strong) NSString *currentClientCredenzialEndPointPath;
@property (nonatomic, strong) NSString *currentClientCredenzialEndPointUrl;
@property (nonatomic, strong) NSString *currentClientCredenzialClientID;
@property (nonatomic, strong) NSString *currentClientCredenzialClientSecret;

/* User credential configuration */
@property (nonatomic, strong) NSString *currentUserCredenzialEndPointPath;
@property (nonatomic, strong) NSString *currentUserCredenzialEndPointUrl;
@property (nonatomic, strong) NSString *currentUserCredenzialClientID;
@property (nonatomic, strong) NSString *currentUserCredenzialClientSecret;


@property (nonatomic, strong) NSString *currentOAuthUserName;
@property (nonatomic, strong) NSString *currentOAuthPassword;

@property (nonatomic, strong) AFOAuth2Manager *clientCredentialAuthManager;
@property (nonatomic, strong) AFOAuth2Manager *userCredentialAuthManager;

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
    return [self initSharedInstanceForEnvironments:endpointUrlsForEnvironments userSubclass:[PNUser class] withoauthMode:OAuthModeClientCredential];
}

+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary *)endpointUrlsForEnvironments andUserSubclass:(Class)userSubClass {
    return [self initSharedInstanceForEnvironments:endpointUrlsForEnvironments userSubclass:userSubClass withoauthMode:OAuthModeClientCredential];
}

+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments userSubclass:(Class _Nonnull) userSubClass withoauthMode:(OAuthMode) oauthMode {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON_PNObjectConfig = [[super allocWithZone:NULL] initWithUserSubclass:userSubClass];
        
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

- (id) initWithUserSubclass:(Class _Nonnull) userSubClass
{
    if(SINGLETON_PNObjectConfig){
        return SINGLETON_PNObjectConfig;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    
    if (self) {
        _userSubClass = userSubClass;
        _configuration = [[NSMutableDictionary alloc] init];
        _minPasswordLenght = minPassLenght;
        _currentEnv = EnvironmentProduction;
        _managerJsonRequestSerializer = [AFJSONRequestSerializer serializer];
        _managerHttpRequestSerializer = [AFHTTPRequestSerializer serializer];
        
        _oauthJsonRequestSerializer = [AFJSONRequestSerializer serializer];
        _oauthHttpRequestSerializer = [AFHTTPRequestSerializer serializer];
        
        _headerFields = [[NSMutableDictionary alloc] init];
        
        if(![DDDKeychainWrapper dataForKey:PNObjectEncryptionKey]){
            
            NSData *key = [[NSString getRandString:256] dataUsingEncoding:NSUTF8StringEncoding];
            
            [DDDKeychainWrapper setData:key forKey:PNObjectEncryptionKey];
            
        }
        
        
        AFOAuthCredential *clientCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:PNObjectServiceClientCredentialIdentifier];
        
        if (clientCredential) {
            _currentOauthClientCredential = clientCredential;
        }
        
        AFOAuthCredential *userCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:PNObjectServiceUserCredentialIdentifier];
        
        if (userCredential) {
            _currentOauthUserCredential = userCredential;
        }
    }
    return self;
}

- (void) setEnvironment:(NSString * _Nonnull) environment {
    
    _currentEnv = environment;
    _currentBaseUrl = nil;
    
    _currentEndPointPath = nil;
    _currentEndPointUrl = nil;
    
    _currentClientCredenzialEndPointPath = nil;
    _currentClientCredenzialEndPointUrl = nil;
    _currentClientCredenzialClientID = nil;
    _currentClientCredenzialClientSecret = nil;
    
    _currentUserCredenzialEndPointPath = nil;
    _currentUserCredenzialEndPointUrl = nil;
    _currentUserCredenzialClientID = nil;
    _currentUserCredenzialClientSecret = nil;
    
    _currentOAuthUserName = nil;
    _currentOAuthPassword = nil;
    
    if ([_configuration objectForKey:_currentEnv]) {
        
        NSDictionary *currentEnvConfig = [_configuration objectForKey:_currentEnv];
        
        _currentBaseUrl = [currentEnvConfig objectForKey:BaseUrl];
        
        _currentEndPointPath = ([currentEnvConfig objectForKey:EndpointPath] ? [currentEnvConfig objectForKey:EndpointPath] : @"");
        _currentEndPointUrl = [_currentBaseUrl stringByAppendingString:_currentEndPointPath];
        
        _currentClientCredenzialClientID = [currentEnvConfig objectForKey:Client_Credential_ID];
        _currentClientCredenzialClientSecret = [currentEnvConfig objectForKey:Client_Credential_Secret];
        _currentClientCredenzialEndPointPath = ([currentEnvConfig objectForKey:Client_CredentialEndpointAction] ? [currentEnvConfig objectForKey:Client_CredentialEndpointAction] : @"");
        
        if([_currentClientCredenzialEndPointPath containsString:@"%@"]){
            _currentClientCredenzialEndPointPath = [NSString stringWithFormat:_currentClientCredenzialEndPointPath,_currentEndPointPath];
        }
        _currentClientCredenzialEndPointUrl = [_currentBaseUrl stringByAppendingString:_currentClientCredenzialEndPointPath];
        
        
        if (![currentEnvConfig objectForKey:Client_ID] || ![currentEnvConfig objectForKey:Client_Secret]) {
             _currentUserCredenzialClientID = _currentClientCredenzialClientID;
             _currentUserCredenzialClientSecret = _currentClientCredenzialClientSecret;
             _currentUserCredenzialEndPointPath = _currentClientCredenzialEndPointPath;
             _currentUserCredenzialEndPointUrl = _currentClientCredenzialEndPointUrl;
        }
        else {
            _currentUserCredenzialClientID = [currentEnvConfig objectForKey:Client_ID];
            _currentUserCredenzialClientSecret = [currentEnvConfig objectForKey:Client_Secret];
            
            _currentUserCredenzialEndPointPath = [currentEnvConfig objectForKey:Client_EndpointAction];
            
            if([_currentUserCredenzialEndPointPath containsString:@"%@"]){
                _currentUserCredenzialEndPointPath = [NSString stringWithFormat:_currentUserCredenzialEndPointPath,_currentEndPointPath];
            }
            _currentUserCredenzialEndPointUrl = [_currentBaseUrl stringByAppendingString:_currentUserCredenzialEndPointPath];
        }
        
        
        if ([currentEnvConfig objectForKey:Client_Username] && [currentEnvConfig objectForKey:Client_Password]) {
            _currentOAuthUserName = [currentEnvConfig objectForKey:Client_Username];
            _currentOAuthPassword = [currentEnvConfig objectForKey:Client_Password];
        }
    }
    
    NSLogDebug(@"%@",[[_configuration objectForKey:_currentEnv] objectForKey:BaseUrl]);
    
    NSAssert(_currentUserCredenzialEndPointUrl,@"Selected environment generate error. Please check configuration");
    
    if (_currentClientCredenzialClientID && _currentClientCredenzialClientSecret) {
        [self clientCredentialAuthManager];
    }
    
    if (_currentClientCredenzialClientID && _currentClientCredenzialClientSecret) {
        
        [self userCredentialAuthManager];
    }
    [self manager];
}


- (NSString * _Nonnull) getEnvironment {
    return _currentEnv;
}

- (NSString *) baseUrl {
    return _currentBaseUrl;
}

- (NSString *) endPointPath {
    return _currentUserCredenzialEndPointPath;
}

- (NSString *) endPointUrl {
    return _currentUserCredenzialEndPointUrl;
}

- (AFHTTPSessionManager *) manager {
    
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        
        for (NSString *key in [_headerFields allKeys]) {
            
            [_managerHttpRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
            [_managerJsonRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
        }
        
        if (_currentOauthUserCredential && ![_currentOauthUserCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
            
            [_managerHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_managerJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        }
        else if (_currentOauthClientCredential && ![_currentOauthClientCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
            
            [_managerHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_managerJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        }
        else {
            [self refreshToken];
        }
        
        _manager.responseSerializer = [AFJSONResponseSerializerWithData serializer];
        _manager.requestSerializer = _managerJsonRequestSerializer;
    }
    
    return _manager;
}

- (AFOAuth2Manager *) clientCredentialAuthManager {
    
    BOOL canTryRefreh = NO;
    
    if (!_clientCredentialAuthManager) {
        _clientCredentialAuthManager = [AFOAuth2Manager manager];
        
        if (_currentClientCredenzialClientID && _currentClientCredenzialClientSecret) {
            
            if (![_clientCredentialAuthManager clientID]) {
                
                _clientCredentialAuthManager = [AFOAuth2Manager  managerWithBaseURL:[NSURL URLWithString:_currentClientCredenzialEndPointUrl] clientID:_currentClientCredenzialClientID secret:_currentClientCredenzialClientSecret];
            }
            
            [_clientCredentialAuthManager setUseHTTPBasicAuthentication:NO];
            
            canTryRefreh = YES;
        }
        
        for (NSString *key in [_headerFields allKeys]) {
            
            [_oauthHttpRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
            [_oauthJsonRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
        }
        //[_oauthJsonRequestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        
        _clientCredentialAuthManager.responseSerializer = [AFJSONResponseSerializerWithData serializer];
        _clientCredentialAuthManager.requestSerializer = _oauthJsonRequestSerializer;
        
        if (canTryRefreh) {
            
            if (_currentOauthClientCredential && ![_currentOauthClientCredential isExpired]) {
                
                [_oauthHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthClientCredential];
                [_oauthJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthClientCredential];
                [_clientCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthClientCredential];
            }
            else {
                [self refreshToken];
            }
        }
        
    }
    
    return _clientCredentialAuthManager;
}

- (AFOAuth2Manager *) userCredentialAuthManager {
    
    BOOL canTryRefreh = NO;
    
    if (!_userCredentialAuthManager) {
        _userCredentialAuthManager = [AFOAuth2Manager manager];
        
        if (_currentUserCredenzialClientID && _currentUserCredenzialClientID && _currentOAuthUserName && _currentOAuthPassword) {
            
            if (![_userCredentialAuthManager clientID]) {
                _userCredentialAuthManager = [AFOAuth2Manager  managerWithBaseURL:[NSURL URLWithString:_currentClientCredenzialEndPointUrl] clientID:_currentUserCredenzialClientID secret:_currentUserCredenzialClientID];
            }
            
            [_userCredentialAuthManager setUseHTTPBasicAuthentication:NO];
            
            canTryRefreh = YES;
        }
        
        for (NSString *key in [_headerFields allKeys]) {
            
            [_oauthJsonRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
            [_oauthHttpRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
        }
        
        if (canTryRefreh) {
            
            if (_currentOauthUserCredential && ![_currentOauthUserCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
                
                [_oauthHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
                [_oauthJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
                [_userCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            }
            else {
                [self refreshToken];
            }
        }
        
        _userCredentialAuthManager.responseSerializer = [AFJSONResponseSerializerWithData serializer];
        _userCredentialAuthManager.requestSerializer = _oauthJsonRequestSerializer;
    }
    
    return _userCredentialAuthManager;
}

- (BOOL) resetTokenForOauthMode:(OAuthMode) oauthMode {
    switch (oauthMode) {
        case OAuthModeClientCredential:
            if (_currentOauthClientCredential) {
                _currentOauthClientCredential = nil;
                [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceClientCredentialIdentifier];
                return [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceUserCredentialIdentifier];
            }
            break;
        case OAuthModePassword:
            if (_currentOauthUserCredential) {
                _currentOauthUserCredential = nil;
                [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceClientCredentialIdentifier];
                return [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceUserCredentialIdentifier];
            }
            break;
        default:
            break;
    }
    
    
    return NO;
}

- (void) resetAllTokens {
    
    [self resetTokenForOauthMode:OAuthModeClientCredential];
    [self resetTokenForOauthMode:OAuthModePassword];
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

- (void) refreshTokenForClientCredential {
    [self refreshTokenForClientCredentialWithBlockSuccess:nil failure:nil];
}

- (void) refreshTokenForClientCredentialWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                                 failure:(nullable void (^)(NSError * _Nonnull error))failure {
    [self refreshTokenForOauthMode:OAuthModeClientCredential WithBlockSuccess:success failure:failure];
}

- (void) refreshTokenForUserWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                     failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    [self refreshTokenForOauthMode:OAuthModePassword WithBlockSuccess:success failure:failure];
}

- (void) refreshTokenForOauthMode:(OAuthMode) oauthMode
                 WithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                          failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    __block __typeof__(_currentOauthClientCredential) __weak wCurrentOauthCredential = _currentOauthClientCredential;
    
    __block __typeof__(_managerHttpRequestSerializer) __weak wHttpSerializer = _managerHttpRequestSerializer;
    __block __typeof__(_managerJsonRequestSerializer) __weak wJsonSerializer = _managerJsonRequestSerializer;
    __block __typeof__(_clientCredentialAuthManager) __weak wClientCredentialAuthManager = _clientCredentialAuthManager;
    __block __typeof__(_userCredentialAuthManager) __weak wUserCredentialAuthManager = _userCredentialAuthManager;
    __block __typeof__(_manager) __weak wManager = _manager;
    
    
    switch (oauthMode) {
        case OAuthModeClientCredential:
            if (_currentOauthClientCredential && ![_currentOauthClientCredential isExpired]) {
                
                [_clientCredentialAuthManager authenticateUsingOAuthWithURLString:_currentClientCredenzialEndPointUrl refreshToken:[_currentOauthClientCredential refreshToken] success:^(AFOAuthCredential * _Nonnull credential) {
                    wCurrentOauthCredential = credential;
                    
                    [AFOAuthCredential storeCredential:wCurrentOauthCredential withIdentifier:PNObjectServiceClientCredentialIdentifier];
                    
                    [wHttpSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wJsonSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wClientCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wUserCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialSuccess object:nil];
                    if (success) {
                        success(YES);
                    }
                    return;
                    
                } failure:^(NSError * _Nonnull error) {
                    [self resetTokenForOauthMode:oauthMode];
                    
                    [self refreshTokenForClientCredentialWithBlockSuccess:success failure:failure];
                    return;
                }];
            }
            else {
                [_clientCredentialAuthManager authenticateUsingOAuthWithURLString:_currentClientCredenzialEndPointUrl scope:@"" success:^(AFOAuthCredential * _Nonnull credential) {
                    
                    [AFOAuthCredential storeCredential:wCurrentOauthCredential withIdentifier:PNObjectServiceClientCredentialIdentifier];
                    
                    [wHttpSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wJsonSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wClientCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wUserCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialSuccess object:nil];
                    if (success) {
                        success(YES);
                    }
                    return;
                } failure:^(NSError * _Nonnull error) {
                    
                    if (failure) {
                        failure(error);
                    }
                }];
            }
            break;
        case OAuthModePassword:
            if (_currentOauthClientCredential && ![_currentOauthClientCredential isExpired]) {
                if (_currentOauthUserCredential && ![_currentOauthUserCredential isExpired]) {
                    
                    [_userCredentialAuthManager authenticateUsingOAuthWithURLString:_currentClientCredenzialEndPointUrl refreshToken:[_currentOauthUserCredential refreshToken] success:^(AFOAuthCredential * _Nonnull credential) {
                        wCurrentOauthCredential = credential;
                        
                        [AFOAuthCredential storeCredential:wCurrentOauthCredential withIdentifier:PNObjectServiceUserCredentialIdentifier];
                        
                        [wHttpSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                        [wJsonSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                        [wUserCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                        [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialSuccess object:nil];
                        if (success) {
                            success(YES);
                        }
                        return;
                        
                    } failure:^(NSError * _Nonnull error) {
                        [self resetTokenForOauthMode:oauthMode];
                        
                        [self refreshTokenForOauthMode:oauthMode WithBlockSuccess:success failure:failure];
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
                                [self refreshTokenForUserWithFacebookId:[[SINGLETON_PNObjectConfig.userSubClass currentUser] facebookId] facebookToken:[[FBSDKAccessToken currentAccessToken] tokenString] withBlockSuccess:success failure:failure];
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
            else {
                
                [self refreshTokenForClientCredentialWithBlockSuccess:^(BOOL refreshSuccess) {
                    [self refreshTokenForOauthMode:oauthMode WithBlockSuccess:success failure:failure];
                } failure:failure];
            }
            break;
        default: {
            if (success) {
                success(YES);
            }
        }
            break;
    }
}

- (void) refreshTokenForUserWithFacebookId:(NSString * _Nonnull) facebookId
                             facebookToken:(NSString * _Nonnull) facebookToken
                          withBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                   failure:(nullable void (^)(NSError * _Nonnull error))failure {
    if (!facebookId || [facebookId length] == 0) {
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
    
    __block __typeof__(_currentOauthUserCredential) __weak wCurrentOauthCredential = _currentOauthUserCredential;
    
    __block __typeof__(_managerHttpRequestSerializer) __weak wHttpSerializer = _managerHttpRequestSerializer;
    __block __typeof__(_managerJsonRequestSerializer) __weak wJsonSerializer = _managerJsonRequestSerializer;
    __block __typeof__(_manager) __weak wManager = _manager;
    __block __typeof__(_userCredentialAuthManager) __weak wUserCredentialAuthManager = _userCredentialAuthManager;
    
    [_userCredentialAuthManager authenticateUsingFacebookOAuthWithURLString:_currentClientCredenzialEndPointUrl facebookId:facebookId facebookToken:facebookToken scope:@"" success:^(AFOAuthCredential * _Nonnull credential) {
        wCurrentOauthCredential = credential;
        
        [AFOAuthCredential storeCredential:wCurrentOauthCredential withIdentifier:PNObjectServiceUserCredentialIdentifier];
        
        [wHttpSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
        [wJsonSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
        [wUserCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
        [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
        
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
    
    __block __typeof__(_currentOauthUserCredential) __weak wCurrentOauthCredential = _currentOauthUserCredential;
    
    __block __typeof__(_managerHttpRequestSerializer) __weak wHttpSerializer = _managerHttpRequestSerializer;
    __block __typeof__(_managerJsonRequestSerializer) __weak wJsonSerializer = _managerJsonRequestSerializer;
    __block __typeof__(_manager) __weak wManager = _manager;
    __block __typeof__(_userCredentialAuthManager) __weak wUserCredentialAuthManager = _userCredentialAuthManager;
    
    
    [_userCredentialAuthManager authenticateUsingOAuthWithURLString:_currentClientCredenzialEndPointUrl username:email password:password scope:@"" success:^(AFOAuthCredential * _Nonnull credential) {
        wCurrentOauthCredential = credential;
        
        [AFOAuthCredential storeCredential:wCurrentOauthCredential withIdentifier:PNObjectServiceUserCredentialIdentifier];
        
        [wHttpSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
        [wJsonSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
        [wUserCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
        [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
        
        
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

- (void) setClientID:(NSString * _Nonnull) clientID clientSecret:(NSString* _Nonnull) clientSecret oAuthEndpointAction:(NSString* _Nonnull) oAuthEndpointAction oauthMode:(OAuthMode) oauthMode forEnv:(NSString *) environment {
    
    if ([_configuration objectForKey:environment]) {
        
        NSMutableDictionary *currentConfigurationDict = [[NSMutableDictionary alloc] initWithDictionary:[_configuration objectForKey:environment]];
        switch (oauthMode) {
            case OAuthModeClientCredential:
                [currentConfigurationDict setObject:clientID forKey:Client_Credential_ID];
                [currentConfigurationDict setObject:clientSecret forKey:Client_Credential_Secret];
                [currentConfigurationDict setObject:oAuthEndpointAction forKey:Client_CredentialEndpointAction];
                break;
            case OAuthModePassword:{
                [currentConfigurationDict setObject:clientID forKey:Client_ID];
                [currentConfigurationDict setObject:clientSecret forKey:Client_Secret];
                [currentConfigurationDict setObject:oAuthEndpointAction forKey:Client_EndpointAction];
            }
                break;
            default:
                break;
        }
        
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

- (BOOL) setCredentialTokenForOauthMode:(OAuthMode) oauthMode {
    switch (oauthMode) {
        case OAuthModeClientCredential:
            if (_currentOauthClientCredential && ![_currentOauthClientCredential isExpired]) {
                return NO;
            }
            [_managerHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthClientCredential];
            [_managerJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthClientCredential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthClientCredential];
            break;
        case OAuthModePassword:
            if (_currentOauthUserCredential && ![_currentOauthUserCredential isExpired]) {
                return NO;
            }
            [_managerHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_managerJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            break;
        default:
            [_managerHttpRequestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
            [_managerJsonRequestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
            [_manager.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
            break;
    }
    return YES;
}

@end
