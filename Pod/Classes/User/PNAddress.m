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
    return @"Address";
}

+ (NSDictionary *) objcetMapping {
    NSDictionary *mapping = @{@"country":@"country",
                              @"province":@"province",
                              @"city":@"city",
                              @"street":@"street",
                              @"number":@"number",
                              @"zip":@"zip",
                              @"location":@{@"key":@"location",@"type":@"PNLocation"},
                              };
    return mapping;
}

@end
