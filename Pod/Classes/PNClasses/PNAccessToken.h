//
//  PNAccessToken.h
//  Pods
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import <PNObject/PNObject.h>

@interface PNAccessToken : PNObject

typedef NS_ENUM(NSInteger, TokenType) {
	TokenTypeBasic = 1,
	TokenTypeBearer = 2
};
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString *accessToken;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSDate *expirationDate;
/**
 *  <#Description#>
 */
@property (nonatomic) TokenType tokenType;

@end
