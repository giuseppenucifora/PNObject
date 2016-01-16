//
//  PNLocation.m
//  Pods
//
//  Created by Giuseppe Nucifora on 13/01/16.
//
//

#import "PNLocation.h"

@implementation PNLocation

+ (NSString *) objectClassName {
    return @"Location";
}


+ (NSDictionary *) objcetMapping {
    NSDictionary *mapping = @{@"lat":@"lat",
                              @"lng":@"lng",
                              };
    return mapping;
}

+ (BOOL)singleInstance {
    return NO;
}

@end
