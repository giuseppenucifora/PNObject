//
//  PNAddress.h
//  Pods
//
//  Created by Giuseppe Nucifora on 13/01/16.
//
//

#import "PNObject.h"
#import "PNLocation.h"

@interface PNAddress : PNObject <PNObjectSubclassing>

///--------------------------------------
#pragma mark - PNAddress Properties
///--------------------------------------

/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * country;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * province;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * city;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * street;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSNumber * number;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * zip;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSString * istruction;
/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) PNLocation * location;

@end
