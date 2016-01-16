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


@interface PNUser() <PNObjectSubclassing>

@end

@implementation PNUser

static PNUser *SINGLETON = nil;

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

+ (instancetype) currentUser {
    return [self sharedInstance];
}

#pragma mark - Life Cycle

+ (instancetype) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (instancetype)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (instancetype)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (instancetype)copy
{
    return [[PNUser alloc] init];
}

- (instancetype)mutableCopy
{
    return [[PNUser alloc] init];
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
        [self setSubClassDelegate:self];
    }
    return self;
}

- (void) setEmail:(NSString *)email {
    if ([email isValidEmail]) {
        _email = email;
    }
    NSLogDebug(@"insertedEmail is not valid.");
}

- (void) setPassword:(NSString *)password {
    if ([password length] >= [[PNObjectConfig sharedInstance] minPasswordLenght]) {
        self.password = password;
    }
    NSLogDebug(@"Inserted Passord is not valid.Lenght must be >= %ld",(long)[[PNObjectConfig sharedInstance] minPasswordLenght]);
}


- (BOOL) isValidPassword:(NSString* _Nonnull) password {
    if ([password length] >= [[PNObjectConfig sharedInstance] minPasswordLenght]) {
        return YES;
    }
    return NO;
}


- (NSString *) password {
    return @"password is not readble";
}

#pragma mark PNObjectSubclassing Protocol 

+ (NSDictionary *)objcetMapping {
    
    NSDictionary *mapping = @{@"userId":@"id",
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
                              @"createdAt":@"created_at",
                              @"facebookId":@"facebookId",
                              @"facebookAccessToken":@"facebookAccessToken",
                              @"address":@{@"key":@"address",@"type":@"PNAddress"}
                              };
    return mapping;
}

+ (NSString *)objectClassName {
    return  @"User";
}

+ (BOOL) singleInstance {
    return YES;
}

#pragma mark -


@end
