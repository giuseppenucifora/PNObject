//
//  NSString+Helper.h
//
//
//  Created by Giuseppe Nucifora on 02/07/15.
//  Copyright (c) 2015 Giuseppe Nucifora All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

+ (NSString *) getRandString: (int) length;

- (BOOL) isValidEmail;

- (BOOL) isNumeric;

- (BOOL) isValidPhoneNumber;

- (BOOL) isValidUrl;

- (BOOL) isValidTaxCode;

- (BOOL) isValidFirstnameOrLastname;

- (NSString *) md5;

- (NSString*) sha1;

- (NSString*) sha256;

- (NSString*) sha512;


@end
