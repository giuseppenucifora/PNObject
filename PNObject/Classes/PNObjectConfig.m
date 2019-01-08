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
#import "PNObject+PNObjectConnection.h"

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
NSString*  const Client_Refresh_Token_Enabled = @"oauth_user_credential_refresh_token_enabled";

NSString*  const Client_Credential_ID = @"oauth_client_credential_client_id";
NSString*  const Client_Credential_Secret = @"oauth_client_credential_client_secret";
NSString*  const Client_Credential_EndpointAction  = @"oauth_client_credential_endpoint_action";
NSString*  const Client_Credential_Refresh_Token_Enabled = @"oauth_client_credential_refresh_token_enabled";

NSString*  const Client_Username = @"client_username";
NSString*  const Client_Password = @"client_password";

@interface PNObjectConfig()

@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic, strong) NSMutableDictionary *headerFields;
@property (nonatomic, strong) NSString *currentEnv;
@property (nonatomic, strong) NSString *currentBaseUrl;
@property (nonatomic, strong) NSString *currentEndPointPath;
@property (nonatomic, strong) NSString *currentEndPointUrl;
@property (nonatomic, strong) NSString *storeClientIdentifier;

/* Client credential configurations */
@property (nonatomic, strong) NSString *currentClientCredenzialEndPointPath;
@property (nonatomic, strong) NSString *currentClientCredenzialEndPointUrl;
@property (nonatomic, strong) NSString *currentClientCredenzialClientID;
@property (nonatomic, strong) NSString *currentClientCredenzialClientSecret;
@property (nonatomic) BOOL currentClientCredenzialRefreshTokenEnabled;

/* User credential configuration */
@property (nonatomic, strong) NSString *currentUserCredenzialEndPointPath;
@property (nonatomic, strong) NSString *currentUserCredenzialEndPointUrl;
@property (nonatomic, strong) NSString *currentUserCredenzialClientID;
@property (nonatomic, strong) NSString *currentUserCredenzialClientSecret;
@property (nonatomic) BOOL currentUserCredenzialRefreshTokenEnabled;

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

+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary *) endpointUrlsForEnvironments andStoreClientIdentifier:(NSString* _Nonnull) identifier {
    return [self initSharedInstanceForEnvironments:endpointUrlsForEnvironments userSubclass:[PNUser class] withoauthMode:OAuthModeClientCredential andStoreClientIdentifier:identifier];
}

+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments userSubclass:(Class _Nonnull) userSubClass andStoreClientIdentifier:(NSString* _Nonnull) identifier {
    return [self initSharedInstanceForEnvironments:endpointUrlsForEnvironments userSubclass:userSubClass withoauthMode:OAuthModeClientCredential andStoreClientIdentifier:identifier];
}

+ (instancetype _Nonnull) initSharedInstanceForEnvironments:(NSDictionary * _Nonnull) endpointUrlsForEnvironments userSubclass:(Class _Nonnull) userSubClass withoauthMode:(OAuthMode) oauthMode andStoreClientIdentifier:(NSString* _Nonnull) identifier  {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON_PNObjectConfig = [[super allocWithZone:NULL] initWithUserSubclass:userSubClass andStoreClientIdentifier:identifier];
        
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

- (id) initWithUserSubclass:(Class _Nonnull) userSubClass andStoreClientIdentifier:(NSString* _Nonnull) identifier
{
    if(SINGLETON_PNObjectConfig){
        return SINGLETON_PNObjectConfig;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    
    if (self) {
        _storeClientIdentifier = identifier;
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
        
        AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[self clientCredentialIdentifier]];
        
        if (!credential || [credential isExpired]) {
            [AFOAuthCredential deleteCredentialWithIdentifier:[self clientCredentialIdentifier]];
        }
        
        credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[self userCredentialIdentifier]];
        
        if (!credential || [credential isExpired]) {
            [AFOAuthCredential deleteCredentialWithIdentifier:[self userCredentialIdentifier]];
        }
        
    }
    return self;
}

- (NSString *) clientCredentialIdentifier {
    return [NSString stringWithFormat:@"%@_%@",_storeClientIdentifier,PNObjectServiceClientCredentialIdentifier];
}

