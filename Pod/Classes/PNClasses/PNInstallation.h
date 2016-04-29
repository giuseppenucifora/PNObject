//
//  PNInstallation.h
//  Pods
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import "PNObject.h"

typedef NS_ENUM(NSInteger, PNInstallationType) {
    PNInstallationTypeNew = 0,
    PNInstallationTypeChange,
    PNInstallationTypeNone,
};

@interface PNInstallation : PNObject

/**
 Gets the currently-running installation from disk and returns an instance of it.
 
 If this installation is not stored on disk, returns a `PFInstallation`
 with `deviceType` and `installationId` fields set to those of the
 current installation.
 
 @result Returns a `Installation` that represents the currently-running installation.
 */
+ (instancetype _Nonnull)currentInstallation;

/**
 *  <#Description#>
 *
 *  @param deviceTokenData <#deviceTokenData description#>
 *
 *  @return RETURN YES if token is not set o token changes, NO if token is the same of old token.
 */
- (PNInstallationType) setDeviceTokenFromData:(nullable NSData *)deviceTokenData;

/**
 *  <#Description#>
 */
- (void) resetBadge;

- (void) setRegistered;

- (void) setUpdated;

///--------------------------------------
#pragma mark - PNInstallation Properties
///--------------------------------------

/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) NSString *deviceType;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) NSString *deviceModel;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) NSString *deviceName;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) NSString *osVersion;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nonnull) NSString *localeIdentifier;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nullable) NSString *deviceToken;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nullable) NSString *oldDeviceToken;
/**
 *  <#Description#>
 */
@property (nonatomic, assign) NSInteger badge;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nullable) NSDate *registeredAt;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nullable) NSDate *updatedAt;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly, nullable) NSDate *lastTokenUpdate;

@end
