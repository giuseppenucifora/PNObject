//
//  DJLocalizationSystem.h
//  DJLocalization
//
//  Created by David Jennes on 15/02/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DJLocalizedString(key, comment) \
	[DJLocalizationSystem.shared localizedStringForKey:(key) value: @"" table: nil]
#define DJLocalizedStringFromTable(key, tbl, comment) \
	[DJLocalizationSystem.shared localizedStringForKey:(key) value: @"" table:(tbl)]

// replace Apple's macros with our own
#undef NSLocalizedString
#define NSLocalizedString(key, comment) \
	DJLocalizedString(key, comment)

#undef NSLocalizedStringFromTable
#define NSLocalizedStringFromTable(key, tbl, comment) \
	DJLocalizedStringFromTable(key, tbl, comment)

@interface DJLocalizationSystem : NSObject

/*!
 * Get the system's global instance
 *
 * @return A localization system instance
 */
@property (class, nonnull, readonly) DJLocalizationSystem *shared;

/*!
 * Get the localized string for a given key/value
 *
 * @param key The localization key
 * @param comment The localization value
 * @param tableName The localization table name
 * @return The localized string
 */
- (nonnull NSString *)localizedStringForKey:(nullable NSString *)key value:(nullable NSString *)comment table:(nullable NSString *)tableName;

/*!
 * Get the localized string for a given key/value in the specified bundle
 *
 * @param key The localization key
 * @param comment The localization value
 * @param bundle The bundle to search in
 * @return The localized string
 */
- (nonnull NSString *)localizedStringForKey:(nullable NSString *)key value:(nullable NSString *)comment table:(nullable NSString *)tableName bundle:(nonnull NSBundle *)bundle;

/*!
 * Reset the localization to the system's default language
 */
- (void)resetLocalization;

/*!
 * The bundle for the currently active language
 */
@property (nonatomic, readonly, nonnull) NSBundle *bundle;

/*!
 * The currently active language
 */
@property (nonatomic, strong, nonnull) NSString *language;

@end
