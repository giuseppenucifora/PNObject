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

@property (nonatomic, strong) NSString * _Nonnull objID;
@property (nonatomic, strong) NSDate * _Nonnull createdAt;
@property (nonatomic, strong, getter=getJSONObject) NSDictionary * _Nonnull objectMapping;
@property (nonatomic, assign) id<PNObjectSubclassing> _Nonnull subClassDelegate;

- (_Nullable instancetype) initWithJSON:( NSDictionary * _Nonnull) JSON;

- (id _Nonnull) saveLocally;

- (BOOL) autoRemoveLocally;

@end
