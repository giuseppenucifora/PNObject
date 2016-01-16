//
//  NSString+Helper.h
//
//
//  Created by Giuseppe Nucifora on 02/07/15.
//  Copyright (c) 2015 Giuseppe Nucifora All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

- (BOOL) isValidEmail;

- (BOOL) isNumeric;

- (BOOL) isValidUrl;

- (BOOL) isValidTaxCode;

@end
