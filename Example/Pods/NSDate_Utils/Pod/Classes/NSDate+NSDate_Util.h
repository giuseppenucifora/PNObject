//
//  NSDate+NSDate_Util.h
//
//  Created by Giuseppe Nucifora on 11/02/14.
//  Copyright (c) 2014 Giuseppe Nucifora. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSunRiseMinutes         5*60
#define kSunSetMinutes          19*60

#define kMoonRiseMinutes        17*60
#define kMoonSetMinutes         7*60

static NSString * _Nonnull kNSDateHelperFormatFullDateWithTime                = @"MMM d, yyyy h:mm a";
static NSString * _Nonnull kNSDateHelperFormatFullDate                        = @"MMM d, yyyy";
static NSString * _Nonnull kNSDateHelperFormatShortDateWithTime               = @"MMM d h:mm a";
static NSString * _Nonnull kNSDateHelperFormatShortDate                       = @"MMM d";
static NSString * _Nonnull kNSDateHelperFormatWeekday                         = @"EEEE";
static NSString * _Nonnull kNSDateHelperFormatWeekdayWithTime                 = @"EEEE h:mm a";
static NSString * _Nonnull kNSDateHelperFormatTime                            = @"h:mm a";
static NSString * _Nonnull kNSDateHelperFormatTimeWithPrefix                  = @"'at' h:mm a";

static NSString * _Nonnull kNSDateHelperFormatSQLTime                         = @"HH:mm:ss";

static NSString * _Nonnull kNSDateHelperFormatSQLDate                         = @"yyyy-MM-dd";
static NSString * _Nonnull kNSDateHelperFormatSQLDate_shashSeparated          = @"yyyy/MM/dd";

static NSString * _Nonnull kNSDateHelperFormatSQLDateIT                       = @"dd-MM-yyyy";
static NSString * _Nonnull kNSDateHelperFormatSQLDateIT_shashSeparated        = @"dd/MM/yyyy";

static NSString * _Nonnull kNSDateHelperFormatSQLDateEN                       = @"MM-dd-yyyy";
static NSString * _Nonnull kNSDateHelperFormatSQLDateEN_shashSeparated        = @"MM/dd/yyyy";

static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTime                 = @"yyyy-MM-dd HH:mm:ss";
static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTime_shashSeparated  = @"yyyy/MM/dd HH:mm:ss";

static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeIT                       = @"dd-MM-yyyy HH:mm:ss";
static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeIT_shashSeparated        = @"dd/MM/yyyy HH:mm:ss";

static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeEN                       = @"MM-dd-yyyy HH:mm:ss";
static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeEN_shashSeparated        = @"MM/dd/yyyy HH:mm:ss";

static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZone_T_Separator = @"yyyy-MM-dd'T'HH:mm:ss ZZZ";
static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZone_T_Separator_shashSeparated = @"yyyy/MM/dd'T'HH:mm:ss ZZZ";

static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZoneEN_T_Separator = @"MM-dd-yyyy'T'HH:mm:ss ZZZ";
static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZoneENAndTSeparator_shashSeparated = @"MM/dd/yyyy'T'HH:mm:ss ZZZ";

static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZoneIT_T_Separator = @"dd-MM-yyyy'T'HH:mm:ss ZZZ";
static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZoneIT_T_Separator_shashSeparated = @"dd/MM/yyyy'T'HH:mm:ss ZZZ";

static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZone = @"yyyy-MM-dd HH:mm:ss ZZZ";
static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZone_shashSeparated = @"yyyy/MM/dd HH:mm:ss ZZZ";

static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZoneEN = @"MM-dd-yyyy HH:mm:ss ZZZ";
static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZoneEN_shashSeparated = @"MM/dd/yyyy HH:mm:ss ZZZ";

static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZoneIT = @"dd-MM-yyyy HH:mm:ss ZZZ";
static NSString * _Nonnull kNSDateHelperFormatSQLDateWithTimeZoneIT_shashSeparated = @"dd/MM/yyyy HH:mm:ss ZZZ";

@interface NSDate (NSDate_Util)

+ (void)initializeStatics;

+ (NSCalendar * _Nonnull) sharedCalendar;
+ (NSDateFormatter * _Nonnull) sharedDateFormatter;

+ (NSDate * _Nullable) dateFromString:(NSString * _Nonnull) string;
+ (NSDate * _Nullable) dateFromString:(NSString * _Nonnull) string withFormat:(NSString * _Nonnull) format;
+ (NSDate * _Nullable) dateFromString:(NSString * _Nonnull) string withFormat:(NSString * _Nonnull) format withTimeZone:(NSTimeZone * _Nonnull) timeZone;
+ (NSDate * _Nullable) dateFromISO8601String:(NSString * _Nonnull) string;

