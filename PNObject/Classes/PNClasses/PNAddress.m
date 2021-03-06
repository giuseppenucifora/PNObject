//
//  PNAddress.m
//  Pods
//
//  Created by Giuseppe Nucifora on 13/01/16.
//
//

#import "PNAddress.h"

@implementation PNAddress

+ (NSString *) objectClassName {
    return @"PNAddress";
}

+ (NSString *)objectEndPoint {
    return @"PNAddress";
}

+ (NSDictionary *) objcetMapping {
    NSDictionary *mapping = @{@"country":@"country",
                              @"province":@"province",
                              @"city":@"city",
                              @"street":@"street",
                              @"number":@"number",
                              @"zip":@"zip",
                              @"location":@{PNObjectMappingKey:@"location",PNObjectMappingType:@"PNLocation"},
                              };
    return mapping;
}

+ (BOOL)singleInstance {
    return NO;
}

@end
