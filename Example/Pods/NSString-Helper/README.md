# NSString-Helper

[![CI Status](http://img.shields.io/travis/Giuseppe Nucifora/NSString-Helper.svg?style=flat)](https://travis-ci.org/Giuseppe Nucifora/NSString-Helper)
[![Version](https://img.shields.io/cocoapods/v/NSString-Helper.svg?style=flat)](http://cocoapods.org/pods/NSString-Helper)
[![License](https://img.shields.io/cocoapods/l/NSString-Helper.svg?style=flat)](http://cocoapods.org/pods/NSString-Helper)
[![Platform](https://img.shields.io/cocoapods/p/NSString-Helper.svg?style=flat)](http://cocoapods.org/pods/NSString-Helper)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

NSString-Helper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NSString-Helper'
```
##Usage

```ruby

#import <NSString-Helper/NSString+Helper.h>

NSString *str = @"testCode";

NSLog(@"%@",[NSNumber numberWithBool:[str isNumeric]]);

NSLog(@"%@",[NSNumber numberWithBool:[str isValidPhoneNumber]]);

NSLog(@"%@",[NSNumber numberWithBool:[str isValidEmail]]);

NSLog(@"%@",[NSNumber numberWithBool:[str isValidUrl]]);

NSLog(@"%@",[NSNumber numberWithBool:[str isValidTaxCode]]);


```

## Author

Giuseppe Nucifora, me@giuseppenucifora.com

## License

NSString-Helper is available under the MIT license. See the LICENSE file for more info.
