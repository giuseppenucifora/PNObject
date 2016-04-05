//
//  DJLocalizableString.m
//  DJLocalization
//
//  Created by David Jennes on 15/02/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "DJLocalizableString.h"

#import "DJLocalizationSystem+Private.h"

static NSString * const kDJLocalizableString = @"NSLocalizableString";

@interface DJLocalizableString ()

@property (nonatomic, strong) NSString *developmentLanguageString;
@property (nonatomic, strong) NSString *stringsFileKey;

@end

@implementation DJLocalizableString

+ (void)load {
    @autoreleasepool {
        [NSKeyedUnarchiver setClass: DJLocalizableString.class forClassName: kDJLocalizableString];
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
    if (self) {
        self.stringsFileKey = [aDecoder decodeObjectForKey: @"NSKey"];
        self.developmentLanguageString = [aDecoder decodeObjectForKey: @"NSDev"];
    }
	
    return self;
}

#pragma mark - NSObject

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return [DJLocalizationSystem.shared localizedStoryboardStringForKey: self.stringsFileKey
																  value: self.developmentLanguageString];
}

#pragma mark - NSString

- (NSUInteger)length {
    return self.developmentLanguageString.length;
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return [self.developmentLanguageString characterAtIndex: index];
}

@end
