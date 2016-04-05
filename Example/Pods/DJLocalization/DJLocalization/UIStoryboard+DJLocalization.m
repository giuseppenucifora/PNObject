//
//  UIStoryboard+DJLocalization.m
//  DJLocalization
//
//  Created by David Jennes on 15/02/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "UIStoryboard+DJLocalization.h"

#import "DJLocalizationSystem.h"

@implementation UIStoryboard (DJLocalization)

+ (instancetype)dj_storyboardWithName:(NSString *)name {
	return [self storyboardWithName: name bundle: DJLocalizationSystem.shared.bundle];
}

@end
