# PNObject

[![CI Status](http://img.shields.io/travis/Giuseppe Nucifora/PNObject.svg?style=flat)](https://travis-ci.org/Giuseppe Nucifora/PNObject)
[![Version](https://img.shields.io/cocoapods/v/PNObject.svg?style=flat)](http://cocoapods.org/pods/PNObject)
[![License](https://img.shields.io/cocoapods/l/PNObject.svg?style=flat)](http://cocoapods.org/pods/PNObject)
[![Platform](https://img.shields.io/cocoapods/p/PNObject.svg?style=flat)](http://cocoapods.org/pods/PNObject)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PNObject is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PNObject"
```

#Usage Example

##PNObject Subclass

```
//Customer.h


#import <PNObject/PNObject.h>

@interface Customer : PNObject <PNObjectSubclassing>

    @property (nonatomic, strong) NSString *name;
    @property (nonatomic, strong) NSString *lastName;
    @property (nonatomic, strong) NSString *email;
    @property (nonatomic, strong) NSDate *birthDate;
    @property (nonatomic, strong) PNAddress *address;

@end
```

```
#import "Customer.h"

@implementation Customer

+ (NSString *) objectClassName {
    return @"Customer";
}


+ (NSDictionary *) objcetMapping {
    
    NSDictionary *mapping = @{
        @"name":@"first_name",
        @"surname":@"last_name",
        @"email":@"email",
        @"birthDate":@"birth_date",
        @"address":@{
            @"key":@"address",
            @"type":@"PNAddress"
        },
    };
    
    return mapping;
}
```

##Configure endpoints


```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PNObjectConfig initSharedInstanceForEnvironments:
        @{
            EnvironmentDevelopment : @"http://domain.local/api/v1/",
            EnvironmentStage : @"https://domain.stage/api/v1/",
            EnvironmentProduction : @"http://domain.prod/api/v1/"
        } 
        userSubclass:[PNUser class] 
        withOauth:YES
        ];
        
        ...
}
```
###Set custom header
```
    [[PNObjectConfig sharedInstance] setHTTPHeaderValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
```

###Set clients ID e client Secret for environments
```
    [[PNObjectConfig sharedInstance] setClientID:@"XXXXXXXX" clientSecret:@"XXXXXXX" forEnv:EnvironmentProduction];
    [[PNObjectConfig sharedInstance] setClientID:@"XXXXXXXX" clientSecret:@"XXXXXXX" forEnv:EnvironmentStage];
    [[PNObjectConfig sharedInstance] setClientID:@"XXXXXXXX" clientSecret:@"XXXXXXX" forEnv:EnvironmentDevelopment];
```

###Enable specific Environment
```
#ifdef DEBUG
    [[PNObjectConfig sharedInstance] setEnvironment:EnvironmentStage];
#endif
```


## Author

Giuseppe Nucifora, me@giuseppenucifora.com

## License

PNObject is available under the MIT license. See the LICENSE file for more info.
