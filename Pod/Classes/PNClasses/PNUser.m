//
//  PNUser.m
//  Pods
//
//  Created by Giuseppe Nucifora on 15/01/16.
//
//

#import "PNUser.h"
#import "NSString+Helper.h"
#import "PNObjectConstants.h"
#import "PNObject+Protected.h"


@interface PNUser() <PNObjectSubclassing>

@end

@implementation PNUser

@synthesize password = _password;

static PNUser *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (instancetype) currentUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        
        SINGLETON = [[super allocWithZone:NULL] initForCurrentUser];
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

- (instancetype)copy
{
    return [[PNUser alloc] init];
}

- (instancetype)mutableCopy
{
    return [[PNUser alloc] init];
}

- (instancetype) initForCurrentUser
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    NSDictionary *savedUser = [[PNObjectModel sharedInstance] fetchObjectsWithClass:[self class]];
    
    if (savedUser) {
        self = [super initWithJSON:savedUser];
    }
    else {
        self = [super init];
    }
    
    if (self) {
    }
    return self;
}

- (void) setEmail:(NSString *)email {
    if ([email isValidEmail]) {
        _email = email;
    }
    else {
        NSLogDebug(@"insertedEmail is not valid.");
    }
}

- (void) setPassword:(NSString *)password {
    if ([self isValidPassword:password]) {
        _password = password;
    }
    else {
        NSLogDebug(@"Inserted Passord is not valid.Lenght must be >= %ld",(long)[[PNObjectConfig sharedInstance] minPasswordLenght]);
    }
}

- (BOOL) isValidPassword:(NSString* _Nonnull) password {
    if ([password length] >= [[PNObjectConfig sharedInstance] minPasswordLenght]) {
        return YES;
    }
    return NO;
}

- (void)logout {
    [self autoRemoveLocally];
    [self resetObject];
}

- (BOOL) isValidUser {
    if(self.username && self.password && [self isValidPassword:[self password]]){
        return YES;
    }
    
    return NO;
}

#pragma mark PNObjectSubclassing Protocol 

+ (NSDictionary *)objcetMapping {
    
    NSDictionary *mapping = @{
                              @"userId":@"id",
                              @"firstName":@"firstName",
                              @"lastName":@"lastName",
                              @"profileImage":@"profileImage",
                              @"sex":@"sex",
                              @"birthDate":@"birthDate",
                              @"phone":@"phone",
                              @"password":@"password",
                              @"hasAcceptedPrivacy":@"hasAcceptedPrivacy",
                              @"hasAcceptedNewsletter":@"hasAcceptedNewsletter",
                              @"hasVerifiedEmail":@"hasVerifiedEmail",
                              @"emailVerifiedDate":@"emailVerifiedDate",
                              @"email":@"email",
                              @"username":@"username",
                              @"publicProfile":@"public_profile",
                              @"loginCount":@"login_count",
                              @"facebookId":@"facebookId",
                              @"facebookAccessToken":@"facebookAccessToken",
                              };
    return mapping;
}

+ (NSString *)objectClassName {
    return  @"User";
}

+ (NSString *) objectEndPoint {
    return @"User";
}

+ (BOOL) singleInstance {
    return YES;
}

#pragma mark -


@end