- (NSString *) userCredentialIdentifier {
    return [NSString stringWithFormat:@"%@_%@",_storeClientIdentifier,PNObjectServiceClientCredentialIdentifier];
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
        _currentClientCredenzialEndPointPath = ([currentEnvConfig objectForKey:Client_Credential_EndpointAction] ? [currentEnvConfig objectForKey:Client_Credential_EndpointAction] : @"");
        _currentClientCredenzialRefreshTokenEnabled = ([currentEnvConfig objectForKey:Client_Credential_Refresh_Token_Enabled] ? [[currentEnvConfig objectForKey:Client_Credential_Refresh_Token_Enabled] boolValue] : YES);
        
        if([_currentClientCredenzialEndPointPath containsString:@"%@"]){
            _currentClientCredenzialEndPointPath = [NSString stringWithFormat:_currentClientCredenzialEndPointPath,_currentEndPointPath];
        }
        _currentClientCredenzialEndPointUrl = [_currentBaseUrl stringByAppendingString:_currentClientCredenzialEndPointPath];
        
        
        if (![currentEnvConfig objectForKey:Client_ID] || ![currentEnvConfig objectForKey:Client_Secret]) {
            _currentUserCredenzialClientID = _currentClientCredenzialClientID;
            _currentUserCredenzialClientSecret = _currentClientCredenzialClientSecret;
            _currentUserCredenzialEndPointPath = _currentClientCredenzialEndPointPath;
            _currentUserCredenzialEndPointUrl = _currentClientCredenzialEndPointUrl;
            _currentUserCredenzialRefreshTokenEnabled = _currentClientCredenzialRefreshTokenEnabled;
        }
        else {
            _currentUserCredenzialClientID = [currentEnvConfig objectForKey:Client_ID];
            _currentUserCredenzialClientSecret = [currentEnvConfig objectForKey:Client_Secret];
            
            _currentUserCredenzialEndPointPath = [currentEnvConfig objectForKey:Client_EndpointAction];
            
            if([_currentUserCredenzialEndPointPath containsString:@"%@"]){
                _currentUserCredenzialEndPointPath = [NSString stringWithFormat:_currentUserCredenzialEndPointPath,_currentEndPointPath];
            }
            _currentUserCredenzialEndPointUrl = [_currentBaseUrl stringByAppendingString:_currentUserCredenzialEndPointPath];
            
            _currentUserCredenzialRefreshTokenEnabled = [currentEnvConfig objectForKey:Client_Refresh_Token_Enabled];
        }
        
        
        if ([currentEnvConfig objectForKey:Client_Username] && [currentEnvConfig objectForKey:Client_Password]) {
            _currentOAuthUserName = [currentEnvConfig objectForKey:Client_Username];
            _currentOAuthPassword = [currentEnvConfig objectForKey:Client_Password];
        }
    }
    
    NSLogDebug(@"%@",[[_configuration objectForKey:_currentEnv] objectForKey:BaseUrl]);
    
    NSAssert(_currentUserCredenzialEndPointUrl,@"Selected environment generate error. Please check configuration");
}

- (void) loadManagersWithCredentials {
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
    return _currentEndPointPath;
}

- (NSString *) endPointUrl {
    return _currentEndPointUrl;
}

