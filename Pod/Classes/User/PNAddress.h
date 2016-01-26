//
//  PNAddress.h
//  Pods
//
//  Created by Giuseppe Nucifora on 13/01/16.
//
//

#import "PNObject.h"
#import "PNLocation.h"

@interface PNAddress : PNObject <PNObjectSubclassing>

@property (nonatomic, strong) NSString * _Nullable country;
@property (nonatomic, strong) NSString * _Nullable province;
@property (nonatomic, strong) NSString * _Nullable city;
@property (nonatomic, strong) NSString * _Nullable street;
@property (nonatomic, strong) NSNumber * _Nullable number;
@property (nonatomic, strong) NSString * _Nullable zip;
@property (nonatomic, strong) NSString * _Nullable istruction;
@property (nonatomic, strong) PNLocation * _Nullable location;

@end
