//
//  PNAccessToken.m
//  Pods
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import "PNAccessToken.h"

@interface PNAccessToken() <PNObjectSubclassing>

@end

@implementation PNAccessToken

#pragma mark PNObjectSubclassing Protocol

+ (NSDictionary *)objcetMapping {
	
	NSDictionary *mapping = @{
							  @"accessToken":@"accessToken",
							  @"expirationDate":@"expirationDate",
							  @"tokenType":@"tokenType",
							  };
	return mapping;
}

+ (NSString *)objectClassName {
	return  @"AccessToken";
}

+ (BOOL) singleInstance {
	return YES;
}

#pragma mark -






@end
