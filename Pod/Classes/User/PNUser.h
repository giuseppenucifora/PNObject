//
//  PNUser.h
//  Pods
//
//  Created by Giuseppe Nucifora on 15/01/16.
//
//

#import "PNObject.h"


@interface PNUser : PNObject

@property (strong, nonatomic) NSString * _Nonnull userId;
@property (strong, nonatomic) NSString * _Nonnull firstName;
@property (strong, nonatomic) NSString * _Nonnull lastName;
@property (nonatomic, strong) NSString * _Nullable profileImage;
@property (nonatomic, strong) NSString * _Nullable sex;
@property (nonatomic, strong) NSDate * _Nullable birthDate;
@property (nonatomic, strong) NSString * _Nullable phone;
@property (nonatomic) BOOL hasAcceptedPrivacy;
@property (nonatomic) BOOL hasAcceptedNewsletter;
@property (nonatomic) BOOL hasVerifiedEmail;
@property (nonatomic, strong) NSDate * _Nullable emailVerifiedDate;
@property (nonatomic, strong) NSString * _Nonnull email;
@property (nonatomic, strong) NSString * _Nonnull username;
@property (nonatomic, strong) NSString * _Nonnull password;
@property (nonatomic) BOOL publicProfile;
@property (nonatomic) NSInteger loginCount;
@property (strong, nonatomic) NSDate * _Nonnull createdAt;
@property (nonatomic, strong) NSString * _Nullable facebookId;
@property (nonatomic, strong) NSString * _Nullable facebookAccessToken;


/**
 *  gets singleton object of current user session.
 *
 *  @return singleton
 */
+ (instancetype _Nonnull) currentUser;

- (BOOL) isValidPassword:(NSString* _Nonnull) password;

- (void) setPassword:(NSString * _Nonnull)password withBlock:(id _Nonnull) object inBackGroundWithBlock:(nullable void (^)(BOOL saveStatus, id _Nullable responseObject, NSError * _Nullable error)) responseBlock;

@end
