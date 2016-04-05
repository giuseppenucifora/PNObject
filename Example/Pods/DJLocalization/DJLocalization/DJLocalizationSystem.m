//
//  DJLocalizationSystem.m
//  DJLocalization
//
//  Created by David Jennes on 15/02/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "DJLocalization.h"
#import "DJLocalizationSystem+Private.h"

@interface DJLocalizationSystem ()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSDictionary *storyboardStrings;
@property (nonatomic, strong) NSString *customLanguage;

@end

@implementation DJLocalizationSystem

+ (instancetype)shared {
	__strong static DJLocalizationSystem *sharedSystem = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedSystem = [self new];
	});

	return sharedSystem;
}

- (instancetype)init {
    self = [super init];
	if (!self)
		return nil;
	
	[self resetLocalization];

    return self;
}

- (NSString *)localizedStoryboardStringForKey:(NSString *)key value:(NSString *)comment {
	NSString *result = self.storyboardStrings[key];
	if (!result)
		result = comment;

	return result;
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
	return [self.bundle localizedStringForKey: key value: value table: tableName];
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName bundle:(NSBundle *)bundle {
	// if no custom language, just get the standard localized string
	if (!self.customLanguage)
		return [bundle localizedStringForKey: key value: value table: tableName];

	// check if our custom language exists
	NSString *path = [bundle pathForResource: self.customLanguage ofType: @"lproj"];
	if (path)
		return [[NSBundle bundleWithPath: path] localizedStringForKey: key value: value table: tableName];

	// otherwise return the default
	return [bundle localizedStringForKey: key value: value table: tableName];
}

- (void)resetLocalization {
	self.language = NSBundle.mainBundle.preferredLocalizations.firstObject;
}

- (void)setLanguage:(NSString*)language {
	if ([language isEqualToString: self.customLanguage ])
		return;
	NSDictionary *languageInfo = [NSLocale componentsFromLocaleIdentifier: language];

	// find bundle
	NSString *path = [NSBundle.mainBundle pathForResource: language ofType: @"lproj"];
	if (path == nil)
		path = [NSBundle.mainBundle pathForResource: languageInfo[NSLocaleLanguageCode] ofType: @"lproj"];

	// set bundle
	if (path) {
		self.bundle = [NSBundle bundleWithPath: path];
		[self loadTables];

		// store language id
		self.customLanguage = language;
	} else {
		NSLog(@"Localization error: no bundle found, resetting!");
		self.bundle = NSBundle.mainBundle;
		self.customLanguage = nil;
	}
}

- (NSString*)language {
	if (self.customLanguage)
		return self.customLanguage;
	else {
		NSString *language = NSLocale.preferredLanguages.firstObject;
		NSDictionary *languageInfo = [NSLocale componentsFromLocaleIdentifier: language];

		return languageInfo[NSLocaleLanguageCode];
	}
}

#pragma mark - Helper methods

- (void)loadTables {
	NSMutableDictionary *strings = [NSMutableDictionary new];

	// find strings files
	NSFileManager *fileManager = NSFileManager.defaultManager;
	NSURL *bundleURL = self.bundle.bundleURL;
	NSArray *contents = [fileManager contentsOfDirectoryAtURL: bundleURL
								   includingPropertiesForKeys: @[]
													  options: NSDirectoryEnumerationSkipsHiddenFiles
														error: nil];

	// load them
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"pathExtension == 'strings'"];
	for (NSURL *fileURL in [contents filteredArrayUsingPredicate: predicate]) {
		if ([fileURL.lastPathComponent isEqualToString: @"Localizable.strings"])
			continue;
		if ([fileURL.lastPathComponent isEqualToString: @"InfoPlist.strings"])
			continue;

		NSDictionary *table = [NSDictionary dictionaryWithContentsOfURL: fileURL];
		[strings addEntriesFromDictionary: table];
	}

	self.storyboardStrings = strings;
}

@end
