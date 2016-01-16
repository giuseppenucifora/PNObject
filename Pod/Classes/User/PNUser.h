//
//  PNUser.h
//  Pods
//
//  Created by Giuseppe Nucifora on 15/01/16.
//
//

#import "PNObject.h"
#import "PNAddress.h"

@interface PNUser : PNObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (nonatomic, strong) NSString *profileImage;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSDate *birthDate;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic) BOOL hasAcceptedPrivacy;
@property (nonatomic) BOOL hasAcceptedNewsletter;
@property (nonatomic) BOOL hasVerifiedEmail;
@property (nonatomic, strong) NSDate *emailVerifiedDate;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic) BOOL publicProfile;
@property (nonatomic) NSInteger loginCount;
@property (strong, nonatomic) NSDate *createdAt;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSString *facebookAccessToken;
@property (nonatomic, strong) PNAddress *address;

/**
 *  gets singleton object of current user session.
 *
 *  @return singleton
 */
+ (instancetype) currentUser;

- (BOOL) isValidPassword:(NSString* _Nonnull) password;

- (void) setPassword:(NSString * _Nonnull)password withBlock:(id _Nonnull) object inBackGroundWithBlock:(nullable void (^)(BOOL saveStatus, id _Nullable responseObject, NSError * _Nullable error)) responseBlock;

@end
