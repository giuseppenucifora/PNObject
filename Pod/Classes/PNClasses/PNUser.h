//
//  PNUser.h
//  Pods
//
//  Created by Giuseppe Nucifora on 15/01/16.
//
//

#import "PNObject.h"


@interface PNUser : PNObject

/**
 *  gets singleton object of current user session.
 *
 *  @return singleton
 */
+ (instancetype _Nonnull) currentUser;

- (BOOL) isValidPassword:(NSString* _Nonnull) password;

//- (void) setPassword:(NSString * _Nonnull)password inBackGroundWithBlock:(nullable void (^)(BOOL saveStatus, id responseObject, NSError * error)) responseBlock;

///--------------------------------------
#pragma mark - PNLocation Properties
///--------------------------------------

/**
 *  <#Description#>
 */
@property (strong, nonatomic, nonnull) NSString * userId;
/**
 *  <#Description#>
 */
@property (strong, nonatomic, nonnull) NSString * firstName;
/**
 *  <#Description#>
 */
@property (strong, nonatomic, nonnull) NSString * lastName;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) UIImage * profileImage;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * sex;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSDate * birthDate;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * phone;
/**
 *  <#Description#>
 */
@property (nonatomic) BOOL hasAcceptedPrivacy;
/**
 *  <#Description#>
 */
@property (nonatomic) BOOL hasAcceptedNewsletter;
/**
 *  <#Description#>
 */
@property (nonatomic) BOOL hasVerifiedEmail;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSDate * emailVerifiedDate;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull) NSString * email;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull) NSString * username;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull) NSString * password;
/**
 *  <#Description#>
 */
@property (nonatomic) BOOL publicProfile;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull) NSNumber * loginCount;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * facebookId;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * facebookAccessToken;


@end
