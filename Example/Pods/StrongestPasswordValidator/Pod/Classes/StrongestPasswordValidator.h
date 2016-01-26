//
//  StrongestPasswordValidator.h
//
//  Created by Giuseppe Nucifora on 03/01/13.
//  Copyright (c) 2013 Giuseppe Nucifora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StrongestPasswordValidator : NSObject

typedef NS_ENUM(NSInteger, PasswordStrengthType) {
    PasswordStrengthTypeWeak,
    PasswordStrengthTypeModerate,
    PasswordStrengthTypeStrong
};

+ (instancetype _Nonnull) sharedInstance;

- (void) setColor:(UIColor * _Nonnull) color forPasswordStrenghtType:(PasswordStrengthType) strenghtType;

- (void)checkPasswordStrength:(NSString * _Nonnull )password withBlock:(nullable void (^)(UIColor * _Nonnull color, PasswordStrengthType  strenghtType)) responseBlock;

- (PasswordStrengthType)checkPasswordStrength:(NSString * _Nonnull)password;

@end
