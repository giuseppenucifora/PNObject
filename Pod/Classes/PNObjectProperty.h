//
//  PNObjectProperty.h
//  Pods
//
//  Created by Giuseppe Nucifora on 28/12/15.
//
//

#import <Foundation/Foundation.h>
#import "PNObject.h"

@interface PNObjectProperty : NSObject

+ (NSDictionary *)propertiesForClass:(Class)PNObjClass;

@end
