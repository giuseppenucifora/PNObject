//
//  PNUser.h
//  Pods
//
//  Created by Giuseppe Nucifora on 15/01/16.
//
//

#import "PNObject.h"
#import "PNObjcPassword.h"

@interface PNUser : PNObject

/**
 *  gets singleton object of current user session.
 *
 *  @return singleton
 */
+ (instancetype _Nonnull) currentUser;

/**
 *  reset current user and gets new singleton object of current user session.
 *
 *  @return <#return value description#>
 */
+ (instancetype _Nonnull) resetUser;

/**
 *  <#Description#>
 *
 *  @param password <#password description#>
 *
 *  @return <#return value description#>
 */
+ (BOOL) isValidPassword:(NSString* _Nonnull) password;

/**
 *  <#Description#>
 */
- (void) logout;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (BOOL) hasValidEmailAndPasswordData;

/**
 *  <#Description#>
 *
 *  @param email    <#email description#>
 *  @param password <#password description#>
 *  @param success  <#success description#>
 *  @param failure  <#failure description#>
 */
- (void) loginCurrentUserWithEmail:(NSString * _Nonnull) email
                          password:(NSString * _Nonnull) password
                  withBlockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                           failure:(nullable void (^)(NSError * _Nonnull error))failure;


/**
 *  <#Description#>
 *
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
- (void) registerWithBlockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                          failure:(nullable void (^)(NSError * _Nonnull error))failure;

/**
 *  <#Description#>
 *
 *  @param viewController <#viewController description#>
 *  @param success        <#success description#>
 *  @param failure        <#failure description#>
 */
- (void) socialLoginWithBlockSuccessFromViewController:(UIViewController* _Nonnull) viewController
                                          blockSuccess:(nullable void (^)(PNUser * _Nullable responseObject))success
                                               failure:(nullable void (^)(NSError * _Nonnull error))failure;



- (void) reloadFormServer;
/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (BOOL) isAuthenticated;

//- (void) setPassword:(NSString * _Nonnull)password inBackGroundWithBlock:(nullable void (^)(BOOL saveStatus, id responseObject, NSError * error)) responseBlock;

///--------------------------------------
#pragma mark - PNUser Properties
///--------------------------------------

/**
 *  <#Description#>
 */
@property (strong, nonatomic, nullable) NSString * userId;
/**
 *  <#Description#>
 */
@property (strong, nonatomic, nullable) NSString * firstName;
/**
 *  <#Description#>
 */
@property (strong, nonatomic, nullable) NSString * lastName;
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
@property (nonatomic) BOOL hasVerifiedPhone;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSDate * emailVerifiedDate;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * email;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * username;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) PNObjcPassword * password;
/**
 *  <#Description#>
 */
@property (nonatomic) BOOL publicProfile;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSNumber * loginCount;
/**
 *  <#Description#>
 */
@property (nonatomic) BOOL isFacebookUser;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * facebookId;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * facebookAccessToken;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSDate * registeredAt;

@end
