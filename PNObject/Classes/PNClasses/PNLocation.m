//
//  PNLocation.m
//  Pods
//  Version 2.7.0
//
//  Created by Giuseppe Nucifora on 13/01/16.
//
//

#import "PNLocation.h"

@implementation PNLocation

+ (NSString *) objectClassName {
    return @"PNLocation";
}

+(NSString *)objectEndPoint {
    return @"PNLocation";
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
