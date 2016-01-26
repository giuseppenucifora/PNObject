//
//  CodFisResponse.h
//  CodFis-Helper
//
//  Created by Giuseppe Nucifora on 09/07/15.
//  Copyright (c) 2015 Giuseppe Nucifora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseConstants.h"

@interface CodFisResponse : NSObject

@property (nonatomic, strong, readonly) NSArray *responseErrors;
@property (nonatomic, strong, readonly) NSString *response;

- (instancetype) initWithResponse:(NSString*) response andErrors:(NSArray*) responseErrors;

@end
