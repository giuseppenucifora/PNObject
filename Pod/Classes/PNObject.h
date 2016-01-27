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

+ (NSString * _Nonnull ) objectClassName;

+ (NSDictionary * _Nonnull) objcetMapping;

+ (BOOL) singleInstance;


@end

@interface PNObject : NSObject

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
@property (nonatomic, strong, getter=getJSONObject, nonnull) NSDictionary * objectMapping;


@end
