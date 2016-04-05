//
//  DJLocalizationSystem+Private.h
//  DJLocalization
//
//  Created by David Jennes on 16/02/16.
//  Copyright (c) 2015. All rights reserved.
//

#import "DJLocalizationSystem.h"

@interface DJLocalizationSystem (Private)

/*!
 *	Special version that tries to load a storyboard string from all the tables
 *	except Localizable and InfoPlist. Defaults to comment if not found.
 *
 *	@param key		The localization key
 *	@param comment	The localization value
 *
 *	@return The localized string
 */
- (NSString *)localizedStoryboardStringForKey:(NSString *)key value:(NSString *)comment;

@end
