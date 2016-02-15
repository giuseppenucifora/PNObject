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


NSString * const PNObjectLocalNotificationRefreshTokenClientCredentialSuccess = @"PNObjectLocalNotificationRefreshTokenClientCredentialSuccess";
NSString * const PNObjectLocalNotificationRefreshTokenClientCredentialFail = @"PNObjectLocalNotificationRefreshTokenClientCredentialFail";


NSString * const PNObjectLocalNotificationRefreshTokenUserSuccess = @"PNObjectLocalNotificationRefreshTokenUserSuccess";
NSString * const PNObjectLocalNotificationRefreshTokenUserFail = @"PNObjectLocalNotificationRefreshTokenUserFail";


NSInteger const minPassLenght = 4;

NSString * const PNObjectEncryptionKey = @"PNObjectConfigEncryptionKey";

NSString * const PNObjectServiceCredentialIdentifier = @"PNObjectServiceCredentialIdentifier";

NSString* const EnvironmentProduction = @"PNObjectConfigEnvProduction";
NSString* const EnvironmentStage = @"PNObjectConfigEnvStage";
NSString* const EnvironmentDevelopment = @"PNObjectConfigDevelopment";

NSString*  const BaseUrl = @"base_url";
NSString*  const Client_ID = @"client_id";
NSString*  const Client_Secret = @"client_secret";

@interface PNObjectConfig()

@property (nonatomic) BOOL oauthEnabled;

@property (nonatomic, strong) NSMutableDictionary *configuration;
@property (nonatomic, strong) NSMutableDictionary *headerFields;
@property (nonatomic, strong) NSString *currentEnv;
@property (nonatomic, strong) NSString *currentEndPointBaseUrl;
@property (nonatomic, strong) NSString *currentOAuthClientID;
@property (nonatomic, strong) NSString *currentOAuthClientSecret;
//@property (nonatomic, strong) NSMutableDictionary *environments;

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

            NSURL * endpointUrl = [NSURL URLWithString:[endpointUrlsForEnvironments objectForKey:key]];
            if (endpointUrl) {
                [SINGLETON.configuration setValue:[NSDictionary dictionaryWithObjectsAndKeys:[endpointUrl absoluteString],BaseUrl, nil] forKey:key];
            }

        }
        NSAssert([SINGLETON.configuration objectForKey:EnvironmentProduction], @"EnvironmentProduction must be valid endpoint url");
        [SINGLETON setEnvironment:EnvironmentProduction];



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
            [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceCredentialIdentifier];
        }

        _configuration = [[NSMutableDictionary alloc] init];
        _minPasswordLenght = minPassLenght;

        _headerFields = [[NSMutableDictionary alloc] init];

        if ([[NSUserDefaults standardUserDefaults] objectForKey:PNObjectEncryptionKey]) {
            _encrypKey = [[NSUserDefaults standardUserDefaults] objectForKey:PNObjectEncryptionKey];
        }
        else {
            _encrypKey = [[NSProcessInfo processInfo] globallyUniqueString];

            [[NSUserDefaults standardUserDefaults] setObject:_encrypKey forKey:PNObjectEncryptionKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

    }
    return self;
}

- (void) setEnvironment:(NSString * _Nonnull) environment {

    _currentEnv = environment;
    _currentEndPointBaseUrl = nil;
    _currentOAuthClientID = nil;
    _currentOAuthClientSecret = nil;

        if ([_configuration objectForKey:environment]) {
            _currentEndPointBaseUrl = [[_configuration objectForKey:_currentEnv] objectForKey:BaseUrl];
            _currentOAuthClientID = [[_configuration objectForKey:_currentEnv] objectForKey:Client_ID];
            _currentOAuthClientSecret = [[_configuration objectForKey:_currentEnv] objectForKey:Client_Secret];
        }

    NSLog(@"%@",[[_configuration objectForKey:_currentEnv] objectForKey:BaseUrl]);

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

    //_currentOauthCredential = [AFOAuthCredential retrieveCredentialWithIdentifier:PNObjectServiceCredentialIdentifier];

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

        if (_currentOauthCredential && ![_currentOauthCredential isExpired]) {
            [[_manager requestSerializer] setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];
        }
        else {
            [self refreshToken];
        }
    }

    _manager.responseSerializer = [AFJSONResponseSerializerWithData serializer];

    return _manager;
}

- (BOOL) resetToken {
    if (_currentOauthCredential) {
        return [AFOAuthCredential deleteCredentialWithIdentifier:PNObjectServiceCredentialIdentifier];
    }
    return NO;
}

- (void) refreshToken {
    if([PNUser currentUser] && [[PNUser currentUser] hasValidEmailAndPasswordData]) {
        [self refreshTokenForUser];
    }
    else {
        [self refreshTokenForClientCredential];
    }
}

- (void) refreshTokenForUser {

    [self refreshTokenForUserWithBlockSuccess:nil failure:nil];
}

- (void) refreshTokenForUserWithBlockSuccess:(nullable void (^)(BOOL refreshSuccess))success
                                     failure:(nullable void (^)(NSError * _Nonnull error))failure {

    if([PNUser currentUser] && [[PNUser currentUser] hasValidEmailAndPasswordData]) {
        [_manager authenticateUsingOAuthWithURLString:[_currentEndPointBaseUrl stringByAppendingString:@"oauth-token"] username:[[PNUser currentUser] email] password:[[[PNUser currentUser] password] password] scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
            _currentOauthCredential = credential;

            [AFOAuthCredential storeCredential:_currentOauthCredential withIdentifier:PNObjectServiceCredentialIdentifier];
            [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];

            if (success) {
                success(YES);
            }
        } failure:^(NSError * _Nonnull error) {

            [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenUserFail object:error];
            if (failure) {
                failure(error);
            }
        }];
    }
    else {
        if (failure) {

            NSError *error = [NSError errorWithDomain:@"" code:kHTTPStatusCodeBadRequest userInfo:nil];
            failure(error);
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
    if (![PNUser isValidPassword:password]) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:NSLocalizedString(@"Password is not valid", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
            failure(error);
            return;
        }
    }
    [_manager authenticateUsingOAuthWithURLString:[_currentEndPointBaseUrl stringByAppendingString:@"oauth-token"] username:email password:password scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
        _currentOauthCredential = credential;

        [AFOAuthCredential storeCredential:_currentOauthCredential withIdentifier:PNObjectServiceCredentialIdentifier];
        [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];

        if (success) {
            success(YES);
        }
    } failure:^(NSError * _Nonnull error) {

        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenUserFail object:error];
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

    [_manager authenticateUsingOAuthWithURLString:[_currentEndPointBaseUrl stringByAppendingString:@"oauth-token"] scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
        _currentOauthCredential = credential;

        [AFOAuthCredential storeCredential:_currentOauthCredential withIdentifier:PNObjectServiceCredentialIdentifier];

        [_manager.requestSerializer setAuthorizationHeaderFieldWithCredential:_currentOauthCredential];

        if (success) {
            success(YES);
        }
    } failure:^(NSError * _Nonnull error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationRefreshTokenClientCredentialFail object:error];
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

@end
