# NSDate_Utils

[![CI Status](http://img.shields.io/travis/Giuseppe Nucifora/NSDate_Utils.svg?style=flat)](https://travis-ci.org/Giuseppe Nucifora/NSDate_Utils)
[![Version](https://img.shields.io/cocoapods/v/NSDate_Utils.svg?style=flat)](http://cocoapods.org/pods/NSDate_Utils)
[![License](https://img.shields.io/cocoapods/l/NSDate_Utils.svg?style=flat)](http://cocoapods.org/pods/NSDate_Utils)
[![Platform](https://img.shields.io/cocoapods/p/NSDate_Utils.svg?style=flat)](http://cocoapods.org/pods/NSDate_Utils)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

NSDate_Utils is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NSDate_Utils"
```

```ruby
+ (NSCalendar *) sharedCalendar;
+ (NSDateFormatter *) sharedDateFormatter;


+ (NSString *) dateFormatString;
+ (NSString *) timeFormatString;
+ (NSString *) timestampFormatString;
+ (NSString *) dbFormatString;

+ (NSString *) parseDateFormatFromString:(NSString *) dateString;

+ (NSString *) WCFStringFromDate:(NSDate*) date;

+ (NSArray*) getSlotTimesFromDate:(NSDate*) date distanceMinutes:(NSInteger) minutes;

+ (NSDate *) dateFromString:(NSString *) string;
+ (NSDate *) dateFromString:(NSString *) string withFormat:(NSString *) format;
+ (NSDate *) dateFromString:(NSString *) string withFormat:(NSString *) format withTimeZone:(NSTimeZone*) timeZone;
+ (NSString *) stringFromDate:(NSDate *) date withFormat:(NSString *) string;
+ (NSString *) stringFromDate:(NSDate *) date;
+ (NSString *) stringForDisplayFromDate:(NSDate *) date;
+ (NSString *) stringForDisplayFromDate:(NSDate *) date prefixed:(BOOL) prefixed;
+ (NSString *) stringForDisplayFromDate:(NSDate *) date prefixed:(BOOL) prefixed alwaysDisplayTime:(BOOL)displayTime;

+ (NSString *) getUniversalHourFromDateString:(NSString *) string formatterString:(NSString*) formatterString andUppercaseString:(BOOL) uppercaseString;

- (NSDate *) dateToNearestMinutes:(NSInteger)minutes;

- (NSDate *) dateByAddingMinutes:(NSInteger) dMinutes;
- (NSDate *) dateByAddingHours:(NSInteger) hours;
- (NSDate*) dateByAddingDays:(NSInteger) days;
- (NSDate*) dateByAddingYears:(NSInteger) years;

- (NSDate *) dateBySubtractingMinutes:(NSInteger) dMinutes;
- (NSDate *) dateBySubtractingHours:(NSInteger) hours;
- (NSDate *) dateBySubtractingDays:(NSInteger) days;
- (NSDate *) dateBySubtractingYears:(NSInteger) years;

- (NSDate *) dateAtStartOfDay;

- (NSInteger) minutesAfterDate:(NSDate *) aDate;
- (CGFloat) distanceInWeeksToDate:(NSDate *) anotherDate;
- (CGFloat) distanceInDaysToDate:(NSDate *) anotherDate;
- (CGFloat) distanceInHoursToDate:(NSDate *) anotherDate;
- (CGFloat) distanceInMinutesToDate:(NSDate *) anotherDate;
- (CGFloat) distanceInSeconsToDate:(NSDate *) anotherDate;

- (NSDate *) toLocalTime;
- (NSDate *) toGlobalTime;

- (BOOL) isSameYearAsDate:(NSDate *) aDate;
- (BOOL) isEarlierThanDate:(NSDate *) aDate;
- (BOOL) isLaterThanDate:(NSDate *) aDate;

- (NSUInteger) daysAgo;
- (NSUInteger) daysAgoAgainstMidnight;
- (NSString *) stringDaysAgo;
- (NSString *) stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger) monthDay;
- (NSUInteger) weekday;
- (NSUInteger) month;
- (NSUInteger) weekNumber;
- (NSUInteger) hour;
- (NSUInteger) minute;
- (NSUInteger) year;
- (long int) utcTimeStamp; //full seconds since

- (NSString *) string;
- (NSString *) stringWithFormat:(NSString *) format;
- (NSString *) stringWithFormat:(NSString *) format timeZone:(NSTimeZone*) timezone;
- (NSString *) stringWithDateStyle:(NSDateFormatterStyle) dateStyle timeStyle:(NSDateFormatterStyle) timeStyle;
- (NSDate *) beginningOfWeek;
- (NSDate *) beginningOfDay;
- (NSDate *) endOfWeek;


- (BOOL)isSameDayAsDate:(NSDate*)otherDate;

- (NSString *) getUniversalHourUppercaseString:(BOOL) uppercaseString;
- (NSString *) getNotificationUniversalHourUppercaseString:(BOOL) uppercaseString;
```

## Author

Giuseppe Nucifora, me@giuseppenucifora.com

## License

NSDate_Utils is available under the MIT license. See the LICENSE file for more info.
