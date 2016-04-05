//
//  DJLocalizableString.h
//  DJLocalization
//
//  Created by David Jennes on 15/02/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJLocalizableString : NSString

- (NSUInteger)length;
- (unichar)characterAtIndex:(NSUInteger)index;

@end
