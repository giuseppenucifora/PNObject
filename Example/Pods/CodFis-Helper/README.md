# CodFis-Helper

[![CI Status](http://img.shields.io/travis/Giuseppe Nucifora/CodFis-Helper.svg?style=flat)](https://travis-ci.org/Giuseppe Nucifora/CodFis-Helper)
[![Version](https://img.shields.io/cocoapods/v/CodFis-Helper.svg?style=flat)](http://cocoapods.org/pods/CodFis-Helper)
[![License](https://img.shields.io/cocoapods/l/CodFis-Helper.svg?style=flat)](http://cocoapods.org/pods/CodFis-Helper)
[![Platform](https://img.shields.io/cocoapods/p/CodFis-Helper.svg?style=flat)](http://cocoapods.org/pods/CodFis-Helper)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CodFis-Helper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CodFis-Helper' , :git => 'https://github.com/giuseppenucifora/CodFis-Helper.git'

OR

pod 'CodFis-Helper'
```

##Usage

```ruby
CodFis_Helper *helper = [[CodFis_Helper alloc] init];

[helper setSurname:@"Rossi"];

[helper setName:@"Mario"];

[helper setBirthDay:15];

[helper setBirthMonth:11];

[helper setBirthYear:83];

[helper setGender:Gender_Man];

[helper setState:Italy];

[helper setPlace:@"Milano"];

CodFisResponse *response = [helper calculate];

NSLog(@"%@",[response responseError]);

NSLog(@"%@",[response response]);
```

## Author

Giuseppe Nucifora, me@giuseppenucifora.com

## License

CodFis-Helper is available under the MIT license. See the LICENSE file for more info.
