//
//  PNObjectSubclassing.h
//  Pods
//
//  Created by Giuseppe Nucifora on 08/01/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PNObjectSubclassing <NSObject>

@required

+ (NSString *) objectClassName;

+ (NSDictionary *) objcetMapping;


@end
