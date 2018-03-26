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
NSString*  const OAuthEndpointPath = @"oauth_endpoint_path";
NSString*  const OAuthEndpointAction  = @"oauth_endpoint_action";

NSString*  const Client_ID = @"client_id";
NSString*  const Client_Secret = @"client_secret";

NSString*  const OAuthClient_ID = @"client_id";
NSString*  const OAuthClient_Secret = @"client_secret";


NSString*  const Client_Username = @"client_username";
NSString*  const Client_Password = @"client_password";

@interface PNObjectConfig()

@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic, strong) NSMutableDictionary *headerFields;
@property (nonatomic, strong) NSString *currentEnv;
@property (nonatomic, strong) NSString *currentBaseUrl;

@property (nonatomic, strong) NSString *currentEndPointPath;
@property (nonatomic, strong) NSString *currentEndPointUrl;
@property (nonatomic, strong) NSString *currentOAuthClientID;
@property (nonatomic, strong) NSString *currentOAuthClientSecret;


@property (nonatomic, strong) NSString *currentOauthEndPointPath;
@property (nonatomic, strong) NSString *currentOauthEndPointUrl;
@property (nonatomic, strong) NSString *currentOauthEndPointAction;
@property (nonatomic, strong) NSString *currentClientID;
@property (nonatomic, strong) NSString *currentClientSecret;

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
                    _currentOauthClientCredential = clientCredential;
                }
                
                AFOAuthCredential *userCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:PNObjectServiceUserCredentialIdentifier];
                
                if (userCredential) {
                    _currentOauthUserCredential = userCredential;
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
    
    
    _currentOauthEndPointPath = nil;
    _currentOauthEndPointUrl = nil;
    _currentOAuthClientID = nil;
    _currentOAuthClientSecret = nil;
    
    _currentEndPointPath = nil;
    _currentEndPointUrl = nil;
    _currentClientID = nil;
    _currentClientSecret = nil;
    
    _currentOAuthUserName = nil;
    _currentOAuthPassword = nil;
    
    if ([_configuration objectForKey:_currentEnv]) {
        
        NSDictionary *currentEnvConfig = [_configuration objectForKey:_currentEnv];
        
        _currentBaseUrl = [currentEnvConfig objectForKey:BaseUrl];
        
        
        _currentEndPointPath = ([currentEnvConfig objectForKey:EndpointPath] ? [currentEnvConfig objectForKey:EndpointPath] : @"");
        _currentClientID = [currentEnvConfig objectForKey:Client_ID];
        _currentClientSecret = [currentEnvConfig objectForKey:Client_Secret];
        
        _currentEndPointUrl = [_currentBaseUrl stringByAppendingString:_currentEndPointPath];
        
        _currentOauthEndPointAction = [currentEnvConfig objectForKey:OAuthEndpointAction];
        
        if (![currentEnvConfig objectForKey:OAuthClient_ID] || ![currentEnvConfig objectForKey:OAuthClient_Secret]) {
            _currentOAuthClientID = _currentClientID;
            _currentOAuthClientSecret = _currentClientSecret;
        }
        else {
            _currentOAuthClientID = [currentEnvConfig objectForKey:OAuthClient_ID];
            _currentOAuthClientSecret = [currentEnvConfig objectForKey:OAuthClient_Secret];
        }
        
        if (![currentEnvConfig objectForKey:OAuthClient_ID] || ![currentEnvConfig objectForKey:OAuthClient_Secret]) {
            _currentOauthEndPointPath = _currentEndPointPath;
            _currentOauthEndPointUrl = _currentEndPointUrl;
        }
        else {
            _currentOauthEndPointPath = ([currentEnvConfig objectForKey:OAuthEndpointPath] ? [currentEnvConfig objectForKey:OAuthEndpointPath] : @"");
            _currentOauthEndPointUrl = [_currentBaseUrl stringByAppendingString:_currentOauthEndPointPath];
        }
        
        
        if ([currentEnvConfig objectForKey:Client_Username] && [currentEnvConfig objectForKey:Client_Password]) {
            _currentOAuthUserName = [currentEnvConfig objectForKey:Client_Username];
            _currentOAuthPassword = [currentEnvConfig objectForKey:Client_Password];
        }
    }
    
    NSLogDebug(@"%@",[[_configuration objectForKey:_currentEnv] objectForKey:BaseUrl]);
    
    NSAssert(_currentEndPointUrl,@"Selected environment generate error. Please check configuration");
    
    if (_currentOAuthClientID && _currentOAuthClientSecret) {
        [self clientCredentialAuthManager];
        [self userCredentialAuthManager];
        [self manager];
    }
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
            
            [_httpSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
            [_jsonSerializer setValue:[_headerFields objectForKey:key] forHTTPHeaderField:key];
        }
        
        if (_currentOauthUserCredential && ![_currentOauthUserCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
            
            [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        }
        else if (_currentOauthClientCredential && ![_currentOauthClientCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
            
            [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        }
        else {
            [self refreshToken];
        }
        
        _manager.responseSerializer = [AFJSONResponseSerializerWithData serializer];
        _manager.requestSerializer = _jsonSerializer;
    }
    
    return _manager;
}

- (BOOL) setCredentialIfPossible {
    
    BOOL response = NO;
    
    if (_currentOauthUserCredential && ![_currentOauthUserCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
        
        [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        response = YES;
    }
    else if (_currentOauthClientCredential && ![_currentOauthClientCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
        
        [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
        response = YES;
    }
    
    return response;
}

- (AFOAuth2Manager *) clientCredentialAuthManager {
    
    BOOL canTryRefreh = NO;
    
    if (!_clientCredentialAuthManager) {
        _clientCredentialAuthManager = [AFOAuth2Manager manager];
        
        switch (_oauthMode) {
            case OAuthModeClientCredential:{
                if (_currentOAuthClientID && _currentOAuthClientSecret) {
                    
                    if (![_clientCredentialAuthManager clientID]) {
                        _clientCredentialAuthManager = [AFOAuth2Manager  managerWithBaseURL:[NSURL URLWithString:_currentOauthEndPointUrl] clientID:_currentOAuthClientID secret:_currentOAuthClientSecret];
                    }
                    
                    [_clientCredentialAuthManager setUseHTTPBasicAuthentication:NO];
                    
                    canTryRefreh = YES;
                }
            }
                break;
            case OAuthModePassword:
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
            
            if (_currentOauthClientCredential && ![_currentOauthClientCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
                
                [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthClientCredential];
                [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthClientCredential];
                [_clientCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthClientCredential];
            }
            else {
                [self refreshToken];
            }
        }
        
        _clientCredentialAuthManager.responseSerializer = [AFJSONResponseSerializerWithData serializer];
    }
    
    return _clientCredentialAuthManager;
}

- (AFOAuth2Manager *) userCredentialAuthManager {
    
    BOOL canTryRefreh = NO;
    
    if (!_userCredentialAuthManager) {
        _userCredentialAuthManager = [AFOAuth2Manager manager];
        
        switch (_oauthMode) {
            
            case OAuthModePassword:{
                if (_currentClientID && _currentClientID && _currentOAuthUserName && _currentOAuthPassword) {
                    
                    if (![_userCredentialAuthManager clientID]) {
                        _userCredentialAuthManager = [AFOAuth2Manager  managerWithBaseURL:[NSURL URLWithString:_currentOauthEndPointUrl] clientID:_currentClientID secret:_currentClientID];
                    }
                    
                    [_userCredentialAuthManager setUseHTTPBasicAuthentication:NO];
                    
                    canTryRefreh = YES;
                }
            }
                break;
            case OAuthModeClientCredential:
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
            
            if (_currentOauthUserCredential && ![_currentOauthUserCredential isExpired] && ![[_manager requestSerializer] hasAuthorizationHeaderField]) {
                
                [_httpSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
                [_jsonSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
                [_userCredentialAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthUserCredential];
            }
            else {
                [self refreshToken];
            }
        }
        
        _userCredentialAuthManager.responseSerializer = [AFJSONResponseSerializerWithData serializer];
    }
    
    return _userCredentialAuthManager;
}

- (BOOL) resetToken {
    if (_currentOauthClientCredential) {
        _currentOauthClientCredential = nil;
        [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceClientCredentialIdentifier];
        return [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceUserCredentialIdentifier];
    }
    if (_currentOauthUserCredential) {
        _currentOauthUserCredential = nil;
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
    
    __block __typeof__(_currentOauthUserCredential) __weak wCurrentOauthCredential = _currentOauthUserCredential;
    
    __block __typeof__(_httpSerializer) __weak wHttpSerializer = _httpSerializer;
    __block __typeof__(_jsonSerializer) __weak wJsonSerializer = _jsonSerializer;
    __block __typeof__(_manager) __weak wManager = _manager;
    __block __typeof__(_userCredentialAuthManager) __weak wUserCredentialAuthManager = _userCredentialAuthManager;
    
    if (_currentOauthUserCredential) {
        
        [_clientCredentialAuthManager authenticateUsingOAuthWithURLString:[_currentOauthEndPointUrl stringByAppendingString:_currentOauthEndPointAction] refreshToken:[_currentOauthUserCredential refreshToken] success:^(AFOAuthCredential * _Nonnull credential) {
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
    
    __block __typeof__(_httpSerializer) __weak wHttpSerializer = _httpSerializer;
    __block __typeof__(_jsonSerializer) __weak wJsonSerializer = _jsonSerializer;
    __block __typeof__(_manager) __weak wManager = _manager;
    __block __typeof__(_userCredentialAuthManager) __weak wUserCredentialAuthManager = _userCredentialAuthManager;
    
    
    [_userCredentialAuthManager authenticateUsingOAuthWithURLString:[_currentOauthEndPointUrl stringByAppendingString:_currentOauthEndPointAction] username:email password:password scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
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
    
    __block __typeof__(_httpSerializer) __weak wHttpSerializer = _httpSerializer;
    __block __typeof__(_jsonSerializer) __weak wJsonSerializer = _jsonSerializer;
    __block __typeof__(_manager) __weak wManager = _manager;
    __block __typeof__(_userCredentialAuthManager) __weak wUserCredentialAuthManager = _userCredentialAuthManager;
    
    [_userCredentialAuthManager authenticateUsingFacebookOAuthWithURLString:[_currentOauthEndPointUrl stringByAppendingString:_currentOauthEndPointAction] facebookId:facebookId facebookToken:facebookToken scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
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

- (void) refreshTokenForClientCredential {
    [self refreshTokenForClientCredentialWithBlockSuccess:nil failure:nil];
}


- (void) refreshTokenForClientCredentialWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                                 failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    __block __typeof__(_currentOauthClientCredential) __weak wCurrentOauthCredential = _currentOauthClientCredential;
    
    __block __typeof__(_httpSerializer) __weak wHttpSerializer = _httpSerializer;
    __block __typeof__(_jsonSerializer) __weak wJsonSerializer = _jsonSerializer;
    __block __typeof__(_clientCredentialAuthManager) __weak wAuthManager = _clientCredentialAuthManager;
    __block __typeof__(_manager) __weak wManager = _manager;
    
    
    if (_currentOauthClientCredential) {
        
        [_clientCredentialAuthManager authenticateUsingOAuthWithURLString:[_currentOauthEndPointUrl stringByAppendingString:_currentOauthEndPointAction] refreshToken:[_currentOauthClientCredential refreshToken] success:^(AFOAuthCredential * _Nonnull credential) {
            wCurrentOauthCredential = credential;
            
            [AFOAuthCredential storeCredential:wCurrentOauthCredential withIdentifier:PNObjectServiceUserCredentialIdentifier];
            
            [wHttpSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
            [wJsonSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
            [wAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
            [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
            
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
                [_clientCredentialAuthManager authenticateUsingOAuthWithURLString:[_currentOauthEndPointUrl stringByAppendingString:_currentOauthEndPointAction] scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
                    wCurrentOauthCredential = credential;
                    
                    [AFOAuthCredential storeCredential:wCurrentOauthCredential withIdentifier:PNObjectServiceUserCredentialIdentifier];
                    
                    [wHttpSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wJsonSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wAuthManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    [wManager.requestSerializer setAuthorizationHeaderFieldWithCredential:wCurrentOauthCredential];
                    
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
            case OAuthModePassword:
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

- (void) setClientID:(NSString * _Nonnull) clientID clientSecret:(NSString* _Nonnull) clientSecret oAuthEndpointAction:(NSString* _Nonnull) oAuthEndpointAction forEnv:(NSString *) environment {
    
    if ([_configuration objectForKey:environment]) {
        
        NSMutableDictionary *currentConfigurationDict = [[NSMutableDictionary alloc] initWithDictionary:[_configuration objectForKey:environment]];
        [currentConfigurationDict setObject:clientID forKey:Client_ID];
        [currentConfigurationDict setObject:clientSecret forKey:Client_Secret];
        [currentConfigurationDict setObject:oAuthEndpointAction forKey:OAuthEndpointAction];
        
        [_configuration setObject:currentConfigurationDict forKey:environment];
        
        if (_currentEnv == environment) {
            [self setEnvironment:environment];
        }
    }
}

- (void) setOauthClientID:(NSString * _Nonnull) oauthClientID oauthClientSecret:(NSString* _Nonnull) oauthClientSecret oAuthEndpointAction:(NSString* _Nonnull) oAuthEndpointAction forEnv:(NSString *) environment {
    
    if ([_configuration objectForKey:environment]) {
        
        NSMutableDictionary *currentConfigurationDict = [[NSMutableDictionary alloc] initWithDictionary:[_configuration objectForKey:environment]];
        [currentConfigurationDict setObject:oauthClientID forKey:OAuthClient_ID];
        [currentConfigurationDict setObject:oauthClientSecret forKey:OAuthClient_Secret];
        [currentConfigurationDict setObject:oAuthEndpointAction forKey:OAuthEndpointAction];
        
        [_configuration setObject:currentConfigurationDict forKey:environment];
        
        if (_currentEnv == environment) {
            [self setEnvironment:environment];
        }
    }
}

- (void) setOauthUserName:(NSString * _Nonnull)oauthUserName oauthPassword:(NSString* _Nonnull) oauthPassword oAuthEndpointAction:(NSString* _Nonnull) oAuthEndpointAction forEnv:(NSString *) environment {
    
    if ([_configuration objectForKey:environment]) {
        
        NSMutableDictionary *currentConfigurationDict = [[NSMutableDictionary alloc] initWithDictionary:[_configuration objectForKey:environment]];
        [currentConfigurationDict setObject:oauthUserName forKey:Client_Username];
        [currentConfigurationDict setObject:oauthPassword forKey:Client_Password];
        [currentConfigurationDict setObject:oAuthEndpointAction forKey:OAuthEndpointAction];
        
        [_configuration setObject:currentConfigurationDict forKey:environment];
        
        if (_currentEnv == environment) {
            [self setEnvironment:environment];
        }
    }
}

@end
