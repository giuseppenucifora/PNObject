//
//  PNAddress.h
//  Pods
//
//  Created by Giuseppe Nucifora on 13/01/16.
//
//

#import <PNObject/PNObject.h>
#import "PNLocation.h"

@interface PNAddress : PNObject <PNObjectSubclassing>

@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *istruction;
@property (nonatomic, strong) PNLocation *location;

@end
