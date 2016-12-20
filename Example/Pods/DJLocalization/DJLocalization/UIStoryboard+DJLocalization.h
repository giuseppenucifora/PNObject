//
//  UIStoryboard+DJLocalization.h
//  DJLocalization
//
//  Created by David Jennes on 15/02/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (DJLocalization)

/*!
 * Get the storyboard for the active language
 *
 * @param name The storyboard's name
 * @return The desired storyboard
 */
+ (nonnull instancetype)dj_storyboardWithName:(nonnull NSString *)name;

@end
