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
@property (nonatomic, strong) NSDate * _Nonnull createdDate;
@property (nonatomic, strong, getter=getObject) NSDictionary * _Nonnull objectMapping;
@property (nonatomic, assign) id<PNObjectSubclassing> _Nonnull subClassDelegate;

- (_Nullable instancetype) initWithJSON:( NSDictionary * _Nonnull) JSON;

- (id _Nonnull) saveLocally;

- (void) saveLocallyInBackGroundWithBlock:(id _Nonnull) object inBackGroundWithBlock:(nullable void (^)(BOOL saveStatus, id _Nullable responseObject, NSError * _Nullable error)) responseBlock;

@end