- (AFHTTPSessionManager *) manager {
    
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        
        for (NSString *key in [_headerFields allKeys]) {
            
            [_managerHttpRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
            [_managerJsonRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
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
        
        AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[self clientCredentialIdentifier]];
        
        if (credential && ![credential isExpired]) {
            
            [_oauthHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:credential];
            [_oauthJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:credential];
            [_clientCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        }
    }
    
    return _clientCredentialAuthManager;
}

- (AFOAuth2Manager *) userCredentialAuthManager {
    
    BOOL canTryRefreh = NO;
    
    if (!_userCredentialAuthManager) {
        _userCredentialAuthManager = [AFOAuth2Manager manager];
        
        if ((_currentUserCredenzialClientID && _currentUserCredenzialClientID) || (_currentOAuthUserName && _currentOAuthPassword)) {
            
            if (![_userCredentialAuthManager clientID]) {
                _userCredentialAuthManager = [AFOAuth2Manager  managerWithBaseURL:[NSURL URLWithString:_currentClientCredenzialEndPointUrl] clientID:_currentUserCredenzialClientID secret:_currentUserCredenzialClientSecret];
            }
            
            [_userCredentialAuthManager setUseHTTPBasicAuthentication:NO];
            
            canTryRefreh = YES;
        }
        
        for (NSString *key in [_headerFields allKeys]) {
            
            [_oauthJsonRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
            [_oauthHttpRequestSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
        }
        
        AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[self userCredentialIdentifier]];
        
        if (credential && ![credential isExpired]) {
            
            [_oauthHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:credential];
            [_oauthJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:credential];
            [_userCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        }
        
        _userCredentialAuthManager.responseSerializer = [AFJSONResponseSerializerWithData serializer];
        _userCredentialAuthManager.requestSerializer = _oauthJsonRequestSerializer;
    }
    
    return _userCredentialAuthManager;
}

- (BOOL) resetTokenForOauthMode:(OAuthMode) oauthMode {
    switch (oauthMode) {
        case OAuthModeClientCredential:
            
            return [AFOAuthCredential deleteCredentialWithIdentifier:[self clientCredentialIdentifier]];
            
            break;
        case OAuthModePassword:
            
            return [AFOAuthCredential deleteCredentialWithIdentifier:[self userCredentialIdentifier]];
            
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
    [self refreshTokenForOauthMode:OAuthModeClientCredential retries:MAX_RETRIES WithBlockSuccess:success failure:failure];
}

- (void) refreshTokenForUserWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                     failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    [self refreshTokenForOauthMode:OAuthModePassword retries:MAX_RETRIES WithBlockSuccess:success failure:failure];
}

- (void) refreshTokenForOauthMode:(OAuthMode) oauthMode
                          retries:(NSUInteger) retries
                 WithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                          failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    __block __typeof__(_managerHttpRequestSerializer) wHttpSerializer = _managerHttpRequestSerializer;
    __block __typeof__(_managerJsonRequestSerializer) wJsonSerializer = _managerJsonRequestSerializer;
    __block __typeof__(_clientCredentialAuthManager) wClientCredentialAuthManager = _clientCredentialAuthManager;
    __block __typeof__(_userCredentialAuthManager) wUserCredentialAuthManager = _userCredentialAuthManager;
    __block __typeof__(_manager) wManager = _manager;
    
    switch (oauthMode) {
        case OAuthModeClientCredential: {
            AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[self clientCredentialIdentifier]];
            
            if (credential && ![credential isExpired] && nil != [credential refreshToken] && _currentClientCredenzialRefreshTokenEnabled) {
                
                [_clientCredentialAuthManager authenticateUsingOAuthWithURLString:_currentClientCredenzialEndPointUrl refreshToken:[credential refreshToken] success:^(AFOAuthCredential * _Nonnull credential) {
                    
                    [AFOAuthCredential storeCredential:credential withIdentifier:[self clientCredentialIdentifier]];
                    
                    [wHttpSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    [wJsonSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    [wClientCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialSuccess object:nil];
                    if (success) {
                        success(YES);
                    }
                    return;
                    
                } failure:^(NSError * _Nonnull error) {
                    
                    if (retries > 0) {
                        [self refreshTokenForOauthMode:oauthMode retries:retries-1 WithBlockSuccess:success failure:failure];
                    }
                    else {
                        [self resetTokenForOauthMode:oauthMode];
                        [self refreshTokenForOauthMode:oauthMode retries:0 WithBlockSuccess:success failure:failure];
                    }
                    
                    return;
                }];
            }
            else {
                [_clientCredentialAuthManager authenticateUsingOAuthWithURLString:_currentClientCredenzialEndPointUrl scope:@"" success:^(AFOAuthCredential * _Nonnull credential) {
                    
                    [AFOAuthCredential storeCredential:credential withIdentifier:[self clientCredentialIdentifier]];
                    
                    [wHttpSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    [wJsonSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    [wClientCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    
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
        }
            break;
        case OAuthModePassword:{
            
            AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[self userCredentialIdentifier]];
            
            if (credential && ![credential isExpired] && nil != [credential refreshToken] && _currentUserCredenzialRefreshTokenEnabled) {
                
                [_userCredentialAuthManager authenticateUsingOAuthWithURLString:_currentClientCredenzialEndPointUrl refreshToken:[credential refreshToken] success:^(AFOAuthCredential * _Nonnull credential) {
                    
                    [AFOAuthCredential storeCredential:credential withIdentifier:[self userCredentialIdentifier]];
                    
                    [wHttpSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    [wJsonSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    [wUserCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialSuccess object:nil];
                    if (success) {
                        success(YES);
                    }
                    return;
                    
                } failure:^(NSError * _Nonnull error) {
                    if (retries > 0) {
                        [self refreshTokenForOauthMode:oauthMode retries:retries-1 WithBlockSuccess:success failure:failure];
                    }
                    else {
                        [self resetTokenForOauthMode:oauthMode];
                        [self refreshTokenForOauthMode:oauthMode retries:0 WithBlockSuccess:success failure:failure];
                    }
                    
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
    
    __block __typeof__(_managerHttpRequestSerializer)  wHttpSerializer = _managerHttpRequestSerializer;
    __block __typeof__(_managerJsonRequestSerializer)  wJsonSerializer = _managerJsonRequestSerializer;
    __block __typeof__(_manager)  wManager = _manager;
    __block __typeof__(_userCredentialAuthManager)  wUserCredentialAuthManager = _userCredentialAuthManager;
    
    [_userCredentialAuthManager authenticateUsingFacebookOAuthWithURLString:_currentClientCredenzialEndPointUrl facebookId:facebookId facebookToken:facebookToken scope:@"" success:^(AFOAuthCredential * _Nonnull credential) {
        
        [AFOAuthCredential storeCredential:credential withIdentifier:[self userCredentialIdentifier]];
        
        [wHttpSerializer setAuthorizationHeaderFieldWithCredential:credential];
        [wJsonSerializer setAuthorizationHeaderFieldWithCredential:credential];
        [wUserCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        
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
    
    __block __typeof__(_managerHttpRequestSerializer)  wHttpSerializer = _managerHttpRequestSerializer;
    __block __typeof__(_managerJsonRequestSerializer)  wJsonSerializer = _managerJsonRequestSerializer;
    __block __typeof__(_manager)  wManager = _manager;
    __block __typeof__(_userCredentialAuthManager) wUserCredentialAuthManager = _userCredentialAuthManager;
    
    
    [_userCredentialAuthManager authenticateUsingOAuthWithURLString:_currentClientCredenzialEndPointUrl username:email password:password scope:@"" success:^(AFOAuthCredential * _Nonnull credential) {
        
        [AFOAuthCredential storeCredential:credential withIdentifier:[self userCredentialIdentifier]];
        
        [wHttpSerializer setAuthorizationHeaderFieldWithCredential:credential];
        [wJsonSerializer setAuthorizationHeaderFieldWithCredential:credential];
        [wUserCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        
        
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

- (void) refreshTokenForUserWithUsername:(NSString * _Nonnull) username
                                password:(NSString * _Nonnull) password
                        withBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                 failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    if (![SINGLETON_PNObjectConfig.userSubClass isValidPassword:password]) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:NSLocalizedString(@"Password is not valid", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
            failure(error);
            return;
        }
    }
    
    __block __typeof__(_managerHttpRequestSerializer)  wHttpSerializer = _managerHttpRequestSerializer;
    __block __typeof__(_managerJsonRequestSerializer)  wJsonSerializer = _managerJsonRequestSerializer;
    __block __typeof__(_manager)  wManager = _manager;
    __block __typeof__(_userCredentialAuthManager) wUserCredentialAuthManager = _userCredentialAuthManager;
    
    
    [_userCredentialAuthManager authenticateUsingOAuthWithURLString:_currentClientCredenzialEndPointUrl username:username password:password scope:@"" success:^(AFOAuthCredential * _Nonnull credential) {
        
        [AFOAuthCredential storeCredential:credential withIdentifier:[self userCredentialIdentifier]];
        
        [wHttpSerializer setAuthorizationHeaderFieldWithCredential:credential];
        [wJsonSerializer setAuthorizationHeaderFieldWithCredential:credential];
        [wUserCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        
        
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
    
    if (_managerHttpRequestSerializer) {
        [_managerHttpRequestSerializer setValue:value forHTTPHeaderField:key];
    }
    if (_managerJsonRequestSerializer) {
        [_managerJsonRequestSerializer setValue:value forHTTPHeaderField:key];
    }
    if (_oauthHttpRequestSerializer) {
        [_oauthHttpRequestSerializer setValue:value forHTTPHeaderField:key];
    }
    if (_oauthJsonRequestSerializer) {
        [_oauthJsonRequestSerializer setValue:value forHTTPHeaderField:key];
    }
}

- (void) removeHTTPHeaderValueForKey:(NSString * _Nonnull) key {
    if ([_headerFields objectForKey:key]) {
        [_headerFields removeObjectForKey:key];
    }
    
    if (_managerHttpRequestSerializer) {
        [_managerHttpRequestSerializer setValue:nil forHTTPHeaderField:key];
    }
    if (_managerJsonRequestSerializer) {
        [_managerJsonRequestSerializer setValue:nil forHTTPHeaderField:key];
    }
    if (_oauthHttpRequestSerializer) {
        [_oauthHttpRequestSerializer setValue:nil forHTTPHeaderField:key];
    }
    if (_oauthJsonRequestSerializer) {
        [_oauthJsonRequestSerializer setValue:nil forHTTPHeaderField:key];
    }
}

- (void) setClientID:(NSString * _Nonnull) clientID clientSecret:(NSString* _Nonnull) clientSecret oAuthEndpointAction:(NSString* _Nonnull) oAuthEndpointAction oauthMode:(OAuthMode) oauthMode refreshTokenEnabled:(BOOL) refreshTokenEnabled forEnv:(NSString * _Nonnull) environment {
    
    if ([_configuration objectForKey:environment]) {
        
        NSMutableDictionary *currentConfigurationDict = [[NSMutableDictionary alloc] initWithDictionary:[_configuration objectForKey:environment]];
        switch (oauthMode) {
            case OAuthModeClientCredential:
                [currentConfigurationDict setObject:clientID forKey:Client_Credential_ID];
                [currentConfigurationDict setObject:clientSecret forKey:Client_Credential_Secret];
                [currentConfigurationDict setObject:oAuthEndpointAction forKey:Client_Credential_EndpointAction];
                [currentConfigurationDict setObject:[NSNumber numberWithBool:refreshTokenEnabled] forKey:Client_Credential_Refresh_Token_Enabled];
                break;
            case OAuthModePassword:{
                [currentConfigurationDict setObject:clientID forKey:Client_ID];
                [currentConfigurationDict setObject:clientSecret forKey:Client_Secret];
                [currentConfigurationDict setObject:oAuthEndpointAction forKey:Client_EndpointAction];
                [currentConfigurationDict setObject:[NSNumber numberWithBool:refreshTokenEnabled] forKey:Client_Refresh_Token_Enabled];
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
        case OAuthModeClientCredential:{
            
            AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[self clientCredentialIdentifier]];
            if (!credential || (credential && [credential isExpired])) {
                return NO;
            }
            [_managerHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:credential];
            [_managerJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:credential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        }
            break;
        case OAuthModePassword:{
            
            AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[self userCredentialIdentifier]];
            if (!credential || (credential && [credential isExpired])) {
                return NO;
            }
            [_managerHttpRequestSerializer setAuthorizationHeaderFieldWithCredential:credential];
            [_managerJsonRequestSerializer setAuthorizationHeaderFieldWithCredential:credential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        }
            break;
        default: {
            [_managerHttpRequestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
            [_managerJsonRequestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
            [_manager.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
        }
            break;
    }
    return YES;
}
- (AFOAuthCredential * _Nullable) currentOauthClientCredential {
    return [AFOAuthCredential retrieveCredentialWithIdentifier:[self clientCredentialIdentifier]];
}

- (AFOAuthCredential * _Nullable) currentOauthUserCredential {
    return [AFOAuthCredential retrieveCredentialWithIdentifier:[self userCredentialIdentifier]];
}

@end
