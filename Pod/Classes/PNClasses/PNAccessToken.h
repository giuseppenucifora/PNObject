//
//  PNAccessToken.h
//  Pods
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import "PNObject.h"

@interface PNAccessToken : PNObject

typedef NS_ENUM(NSInteger, TokenType) {
	TokenTypeBasic = 1,
	TokenTypeBearer = 2
};

/**
 *  gets singleton object of current user session.
 *
 *  @return singleton
 */
+ (instancetype _Nonnull) currentAccessToken;


/**
 *  gets singleton object of current user session.
 *
 *  @return singleton
 */
+ (instancetype _Nonnull) currentAccessTokenWithJSON:(NSDictionary *)JSON;

///--------------------------------------
#pragma mark - PNAccessToken Properties
///--------------------------------------


/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString *accessToken;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSDate *expirationDate;

@property (nonatomic, strong, nullable) NSNumber *expiresIn;
/**
 *  <#Description#>
 */
@property (nonatomic) TokenType tokenType;

@property (nonatomic, strong, nullable) NSString *tokenTypeString;

@property (nonatomic, strong, nullable) NSString *scope;

@property (nonatomic, strong, nullable) NSString *refreshToken;


@end
