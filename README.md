# PNObject

[![CI Status](http://img.shields.io/travis/Giuseppe Nucifora/PNObject.svg?style=flat)](https://travis-ci.org/Giuseppe Nucifora/PNObject)
[![Version](https://img.shields.io/cocoapods/v/PNObject.svg?style=flat)](http://cocoapods.org/pods/PNObject)
[![License](https://img.shields.io/cocoapods/l/PNObject.svg?style=flat)](http://cocoapods.org/pods/PNObject)
[![Platform](https://img.shields.io/cocoapods/p/PNObject.svg?style=flat)](http://cocoapods.org/pods/PNObject)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PNObject is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PNObject"
```

New in version 1.3.0
---
                                                        
- Can Separate Base url with endpoint api path during configuration
- Access to separate base url, endpoint path or complete endpoint url


Configure PNObject endpoint client ID, client secret and OAuthModePassword with separate base url and api path
---

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [PNObjectConfig initSharedInstanceForEnvironments:@{EnvironmentDevelopment : @{BaseUrl:@"http://pnobject.local/",EndpointPath:@"api/v1/"},
                                                        EnvironmentStage : @{BaseUrl:@"http://pnobject.stage.it/",EndpointPath:@"api/v1/"},
                                                        EnvironmentProduction : @{BaseUrl:@"http://pnobject.prod.it/",EndpointPath:@"api/v1/"},
                                                        } userSubclass:[PNUser class]];
    
    [[PNObjectConfig sharedInstance] setClientID:@"xxxxxxxxx" clientSecret:@"xxxxxxxxxxxx" forEnv:EnvironmentStage];
    [[PNObjectConfig sharedInstance] setClientID:@"xxxxxxxxx" clientSecret:@"xxxxxxxxxxxx" forEnv:EnvironmentProduction];
        
    
    
    [[PNObjectConfig sharedInstance] setOauthUserName:@"admin" oauthPassword:@"admin" forEnv:EnvironmentStage];
   
    [[PNObjectConfig sharedInstance] setEnvironment:EnvironmentStage];
    
    
}
```

Get BaseUrl, endPointPath and endPointUrl
---
```
    NSLogDebug(@"%@",[[PNObjectConfig sharedInstance] baseUrl]);
    NSLogDebug(@"%@",[[PNObjectConfig sharedInstance] endPointPath]);
    NSLogDebug(@"%@",[[PNObjectConfig sharedInstance] endPointUrl]);
```

###
Configure PNObject endpoint client ID, client secret and OAuthModePassword
---

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

[PNObjectConfig initSharedInstanceForEnvironments:@{EnvironmentDevelopment : @"http://pnobject.local/api/v1/",
                                                        EnvironmentStage : @"http://pnobject.stage.it/api/v1/",
                                                        EnvironmentProduction : @"http://pnobject.prod.it/api/v1/"
                                                        } userSubclass:[PNUser class]];
    
    [[PNObjectConfig sharedInstance] setClientID:@"xxxxxxxxx" clientSecret:@"xxxxxxxxxxxx" forEnv:EnvironmentStage];
    [[PNObjectConfig sharedInstance] setClientID:@"xxxxxxxxx" clientSecret:@"xxxxxxxxxxxx" forEnv:EnvironmentProduction];
        
    
    
    [[PNObjectConfig sharedInstance] setOauthUserName:@"admin" oauthPassword:@"admin" forEnv:EnvironmentStage];
   
    [[PNObjectConfig sharedInstance] setEnvironment:EnvironmentStage];
}
```
###
Configure PNObject endpoint client ID, client secret and OAuthModeClientCredential
---


```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

[PNObjectConfig initSharedInstanceForEnvironments:@{EnvironmentDevelopment : @"http://pnobject.local/api/v1/",
                                                        EnvironmentStage : @"http://pnobject.stage.it/api/v1/",
                                                        EnvironmentProduction : @"http://pnobject.prod.it/api/v1/"
                                                        } userSubclass:[PNUser class]];
    
    [[PNObjectConfig sharedInstance] setClientID:@"xxxxxxxxx" clientSecret:@"xxxxxxxxxxxx" forEnv:EnvironmentStage];
    [[PNObjectConfig sharedInstance] setClientID:@"xxxxxxxxx" clientSecret:@"xxxxxxxxxxxx" forEnv:EnvironmentProduction];
        
    [[PNObjectConfig sharedInstance] setEnvironment:EnvironmentStage];
}
```
###
Configure PNObject endpoint and using custom PNUser object
---

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

[PNObjectConfig initSharedInstanceForEnvironments:@{EnvironmentDevelopment : @"http://pnobject.local/api/v1/",
                                                        EnvironmentStage : @"http://pnobject.stage.it/api/v1/",
                                                        EnvironmentProduction : @"http://pnobject.prod.it/api/v1/"
                                                        } userSubclass:[PNUser class]];
    
    [[PNObjectConfig sharedInstance] setClientID:@"xxxxxxxxx" clientSecret:@"xxxxxxxxxxxx" forEnv:EnvironmentStage];
    [[PNObjectConfig sharedInstance] setClientID:@"xxxxxxxxx" clientSecret:@"xxxxxxxxxxxx" forEnv:EnvironmentProduction];
        
    [[PNObjectConfig sharedInstance] setEnvironment:EnvironmentStage];
}
```

###
User.h
---

```


#import <PNObject/PNUser.h>

@interface User : PNUser

@end
```

###
User.m
---
```
#import "User.h"
#import "PNObject+Protected.h"
#import "PNObject+PNObjectConnection.h"
#import <NSDate_Utils/NSDate+NSDate_Util.h>

@interface User () <PNObjectSubclassing>

@end


@implementation User

+ (NSDictionary *)objcetMapping {
    
    NSMutableDictionary *userMapping = [[NSMutableDictionary alloc] initWithDictionary:[[PNUser class] objcetMapping]];
    
    return userMapping;
}

+ (BOOL) singleInstance {
    return [[self class] singleInstance];
}

+ (NSString * _Nonnull) objectEndPoint {
    return @"User";
}


+ (NSString * _Nonnull ) objectClassName {
    return @"User";
}

###
Custom Reset Password

+ (void) resetPasswordForEmail:(NSString * _Nonnull) userEmail
                      Progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                       Success:(nullable void (^)(NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    [self POSTWithEndpointAction:@"password-reset-request"
                      parameters:[self resetPasswordFormObject:userEmail]
                        progress:uploadProgress
                         success:^(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject) {
                             if (success) {
                                 success(responseObject);
                             }
                         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                             if (failure) {
                                 failure(error);
                             }
                         }];
}

+ (NSDictionary * _Nonnull) resetPasswordFormObject:(NSString *) email {
    
    NSMutableDictionary *resetPasswordDictionary = [[NSMutableDictionary alloc] init];
    [resetPasswordDictionary setObject:email forKey:@"email"];
    
    return resetPasswordDictionary;
}

```




## Author

Giuseppe Nucifora, me@giuseppenucifora.com

## License

PNObject is available under the MIT license. See the LICENSE file for more info.
