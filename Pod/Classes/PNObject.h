//
//  PNObject.h
//  Pods
//
//  Created by Giuseppe Nucifora on 28/12/15.
//
//

#import <Foundation/Foundation.h>
#import "PNObjectConfig.h"
#import "PNObjectModel.h"

@protocol PNObjectSubclassing <NSObject>

@required

+ (NSDictionary * _Nonnull) objcetMapping;

+ (BOOL) singleInstance;

+ (NSString * _Nonnull) objectEndPoint;

@optional

+ (NSString * _Nonnull ) objectClassName;

@end

@interface PNObject : NSObject

+ (NSString * _Nonnull) PNObjClassName;

+ (NSString * _Nonnull) PNObjEndPoint;

- (_Nullable instancetype) initWithJSON:( NSDictionary * _Nonnull) JSON;

- (id _Nonnull) saveLocally;

- (BOOL) autoRemoveLocally;

///--------------------------------------
#pragma mark - PNObject Properties
///--------------------------------------

/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull) NSString * objID;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull) NSDate * createdAt;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull) NSDictionary * JSONObject;

@end