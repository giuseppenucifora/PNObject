//
//  PNObjcPassword.m
//  Pods
//
//  Created by Giuseppe Nucifora on 13/01/16.
//
//

#import "PNObjcPassword.h"
#import "PNUser.h"
#import "PNObjectConstants.h"

@implementation PNObjcPassword

+ (NSString *) objectClassName {
    return @"PNObjcPassword";
}

+(NSString *)objectEndPoint {
    return @"PNObjcPassword";
}

+ (NSDictionary *) objcetMapping {
    NSDictionary *mapping = @{@"password":@"password",
                              @"confirmPassword":@"confirmPassword",
                              };
    return mapping;
}

+ (BOOL)singleInstance {
    return NO;
}



- (void) setPassword:(NSString *)password {
    if ([self validateMinimumRequirenment:password]) {
        _password = password;
    }
    else {
        NSLogDebug(@"Inserted Passord is not valid.Lenght must be >= %ld",(long)[[PNObjectConfig sharedInstance] minPasswordLenght]);
    }
}

- (void) setConfirmPassword:(NSString *)confirmPassword {
    if ([self validateMinimumRequirenment:confirmPassword]) {
        if ([confirmPassword isEqualToString:_password]) {
            _confirmPassword = confirmPassword;
        }
        else {
            NSLogDebug(@"Inserted Passord is not same password.");
        }
    }
    else {
        NSLogDebug(@"Inserted Passord is not valid.Lenght must be >= %ld",(long)[[PNObjectConfig sharedInstance] minPasswordLenght]);
    }
}


- (BOOL)isValid {
    if ([self validateMinimumRequirenment:_password] && [self validateMinimumRequirenment:_confirmPassword] && [_confirmPassword isEqualToString:_password]) {
        return YES;
    }
    return NO;
}

- (BOOL) validateMinimumRequirenment:(NSString * _Nullable) passString {
    if ([passString length] >= [[PNObjectConfig sharedInstance] minPasswordLenght]) {
        return YES;
    }
    return NO;
}

+ (BOOL) validateMinimumRequirenment:(NSString * _Nullable) passString {
    if ([passString length] >= [[PNObjectConfig sharedInstance] minPasswordLenght]) {
        return YES;
    }
    return NO;
}

@end
