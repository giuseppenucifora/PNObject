//
//  PNLocation.h
//  Pods
//  Version 2.7.0
//
//  Created by Giuseppe Nucifora on 13/01/16.
//
//

#import "PNObject.h"

@interface PNLocation : PNObject <PNObjectSubclassing>

///--------------------------------------
#pragma mark - PNLocation Properties
///--------------------------------------

/**
 *  <#Description#>
 */
@property (nonatomic) CGFloat lat;
/**
 *  <#Description#>
 */
@property (nonatomic) CGFloat lng;

@end
