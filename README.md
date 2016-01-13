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

##Usage Example

PNObject Subclass

```ruby
Customer.h

#import <PNObject/PNObject.h>

@interface Customer : PNObject <PNObjectSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDate *birthDate;
@property (nonatomic, strong) PNAddress *address;

@end
```

```ruby
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
@"address":@{@"key":@"address",@"type":@"PNAddress"},
};
return mapping;
}
```


## Author

Giuseppe Nucifora, me@giuseppenucifora.com

## License

PNObject is available under the MIT license. See the LICENSE file for more info.
