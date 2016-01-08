//
//  PNObject.h
//  Pods
//
//  Created by Giuseppe Nucifora on 28/12/15.
//
//

#import <Foundation/Foundation.h>
#import "PNObjectSubclassing.h"
#import "PNObjectConfig.h"

@interface PNObject : NSObject <PNObjectSubclassing>

@property (nonatomic, strong) NSString *objID;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSDictionary *objectMapping;

- (instancetype) initWithJSON:(NSDictionary*) JSON;



@end
