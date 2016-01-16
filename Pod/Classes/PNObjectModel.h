//
//  PNObjectModel.h
//  Pods
//
//  Created by Giuseppe Nucifora on 16/01/16.
//
//

#import <Foundation/Foundation.h>

@protocol PNObjectPersistency <NSObject>

@required

- (BOOL) initObjectPersistency;

@end

@interface PNObjectModel : NSObject

@property (nonatomic, assign) id<PNObjectPersistency> _Nonnull persistencyDelegate;

+ (_Nonnull instancetype) sharedInstance;

/**
 *  <#Description#>
 *
 *  @param object PNObject Subclass to save
 *
 *  @return return It return the object if the save was successful.
 *  @return return NSError 
 */
- (id _Nonnull) saveLocally:(id _Nonnull) object;

/**
 *  <#Description#>
 *
 *  @param object        <#object description#>
 *  @param responseBlock <#responseBlock description#>
 */
- (void) saveLocally:(id _Nonnull) object inBackGroundWithBlock:(nullable void (^)(BOOL saveStatus, id _Nullable responseObject, NSError * _Nullable error)) responseBlock;

/**
 *  <#Description#>
 *
 *  @param object PNObject Subclass add list objects and save the list
 *
 *  @return <#return value description#>
 */
- (id _Nonnull) pushObjectAndSaveLocally:(id _Nonnull) object;

/**
 *  <#Description#>
 *
 *  @param object        <#object description#>
 *  @param responseBlock <#responseBlock description#>
 */
- (void) pushObjectAndSaveLocally:(id _Nonnull) object inBackGroundWithBlock:(nullable void (^)(BOOL saveStatus, id _Nullable responseObject, NSError * _Nullable error)) responseBlock;

@end
