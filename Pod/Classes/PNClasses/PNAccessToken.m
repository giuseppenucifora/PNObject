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

static PNAccessToken *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (instancetype) currentAccessToken {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		isFirstAccess = NO;
		
		SINGLETON = [[super allocWithZone:NULL] initForCurrentAccessTokenWithJSON:nil];
	});
	
	return SINGLETON;
}

+ (instancetype _Nonnull) currentAccessTokenWithJSON:(NSDictionary *)JSON {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		isFirstAccess = NO;
		
		SINGLETON = [[super allocWithZone:NULL] initForCurrentAccessTokenWithJSON:JSON];
	});
	
	return SINGLETON;
}


- (instancetype) initForCurrentAccessTokenWithJSON:(NSDictionary *)JSON {
	if(SINGLETON){
		return SINGLETON;
	}
	if (isFirstAccess) {
		[self doesNotRecognizeSelector:_cmd];
	}
	NSDictionary *savedAccessToken;
	
	if (JSON) {
		savedAccessToken =  JSON;
	}
	else {
		savedAccessToken = [[PNObjectModel sharedInstance] fetchObjectsWithClass:[self class]];
	}
	
	if (savedAccessToken) {
		self = [super initWithJSON:savedAccessToken];
	}
	else {
		self = [super init];
	}
	
	if (self) {
		if (_tokenTypeString) {
			((void (^)())@{
						   @"beaer" : ^{
				_tokenType = TokenTypeBearer;
			},
						   @"basic" : ^{
				_tokenType = TokenTypeBasic;
			}
						   }[_tokenTypeString] ?: ^{
							   
						   })();
		}
		
		if (_expiresIn) {
			_expirationDate = [[NSDate date] dateByAddingHours:[_expiresIn integerValue]];
		}
	}
	
	return self;
}


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
	return [[self class] currentAccessTokenWithJSON:JSON];
}

+ (NSString *)objectClassName {
	return  @"AccessToken";
}

+ (BOOL) singleInstance {
	return YES;
}

#pragma mark -



@end
