//
//  PNAccessToken.m
//  Pods
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import "PNAccessToken.h"
#import <NSDate_Utils/NSDate+NSDate_Util.h>

@interface PNAccessToken() <PNObjectSubclassing>

@end

@implementation PNAccessToken

#pragma mark PNObjectSubclassing Protocol

+ (NSDictionary *)objcetMapping {
	
	NSDictionary *mapping = @{
							  @"accessToken":@"access_token",
							  @"expiresIn":@"expires_in",
							  @"tokenTypeString":@"token_type",
							  @"tokenType":@"scope",
							  @"refreshToken":@"refresh_token",
							  };
	return mapping;
}

- (instancetype) initWithJSON:(NSDictionary *)JSON {
	self = [super initWithJSON:JSON];
	
	if (self) {
		((void (^)())@{
					   @"beaer" : ^{
			_tokenType = TokenTypeBearer;
		},
					   @"basic" : ^{
			_tokenType = TokenTypeBasic;
		}
					   }[_tokenTypeString] ?: ^{
						   
					   })();
		
		_expirationDate = [[NSDate date] dateByAddingHours:[_expiresIn integerValue]];
	}
	return self;
}

+ (NSString *)objectClassName {
	return  @"AccessToken";
}

+ (BOOL) singleInstance {
	return YES;
}

#pragma mark -



@end
