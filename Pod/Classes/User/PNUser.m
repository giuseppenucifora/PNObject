//
//  PNUser.m
//  Pods
//
//  Created by Giuseppe Nucifora on 08/01/16.
//
//

#import "PNUser.h"

@implementation PNUser

/*
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
 @property (strong, nonatomic) NSString *username;
 @property (nonatomic) BOOL publicProfile;
 @property (nonatomic) NSInteger loginCount;
 @property (strong, nonatomic) NSDate *createdAt;
 @property (nonatomic, strong) NSString *facebookId;
 @property (nonatomic, strong) NSString *facebookAccessToken;
 @property (nonatomic, strong) PNAddress *address;
 */

+ (NSDictionary *)objcetMapping {
    NSDictionary *mapping = @{@"userId":@"id",
                              @"firstName":@"firstName",
                              @"lastName":@"lastName",
                              @"profileImage":@"profileImage",
                              @"sex":@"sex",
                              @"birthDate":@"birthDate",
                              @"phone":@"phone",
                              @"hasAcceptedPrivacy":@"hasAcceptedPrivacy",
                              @"hasAcceptedNewsletter":@"hasAcceptedNewsletter",
                              @"hasVerifiedEmail":@"hasVerifiedEmail",
                              @"emailVerifiedDate":@"emailVerifiedDate",
                              @"email":@"email",
                              @"username":@"username",
                              @"publicProfile":@"public_profile",
                              @"loginCount":@"login_count",
                              @"createdAt":@"created_at",
                              @"facebookId":@"facebookId",
                              @"facebookAccessToken":@"facebookAccessToken",
                              @"address":@{@"key":@"address",@"type":@"PNAddress"}
                              };
    return mapping;
}

+ (NSString *)objectClassName {
    return  @"User";
}


@end
