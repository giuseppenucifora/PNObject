//
//  DJLocalizationSystem.h
//  DJLocalization
//
//  Created by David Jennes on 15/02/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>

// replace Apple's macros with our own
#undef NSLocalizedString
#define NSLocalizedString(key, comment) \
	[DJLocalizationSystem.shared localizedStringForKey:(key) value: @"" table: nil]

#undef NSLocalizedStringFromTable
#define NSLocalizedStringFromTable(key, tbl, comment) \
	[DJLocalizationSystem.shared localizedStringForKey:(key) value:@"" table:(tbl)]

@interface DJLocalizationSystem : NSObject

/*!
 * Get the system's global instance
 *
 * @return A localization system instance
 */
+ (instancetype)shared;

/*!
 * Get the localized string for a given key/value
 *
 * @param key The localization key
 * @param comment The localization value
 * @param tableName The localization table name
 * @return The localized string
 */
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment table:(NSString *)tableName;

/*!
 * Get the localized string for a given key/value in the specified bundle
 *
 * @param key The localization key
 * @param comment The localization value
 * @param bundle The bundle to search in
 * @return The localized string
 */
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment table:(NSString *)tableName bundle:(NSBundle *)bundle;

/*!
 * Reset the localization to the system's default language
 */
- (void)resetLocalization;

/*!
 * The bundle for the currently active language
 */
@property (nonatomic, readonly) NSBundle *bundle;

/*!
 * The currently active language
 */
@property (nonatomic, strong) NSString *language;

@end