+ (NSString * _Nonnull) stringFromDate:(NSDate * _Nonnull) date withFormat:(NSString * _Nonnull) string;
+ (NSString * _Nonnull) stringFromDate:(NSDate * _Nonnull) date;
+ (NSString * _Nonnull) stringForDisplayFromDate:(NSDate * _Nonnull) date;
+ (NSString * _Nonnull) stringForDisplayFromDate:(NSDate * _Nonnull) date prefixed:(BOOL) prefixed;
+ (NSString * _Nonnull) stringForDisplayFromDate:(NSDate * _Nonnull) date prefixed:(BOOL) prefixed alwaysDisplayTime:(BOOL)displayTime;

+ (NSString * _Nonnull) dateFormatString;
+ (NSString * _Nonnull) timeFormatString;
+ (NSString * _Nonnull) timestampFormatString;
+ (NSString * _Nonnull) dbFormatString;

+ (NSString * _Nonnull) parseDateFormatFromString:(NSString * _Nonnull) dateString;

+ (NSString * _Nonnull) WCFStringFromDate:(NSDate * _Nonnull) date;

+ (NSArray * _Nullable) getSlotTimesFromDate:(NSDate * _Nonnull) date distanceMinutes:(NSInteger) minutes;

+ (NSString * _Nonnull) getUniversalHourFromDateString:(NSString * _Nonnull) string formatterString:(NSString * _Nonnull) formatterString andUppercaseString:(BOOL) uppercaseString;

+ (NSTimeInterval) timeIntervalFromMinutes:(NSUInteger) minutes;
+ (NSTimeInterval) timeIntervalFromHours:(NSUInteger) minutes;

+ (NSString * _Nonnull) stringFromWeekday :(NSInteger) weekday;
+ (NSString * _Nonnull) stringMonth :(NSInteger) month;

- (NSDate * _Nonnull) dateToNearestMinutes:(NSInteger)minutes;

- (NSDate * _Nonnull) dateByAddingMinutes:(NSInteger) dMinutes;
- (NSDate * _Nonnull) dateByAddingHours:(NSInteger) hours;
- (NSDate * _Nonnull) dateByAddingDays:(NSInteger) days;
- (NSDate * _Nonnull) dateByAddingYears:(NSInteger) years;

- (NSDate * _Nonnull) dateBySubtractingMinutes:(NSInteger) dMinutes;
- (NSDate * _Nonnull) dateBySubtractingHours:(NSInteger) hours;
- (NSDate * _Nonnull) dateBySubtractingDays:(NSInteger) days;
- (NSDate * _Nonnull) dateBySubtractingYears:(NSInteger) years;

- (NSDate * _Nonnull) dateAtStartOfDay;
- (NSDate * _Nonnull) dateAtEndOfDay;

- (NSInteger) minutesAfterDate:(NSDate * _Nonnull) aDate;
- (CGFloat) distanceInWeeksToDate:(NSDate * _Nonnull) anotherDate;
- (CGFloat) distanceInDaysToDate:(NSDate * _Nonnull) anotherDate;
- (CGFloat) distanceInHoursToDate:(NSDate * _Nonnull) anotherDate;
- (CGFloat) distanceInMinutesToDate:(NSDate * _Nonnull) anotherDate;
- (CGFloat) distanceInSeconsToDate:(NSDate * _Nonnull) anotherDate;

- (NSDate * _Nonnull) toLocalTime;
- (NSDate * _Nonnull) toGlobalTime;

- (BOOL) isSameYearAsDate:(NSDate * _Nonnull) aDate;
- (BOOL) isEarlierThanDate:(NSDate * _Nonnull) aDate;
- (BOOL) isLaterThanDate:(NSDate * _Nonnull) aDate;

- (NSUInteger) daysAgo;
- (NSUInteger) daysAgoAgainstMidnight;
- (NSString * _Nonnull) stringDaysAgo;
- (NSString * _Nonnull) stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger) monthDay;
- (NSUInteger) weekday;
- (NSUInteger) month;
- (NSUInteger) weekNumber;
- (NSUInteger) hour;
- (NSUInteger) minute;
- (NSUInteger) year;
- (long int) utcTimeStamp; //full seconds since

- (NSString * _Nonnull) monthSymbol;
- (NSString * _Nonnull) string;
- (NSString * _Nullable) stringWithFormat:(NSString * _Nonnull) format;
- (NSString * _Nullable) stringWithFormat:(NSString * _Nonnull) format timeZone:(NSTimeZone * _Nonnull) timezone;
- (NSString * _Nonnull) stringWithDateStyle:(NSDateFormatterStyle) dateStyle timeStyle:(NSDateFormatterStyle) timeStyle;
- (NSDate * _Nonnull) beginningOfWeek;
- (NSDate * _Nonnull) beginningOfDay;
- (NSDate * _Nonnull) endOfWeek;

- (BOOL)isSameDayAsDate:(NSDate * _Nonnull)otherDate;

- (NSString * _Nonnull) getUniversalHourUppercaseString:(BOOL) uppercaseString;
- (NSString * _Nonnull) getNotificationUniversalHourUppercaseString:(BOOL) uppercaseString;

@end
