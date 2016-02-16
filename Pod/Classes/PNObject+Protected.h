//
//  PNObject+Protected.h
//  Pods
//
//  Created by Giuseppe Nucifora on 25/01/16.
//
//

#import "PNObject.h"

@interface PNObject (Protected)
/**
 *  <#Description#>
 *
 *  @param JSON <#JSON description#>
 */
- (void)populateObjectFromJSON:(id _Nullable)JSON;

/**
 *  <#Description#>
 *
 *  @param JSON      <#JSON description#>
 *  @param fromLocal <#fromLocal description#>
 */
- (void) populateObjectFromJSON:(id _Nullable)JSON fromLocal:(BOOL) fromLocal;

/**
 *  <#Description#>
 *
 *  @param obj <#obj description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)isObjNull:(id _Nullable)obj;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray * _Nonnull) protectedProperties;

/**
 *  <#Description#>
 *
 *  @param PNObjClass <#PNObjClass description#>
 *
 *  @return <#return value description#>
 */
+ (NSDictionary * _Nullable)propertiesForClass:(Class _Nonnull)PNObjClass;

/**
 *  <#Description#>
 *
 *  @param mappingSelector <#mappingSelector description#>
 *
 *  @return <#return value description#>
 */
- (NSDictionary* _Nonnull) getFormObject:(SEL _Nonnull) dictionaryMappingSelector;

- (void)resetObject;

///--------------------------------------
#pragma mark - PNObject (Protected) Properties
///--------------------------------------
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull) PNObjectModel * objectModel;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSMutableDictionary *  JSON;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * endPoint;
/**
 *  <#Description#>
 */
@property (nonatomic) BOOL singleInstance;


@end
