//
//  PNInstallation.h
//  Pods
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import <PNObject/PNObject.h>

@interface PNInstallation : PNObject

/**
 Gets the currently-running installation from disk and returns an instance of it.
 
 If this installation is not stored on disk, returns a `PFInstallation`
 with `deviceType` and `installationId` fields set to those of the
 current installation.
 
 @result Returns a `Installation` that represents the currently-running installation.
 */
+ (instancetype _Nonnull)currentInstallation;

- (void)setDeviceTokenFromData:(nullable NSData *)deviceTokenData;

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
@property (nonatomic, assign) NSInteger badge;

@end
