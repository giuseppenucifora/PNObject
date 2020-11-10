//
//  PNInstallation.h
//  Pods
//  Version 2.7.0
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import "PNObject.h"
#import "PNUser.h"

typedef NS_ENUM(NSInteger, PNInstallationStatus) {
    PNInstallationStatusNew = 0,
    PNInstallationStatusChange,
    PNInstallationStatusNone,
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
- (PNInstallationStatus) setDeviceTokenFromData:(nullable NSData *)deviceTokenData;

/**
 *  <#Description#>
 */
- (void) resetBadge;

- (void) setRegistered;

- (void) setUpdated;

- (void) registerDeviceWithBlockProgress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                                 Success:(nullable void (^)(BOOL response))success
                                 failure:(nullable void (^)(NSError * _Nonnull error))failure;

- (void) updateDeviceWithBlockProgress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                               Success:(nullable void (^)(BOOL response))success
                               failure:(nullable void (^)(NSError * _Nonnull error))failure;

- (void) removeDeviceWithBlockProgress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                               Success:(nullable void (^)(BOOL response))success
                               failure:(nullable void (^)(NSError * _Nonnull error))failure;

///--------------------------------------
#pragma mark - PNInstallation Properties
///--------------------------------------
@property (nonatomic, strong, nullable) PNUser *user;
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
@property (nonatomic, readonly) PNInstallationStatus installationStatus;
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
