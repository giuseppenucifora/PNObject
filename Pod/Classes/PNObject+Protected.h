//
//  PNObject+Protected.h
//  Pods
//
//  Created by Giuseppe Nucifora on 25/01/16.
//
//

#import <PNObject/PNObject.h>

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
@property (nonatomic, strong, nonnull) NSDictionary *  JSON;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nonnull) NSString * endPoint;
/**
 *  <#Description#>
 */
@property (nonatomic) BOOL singleInstance;


@end
