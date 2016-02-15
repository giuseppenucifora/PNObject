//
//  PNObjcPassword.h
//  Pods
//
//  Created by Giuseppe Nucifora on 13/01/16.
//
//

#import "PNObject.h"

@interface PNObjcPassword : PNObject <PNObjectSubclassing>

+ (BOOL) validateMinimumRequirenment:(NSString * _Nullable) passString;

- (BOOL) isValid;

///--------------------------------------
#pragma mark - PNObjcPassword Properties
///--------------------------------------

/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString *password;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString *confirmPassword;

@end
