//
//  NSDate+NSDate_Util.m
//
//  Created by Giuseppe Nucifora on 11/02/14.
//  Copyright (c) 2014 Giuseppe Nucifora. All rights reserved.
//

#import "NSDate+NSDate_Util.h"

#define DATE_COMPONENTS (NSCalendarUnitEra | NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]
#define D_MINUTE	60


@implementation NSDate (NSDate_Util)

static NSCalendar *_calendar = nil;
static NSDateFormatter *_displayFormatter = nil;

+ (void)initializeStatics {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if (_calendar == nil) {
                _calendar = [NSCalendar currentCalendar];
            }
            if (_displayFormatter == nil) {
                _displayFormatter = [[NSDateFormatter alloc] init];
            }
        }
    });
}

+ (NSCalendar *)sharedCalendar {
    [self initializeStatics];
    return _calendar;
}

+ (NSDateFormatter *)sharedDateFormatter {
    [self initializeStatics];
    return _displayFormatter;
}

+ (NSDate *)dateFromString:(NSString *)string {
    return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format withTimeZone:(NSTimeZone*) timeZone {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    if (timeZone) {
        [formatter setTimeZone:timeZone];
    }
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+ (NSDate *) dateFromISO8601String:(NSString*) string {
    
    NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
    
    return [formatter dateFromString:string];
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    return [date string];
}

+ (NSString *) WCFStringFromDate:(NSDate*) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"Z"];
    
    NSString *jsonDateFrom = [NSString stringWithFormat:@"/Date(%.0f000%@)/", [date timeIntervalSince1970],[formatter stringFromDate:date]];
    
    return jsonDateFrom;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime {
    /*
     * if the date is in today, display 12-hour time with meridian,
     * if it is within the last 7 days, display weekday name (Friday)
     * if within the calendar year, display as Jan 23
     * else display as Nov 11, 2008
     */
    NSDate *today = [NSDate date];
    NSDateComponents *offsetComponents = [[self sharedCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                                  fromDate:today];
    NSDate *midnight = [[self sharedCalendar] dateFromComponents:offsetComponents];
    NSString *displayString = nil;
    // comparing against midnight
    NSComparisonResult midnight_result = [date compare:midnight];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (midnight_result == NSOrderedDescending) {
        if (prefixed) {
            [formatter setDateFormat:kNSDateHelperFormatTimeWithPrefix]; // at 11:30 am
        } else {
            [formatter setDateFormat:kNSDateHelperFormatTime]; // 11:30 am
        }
    } else {
        // check if date is within last 7 days
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-7];
        NSDate *lastweek = [[self sharedCalendar] dateByAddingComponents:componentsToSubtract toDate:today options:0];

        NSComparisonResult lastweek_result = [date compare:lastweek];
        if (lastweek_result == NSOrderedDescending) {
            if (displayTime) {
                [formatter setDateFormat:kNSDateHelperFormatWeekdayWithTime];
            } else {
                [formatter setDateFormat:kNSDateHelperFormatWeekday]; // Tuesday
            }
        } else {
            // check if same calendar year
            NSInteger thisYear = [offsetComponents year];
            NSDateComponents *dateComponents = [[self sharedCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                                        fromDate:date];
            NSInteger thatYear = [dateComponents year];
            if (thatYear >= thisYear) {
                if (displayTime) {
                    [formatter setDateFormat:kNSDateHelperFormatShortDateWithTime];
                }
                else {
                    [formatter setDateFormat:kNSDateHelperFormatShortDate];
                }
            } else {
                if (displayTime) {
                    [formatter setDateFormat:kNSDateHelperFormatFullDateWithTime];
                }
                else {
                    [formatter setDateFormat:kNSDateHelperFormatFullDate];
                }
            }
        }
        if (prefixed) {
            NSString *dateFormat = [formatter dateFormat];
            NSString *prefix = @"'on' ";
            [formatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
        }
    }
    // use display formatter to return formatted date string
    displayString = [formatter stringFromDate:date];
    return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
    return [[self class] stringForDisplayFromDate:date prefixed:prefixed alwaysDisplayTime:NO];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
    return [self stringForDisplayFromDate:date prefixed:NO];
}

+ (NSString *)dateFormatString {
    return kNSDateHelperFormatSQLDate;
}

+ (NSString *)timeFormatString {
    return kNSDateHelperFormatSQLTime;
}

+ (NSString *)timestampFormatString {
    return kNSDateHelperFormatSQLDateWithTime;
}

// preserving for compatibility
+ (NSString *)dbFormatString {
    return [NSDate timestampFormatString];
}

+ (NSString *)parseDateFormatFromString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSArray *dateFormatsArray = [[NSArray alloc] initWithObjects:kNSDateHelperFormatFullDateWithTime,kNSDateHelperFormatFullDate,
                                 kNSDateHelperFormatShortDateWithTime,kNSDateHelperFormatShortDate,kNSDateHelperFormatWeekday,
                                 kNSDateHelperFormatWeekdayWithTime,kNSDateHelperFormatTime,kNSDateHelperFormatTimeWithPrefix,
                                 kNSDateHelperFormatSQLTime,kNSDateHelperFormatSQLDate,kNSDateHelperFormatSQLDate_shashSeparated,
                                 kNSDateHelperFormatSQLDateIT,kNSDateHelperFormatSQLDateIT_shashSeparated,kNSDateHelperFormatSQLDateEN,
                                 kNSDateHelperFormatSQLDateEN_shashSeparated,kNSDateHelperFormatSQLDateWithTime,
                                 kNSDateHelperFormatSQLDateWithTime_shashSeparated,kNSDateHelperFormatSQLDateWithTimeIT,
                                 kNSDateHelperFormatSQLDateWithTimeIT_shashSeparated,kNSDateHelperFormatSQLDateWithTimeEN,
                                 kNSDateHelperFormatSQLDateWithTimeEN_shashSeparated,kNSDateHelperFormatSQLDateWithTimeZone,
                                 kNSDateHelperFormatSQLDateWithTimeZone_shashSeparated,kNSDateHelperFormatSQLDateWithTimeZoneEN,
                                 kNSDateHelperFormatSQLDateWithTimeZoneEN_shashSeparated,kNSDateHelperFormatSQLDateWithTimeZoneIT,
                                 kNSDateHelperFormatSQLDateWithTimeZoneIT_shashSeparated, nil];
    
    
    for (NSString *dateFormat in dateFormatsArray) {
        
        [dateFormatter setDateFormat:dateFormat];
        
        NSDate *theDate = [NSDate dateFromString:dateString withFormat:dateFormat];
        
        if (theDate) {
            
            return dateFormat;
        }
    }
    return nil;
}

+ (NSArray*) getSlotTimesFromDate:(NSDate*) date distanceMinutes:(NSInteger) minutes {
    
    if (!date) {
        date = [NSDate date];
    }
    
    if (minutes == 0) {
        minutes = 10;
    }
    
    NSMutableArray *slotTimes = [[NSMutableArray alloc] init];
    
    BOOL step = TRUE;
    while (step){
        
        [slotTimes addObject:date];
        
        if([date minute] == 30 && [date hour] == 23) {
            step = FALSE;
        }
        
        date = [date dateByAddingMinutes:minutes];
    }
    
    
    return slotTimes;
}

+ (NSString *)getUniversalHourFromDateString:(NSString *)string formatterString:(NSString*) formatterString andUppercaseString:(BOOL)uppercaseString {
    
    NSString * dateString = [NSString stringWithString:string];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    if (formatterString) {
        [dateFormatter setDateFormat:formatterString];
    }
    else {
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    NSDate* myDate = [dateFormatter dateFromString:dateString];
    
    NSDate *now = [NSDate date];
    NSTimeInterval time = [myDate timeIntervalSinceDate:now];
    
    if (time < 0) {
        time *=-1;
        
        if (time < 60) {
            if (uppercaseString) {
                return [NSLocalizedString(@"Poco fa", nil) uppercaseString];
            }
            return NSLocalizedString(@"Poco fa", nil);
        } else if (time < 3600) {
            int diff = round(time / 60);
            
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"1 Minuto fa", nil) uppercaseString];
                }
                return NSLocalizedString(@"1 Minuto fa", nil);
            }
            
            if (uppercaseString) {
                return [[NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Minuti fa", nil)] uppercaseString];
            }
            return [NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Minuti fa", nil)];
            
        } else if (time < 86400) {
            int diff = round(time / 60 / 60);
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"1 Ora fa", nil) uppercaseString];
                }
                return NSLocalizedString(@"1 Ora fa", nil);
            }
            if (uppercaseString) {
                return [[NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Ore fa", nil)] uppercaseString];
            }
            return [NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Ore fa", nil)];
        } else {
            NSInteger diff = round(time / 60 / 60 / 24);
            switch (diff) {
                case 1:{
                    if (uppercaseString) {
                        
                        return [[NSString stringWithFormat:@"%@",NSLocalizedString(@"Ieri", nil)] uppercaseString];
                    }
                    return [NSString stringWithFormat:@"%@",NSLocalizedString(@"Ieri", nil)];
                }
                    break;
                case 2:
                case 3:
                case 4:
                case 5:
                case 6: {
                    
                    if (uppercaseString) {
                        return [[NSString stringWithFormat:@"%ld %@", (long)diff, NSLocalizedString(@"Giorni fa", nil)] uppercaseString];
                    }
                    return [NSString stringWithFormat:@"%ld %@", (long)diff, NSLocalizedString(@"Giorni fa", nil)];
                }
                    break;
                default:{
                    NSInteger diffWeeks = round(time / 60 / 60 / 24 / 7);
                    switch (diffWeeks) {
                        case 1:{
                            if (uppercaseString) {
                                return [[NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Settimana fa", nil)] uppercaseString];
                            }
                            return [NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Settimana fa", nil)];
                        }
                            break;
                        case 2:
                        case 3:
                            if (uppercaseString) {
                                return [[NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Settimane fa", nil)] uppercaseString];
                            }
                            return [NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Settimane fa", nil)];
                            break;
                        default:{
                            NSInteger diffMounth = round(time / 60 /60 / 24 / 30);
                            switch (diffMounth) {
                                case 1: {
                                    if (uppercaseString) {
                                        return [[NSString stringWithFormat:@"%ld %@",(long)diffMounth,NSLocalizedString(@"Mese fa", nil)] uppercaseString];
                                    }
                                    return [NSString stringWithFormat:@"%ld %@",(long)diffMounth,NSLocalizedString(@"Mese fa", nil)];
                                }
                                    break;
                                case 2:
                                case 3:
                                case 4:
                                case 5:
                                case 6:
                                case 7:
                                case 8:
                                case 9:
                                case 10:
                                case 11:{
                                    if (uppercaseString) {
                                        return [[NSString stringWithFormat:@"%ld %@",(long)diffMounth,NSLocalizedString(@"Mesi fa", nil)] uppercaseString];
                                    }
                                    return [NSString stringWithFormat:@"%ld %@",(long)diffMounth,NSLocalizedString(@"Mesi fa", nil)];
                                }
                                    break;
                                    
                                default:{
                                    NSInteger diffYears = round(time / 60 /60 / 24 / 365);
                                    switch (diffYears) {
                                        case 1:
                                            if (uppercaseString) {
                                                return [[NSString stringWithFormat:@"%ld %@",(long)diffYears,NSLocalizedString(@"Anno fa", nil)] uppercaseString];
                                            }
                                            return [NSString stringWithFormat:@"%ld %@",(long)diffYears,NSLocalizedString(@"Anno fa", nil)];
                                            break;
                                        default:{
                                            if (uppercaseString) {
                                                return [[NSString stringWithFormat:@"%ld %@",(long)diffYears,NSLocalizedString(@"Anni fa", nil)] uppercaseString];
                                            }
                                            return [NSString stringWithFormat:@"%ld %@",(long)diffYears,NSLocalizedString(@"Anni fa", nil)];
                                        }
                                            break;
                                    }
                                }
                                    break;
                            }
                        }
                            break;
                    }
                }
                    break;
            }
        }
    }
    else {
        if (time < 60) {
            if (uppercaseString) {
                return [NSLocalizedString(@"Tra poco", nil) uppercaseString];
            }
            return NSLocalizedString(@"Tra poco", nil);
        } else if (time < 3600) {
            int diff = round(time / 60);
            
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"Tra 1 minuto", nil) uppercaseString];
                }
                return NSLocalizedString(@"Tra 1 minuto", nil);
            }
            
            if (uppercaseString) {
                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d minuti", nil), diff] uppercaseString];
            }
            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d minuti", nil), diff];
            
        } else if (time < 86400) {
            int diff = round(time / 60 / 60);
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"Tra 1 ora", nil) uppercaseString];
                }
                return NSLocalizedString(@"Tra 1 ora", nil);
            }
            if (uppercaseString) {
                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d ore", nil), diff] uppercaseString];
            }
            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d ore", nil), diff];
        } else {
            NSInteger diff = round(time / 60 / 60 / 24);
            switch (diff) {
                case 1:{
                    if (uppercaseString) {
                        
                        return [[NSString stringWithFormat:@"%@",NSLocalizedString(@"Domani", nil)] uppercaseString];
                    }
                    return [NSString stringWithFormat:@"%@",NSLocalizedString(@"Domani", nil)];
                }
                    break;
                case 2:
                case 3:
                case 4:
                case 5:
                case 6: {
                    
                    if (uppercaseString) {
                        return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d giorni", nil), diff] uppercaseString];
                    }
                    return [NSString stringWithFormat:NSLocalizedString(@"Tra %d giorni", nil), diff];
                }
                    break;
                default:{
                    NSInteger diffWeeks = round(time / 60 / 60 / 24 / 7);
                    switch (diffWeeks) {
                        case 1:{
                            if (uppercaseString) {
                                return [[NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Tra 1 Settimana", nil)] uppercaseString];
                            }
                            return [NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Tra 1 Settimana", nil)];
                        }
                            break;
                        case 2:
                        case 3:
                            if (uppercaseString) {
                                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d settimane", nil), diff] uppercaseString];
                            }
                            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d settimane", nil), diff];
                            break;
                        default:{
                            NSInteger diffMounth = round(time / 60 /60 / 24 / 30);
                            switch (diffMounth) {
                                case 1: {
                                    if (uppercaseString) {
                                        return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d mese", nil), diff] uppercaseString];
                                    }
                                    return [NSString stringWithFormat:NSLocalizedString(@"Tra %d mese", nil), diff];
                                }
                                    break;
                                case 2:
                                case 3:
                                case 4:
                                case 5:
                                case 6:
                                case 7:
                                case 8:
                                case 9:
                                case 10:
                                case 11:{
                                    if (uppercaseString) {
                                        return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d mesi", nil), diff] uppercaseString];
                                    }
                                    return [NSString stringWithFormat:NSLocalizedString(@"Tra %d mesi", nil), diff];
                                }
                                    break;
                                    
                                default:{
                                    NSInteger diffYears = round(time / 60 /60 / 24 / 365);
                                    switch (diffYears) {
                                        case 1:
                                            if (uppercaseString) {
                                                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d anno", nil), diff] uppercaseString];
                                            }
                                            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d anno", nil), diff];
                                            break;
                                        default:{
                                            if (uppercaseString) {
                                                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d anni", nil), diff] uppercaseString];
                                            }
                                            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d anni", nil), diff];
                                        }
                                            break;
                                    }
                                }
                                    break;
                            }
                        }
                            break;
                    }
                }
                    break;
            }
        }
    }
}


- (NSDate *) dateAtStartOfDay
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *) dateAtEndOfDay
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
    return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *) dateBySubtractingHours: (NSInteger) hours {
    
    return [self dateByAddingHours: (hours * -1)];
}

- (NSDate *) dateBySubtractingDays: (NSInteger) days
{
    return [self dateByAddingDays: (days * -1)];
}

- (NSDate *) dateBySubtractingYears: (NSInteger) years {
    
    
    return [self dateByAddingYears: (years * -1)];
}

- (NSDate *)dateToNearestMinutes:(NSInteger)minutes {
    unsigned unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal;
    // Extract components.
    NSDateComponents *time = [[NSCalendar currentCalendar] components:unitFlags fromDate:self];
    NSInteger thisMin = [time minute];
    NSDate *newDate;
    long remain = thisMin % minutes;
    // if less then 3 then round down
    NSInteger dividor = ceil(minutes/2);
    if (remain<dividor){
        // Subtract the remainder of time to the date to round it down evenly
        newDate = [self dateByAddingTimeInterval:-60*(remain)];
    }else{
        // Add the remainder of time to the date to round it up evenly
        newDate = [self dateByAddingTimeInterval:60*(minutes-remain)];
    }
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:newDate];
    [comps setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}
- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedDescending);
}

- (CGFloat) distanceInWeeksToDate:(NSDate *)anotherDate
{
    return [self distanceInDaysToDate:anotherDate]/7;
}

- (CGFloat) distanceInDaysToDate:(NSDate *)anotherDate
{
    return [self distanceInHoursToDate:anotherDate]/24;
}

- (CGFloat) distanceInHoursToDate:(NSDate *)anotherDate
{
    return [self distanceInMinutesToDate:anotherDate]/60;
}

- (CGFloat) distanceInMinutesToDate:(NSDate *)anotherDate
{
    return [self distanceInSeconsToDate:anotherDate]/60;
}

- (CGFloat) distanceInSeconsToDate:(NSDate *)anotherDate
{
    return -[self timeIntervalSinceDate:anotherDate];
}

- (NSString *) monthSymbol {
    
    return [[[NSDate sharedDateFormatter] monthSymbols] objectAtIndex:([self month]-1)];
}

-(NSDate *) toLocalTime
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

-(NSDate *) toGlobalTime
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate*) dateByAddingHours:(NSInteger) hours {
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:self];
    [comps setHour:[comps hour] + hours];
    return [gregorian dateFromComponents:comps];
}

- (NSDate*) dateByAddingDays:(NSInteger) days {
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:self];
    [comps setDay:[comps day] + days];
    return [gregorian dateFromComponents:comps];
}

- (NSDate*) dateByAddingYears:(NSInteger) years {
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:self];
    [comps setYear:[comps year] + years];
    return [gregorian dateFromComponents:comps];
}

- (NSUInteger)daysAgo {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
    // get a midnight version of ourself:
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
    return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo {
    return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
    NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
    NSString *text = nil;
    switch (daysAgo) {
        case 0:
            text = NSLocalizedString(@"Today", nil);
            break;
        case 1:
            text = NSLocalizedString(@"Yesterday", nil);
            break;
        default:
            text = [NSString stringWithFormat:@"%ld days ago", (long)daysAgo];
    }
    return text;
}

- (NSUInteger)hour {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *weekdayComponents = [calendar components:(NSCalendarUnitHour) fromDate:self];
    return [weekdayComponents hour];
}

- (NSUInteger)minute {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *weekdayComponents = [calendar components:(NSCalendarUnitMinute) fromDate:self];
    return [weekdayComponents minute];
}

- (NSUInteger)year {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *weekdayComponents = [calendar components:(NSCalendarUnitYear) fromDate:self];
    return [weekdayComponents year];
}

- (long int)utcTimeStamp{
    return lround(floor([self timeIntervalSince1970]));
}

- (NSUInteger)monthDay {
    
    NSDateComponents *weekdayComponents = [[[self class] sharedCalendar] components:(NSCalendarUnitDay) fromDate:self];
    return [weekdayComponents day];
}

- (NSUInteger)weekday {
    NSDateComponents *weekdayComponents = [[[self class] sharedCalendar] components:(NSCalendarUnitWeekday) fromDate:self];
    return [weekdayComponents weekday];
}

- (NSUInteger)month {
    NSDateComponents *weekdayComponents = [[[self class] sharedCalendar] components:(NSCalendarUnitMonth) fromDate:self];
    return [weekdayComponents month];
}

- (NSUInteger)weekNumber {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitWeekOfMonth) fromDate:self];
    return [dateComponents weekOfYear];
}

- (NSString *)stringWithFormat:(NSString *)format {
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:format];
    NSString *timestamp_str = [outputFormatter stringFromDate:self];
    
    return timestamp_str;
}

- (NSString *)stringWithFormat:(NSString *)format timeZone:(NSTimeZone*) timezone {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:timezone];
    
    NSString *timestamp_str = [formatter stringFromDate:self];
    return timestamp_str;
}

- (NSString *)string {
    return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:dateStyle];
    [formatter setTimeStyle:timeStyle];
    NSString *outputString = [formatter stringFromDate:self];
    return outputString;
}

- (NSDate *)beginningOfWeek {
    // largely borrowed from "Date and Time Programming Guide for Cocoa"
    // we'll use the default calendar and hope for the best
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDate *beginningOfWeek = nil;
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth startDate:&beginningOfWeek
                           interval:NULL forDate:self];
    if (ok) {
        return beginningOfWeek;
    }
    // couldn't calc via range, so try to grab Sunday, assuming gregorian style
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    /*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
    beginningOfWeek = nil;
    beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];

    //normalize to midnight, extract the year, month, and day components and create a new date from those components.
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                               fromDate:beginningOfWeek];
    return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
    NSCalendar *calendar = [[self class] sharedCalendar];
    // Get the weekday component of the current date
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                               fromDate:self];
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
    NSCalendar *calendar = [[self class] sharedCalendar];
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    // to get the end of week for a particular date, add (7 - weekday) days
    [componentsToAdd setDay:(7 - [weekdayComponents weekday])];
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];

    return endOfWeek;
}

- (BOOL)isSameDayAsDate:(NSDate*)otherDate {
    
    // From progrmr's answer...
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:otherDate];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}


- (NSString *)getUniversalHourUppercaseString:(BOOL)uppercaseString {
    
    NSDate *now = [NSDate date];
    NSTimeInterval time = [self timeIntervalSinceDate:now];
    
    if (time < 0) {
        time *=-1;
        
        if (time < 60) {
            if (uppercaseString) {
                return [NSLocalizedString(@"Poco fa", nil) uppercaseString];
            }
            return NSLocalizedString(@"Poco fa", nil);
        } else if (time < 3600) {
            int diff = round(time / 60);
            
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"1 Minuto fa", nil) uppercaseString];
                }
                return NSLocalizedString(@"1 Minuto fa", nil);
            }
            
            if (uppercaseString) {
                return [[NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Minuti fa", nil)] uppercaseString];
            }
            return [NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Minuti fa", nil)];
            
        } else if (time < 86400) {
            int diff = round(time / 60 / 60);
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"1 Ora fa", nil) uppercaseString];
                }
                return NSLocalizedString(@"1 Ora fa", nil);
            }
            if (uppercaseString) {
                return [[NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Ore fa", nil)] uppercaseString];
            }
            return [NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Ore fa", nil)];
        } else {
            NSInteger diff = round(time / 60 / 60 / 24);
            switch (diff) {
                case 1:{
                    if (uppercaseString) {
                        
                        return [[NSString stringWithFormat:@"%@",NSLocalizedString(@"Ieri", nil)] uppercaseString];
                    }
                    return [NSString stringWithFormat:@"%@",NSLocalizedString(@"Ieri", nil)];
                }
                    break;
                case 2:
                case 3:
                case 4:
                case 5:
                case 6: {
                    
                    if (uppercaseString) {
                        return [[NSString stringWithFormat:@"%ld %@", (long)diff, NSLocalizedString(@"Giorni fa", nil)] uppercaseString];
                    }
                    return [NSString stringWithFormat:@"%ld %@", (long)diff, NSLocalizedString(@"Giorni fa", nil)];
                }
                    break;
                default:{
                    NSInteger diffWeeks = round(time / 60 / 60 / 24 / 7);
                    switch (diffWeeks) {
                        case 1:{
                            if (uppercaseString) {
                                return [[NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Settimana fa", nil)] uppercaseString];
                            }
                            return [NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Settimana fa", nil)];
                        }
                            break;
                        case 2:
                        case 3:
                            if (uppercaseString) {
                                return [[NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Settimane fa", nil)] uppercaseString];
                            }
                            return [NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Settimane fa", nil)];
                            break;
                        default:{
                            NSInteger diffMounth = round(time / 60 /60 / 24 / 30);
                            switch (diffMounth) {
                                case 1: {
                                    if (uppercaseString) {
                                        return [[NSString stringWithFormat:@"%ld %@",(long)diffMounth,NSLocalizedString(@"Mese fa", nil)] uppercaseString];
                                    }
                                    return [NSString stringWithFormat:@"%ld %@",(long)diffMounth,NSLocalizedString(@"Mese fa", nil)];
                                }
                                    break;
                                case 2:
                                case 3:
                                case 4:
                                case 5:
                                case 6:
                                case 7:
                                case 8:
                                case 9:
                                case 10:
                                case 11:{
                                    if (uppercaseString) {
                                        return [[NSString stringWithFormat:@"%ld %@",(long)diffMounth,NSLocalizedString(@"Mesi fa", nil)] uppercaseString];
                                    }
                                    return [NSString stringWithFormat:@"%ld %@",(long)diffMounth,NSLocalizedString(@"Mesi fa", nil)];
                                }
                                    break;
                                    
                                default:{
                                    NSInteger diffYears = round(time / 60 /60 / 24 / 365);
                                    switch (diffYears) {
                                        case 1:
                                            if (uppercaseString) {
                                                return [[NSString stringWithFormat:@"%ld %@",(long)diffYears,NSLocalizedString(@"Anno fa", nil)] uppercaseString];
                                            }
                                            return [NSString stringWithFormat:@"%ld %@",(long)diffYears,NSLocalizedString(@"Anno fa", nil)];
                                            break;
                                        default:{
                                            if (uppercaseString) {
                                                return [[NSString stringWithFormat:@"%ld %@",(long)diffYears,NSLocalizedString(@"Anni fa", nil)] uppercaseString];
                                            }
                                            return [NSString stringWithFormat:@"%ld %@",(long)diffYears,NSLocalizedString(@"Anni fa", nil)];
                                        }
                                            break;
                                    }
                                }
                                    break;
                            }
                        }
                            break;
                    }
                }
                    break;
            }
        }
    }
    else {
        if (time < 60) {
            if (uppercaseString) {
                return [NSLocalizedString(@"Tra poco", nil) uppercaseString];
            }
            return NSLocalizedString(@"Tra poco", nil);
        } else if (time < 3600) {
            int diff = round(time / 60);
            
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"Tra 1 minuto", nil) uppercaseString];
                }
                return NSLocalizedString(@"Tra 1 minuto", nil);
            }
            
            if (uppercaseString) {
                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d minuti", nil), diff] uppercaseString];
            }
            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d minuti", nil), diff];
            
        } else if (time < 86400) {
            int diff = round(time / 60 / 60);
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"Tra 1 ora", nil) uppercaseString];
                }
                return NSLocalizedString(@"Tra 1 ora", nil);
            }
            if (uppercaseString) {
                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d ore", nil), diff] uppercaseString];
            }
            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d ore", nil), diff];
        } else {
            NSInteger diff = round(time / 60 / 60 / 24);
            switch (diff) {
                case 1:{
                    if (uppercaseString) {
                        
                        return [[NSString stringWithFormat:@"%@",NSLocalizedString(@"Domani", nil)] uppercaseString];
                    }
                    return [NSString stringWithFormat:@"%@",NSLocalizedString(@"Domani", nil)];
                }
                    break;
                case 2:
                case 3:
                case 4:
                case 5:
                case 6: {
                    
                    if (uppercaseString) {
                        return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d giorni", nil), diff] uppercaseString];
                    }
                    return [NSString stringWithFormat:NSLocalizedString(@"Tra %d giorni", nil), diff];
                }
                    break;
                default:{
                    NSInteger diffWeeks = round(time / 60 / 60 / 24 / 7);
                    switch (diffWeeks) {
                        case 1:{
                            if (uppercaseString) {
                                return [[NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Tra 1 Settimana", nil)] uppercaseString];
                            }
                            return [NSString stringWithFormat:@"%ld %@",(long)diffWeeks,NSLocalizedString(@"Tra 1 Settimana", nil)];
                        }
                            break;
                        case 2:
                        case 3:
                            if (uppercaseString) {
                                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d settimane", nil), diff] uppercaseString];
                            }
                            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d settimane", nil), diff];
                            break;
                        default:{
                            NSInteger diffMounth = round(time / 60 /60 / 24 / 30);
                            switch (diffMounth) {
                                case 1: {
                                    if (uppercaseString) {
                                        return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d mese", nil), diff] uppercaseString];
                                    }
                                    return [NSString stringWithFormat:NSLocalizedString(@"Tra %d mese", nil), diff];
                                }
                                    break;
                                case 2:
                                case 3:
                                case 4:
                                case 5:
                                case 6:
                                case 7:
                                case 8:
                                case 9:
                                case 10:
                                case 11:{
                                    if (uppercaseString) {
                                        return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d mesi", nil), diff] uppercaseString];
                                    }
                                    return [NSString stringWithFormat:NSLocalizedString(@"Tra %d mesi", nil), diff];
                                }
                                    break;
                                    
                                default:{
                                    NSInteger diffYears = round(time / 60 /60 / 24 / 365);
                                    switch (diffYears) {
                                        case 1:
                                            if (uppercaseString) {
                                                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d anno", nil), diff] uppercaseString];
                                            }
                                            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d anno", nil), diff];
                                            break;
                                        default:{
                                            if (uppercaseString) {
                                                return [[NSString stringWithFormat:NSLocalizedString(@"Tra %d anni", nil), diff] uppercaseString];
                                            }
                                            return [NSString stringWithFormat:NSLocalizedString(@"Tra %d anni", nil), diff];
                                        }
                                            break;
                                    }
                                }
                                    break;
                            }
                        }
                            break;
                    }
                }
                    break;
            }
        }
    }
}

- (NSString *)getNotificationUniversalHourUppercaseString:(BOOL)uppercaseString {
    
    NSDate *now = [NSDate date];
    NSTimeInterval time = [self timeIntervalSinceDate:now];
    
    if (time < 0) {
        time *=-1;
        
        if (time < 60) {
            if (uppercaseString) {
                return [NSLocalizedString(@"Poco fa", nil) uppercaseString];
            }
            return NSLocalizedString(@"Poco fa", nil);
        } else if (time < 3600) {
            int diff = round(time / 60);
            
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"1 Minuto fa", nil) uppercaseString];
                }
                return NSLocalizedString(@"1 Minuto fa", nil);
            }
            
            if (uppercaseString) {
                return [[NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Minuti fa", nil)] uppercaseString];
            }
            return [NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Minuti fa", nil)];
            
        } else if (time < 86400) {
            int diff = round(time / 60 / 60);
            if (diff == 1) {
                if (uppercaseString) {
                    return [NSLocalizedString(@"1 Ora fa", nil) uppercaseString];
                }
                return NSLocalizedString(@"1 Ora fa", nil);
            }
            if (uppercaseString) {
                return [[NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Ore fa", nil)] uppercaseString];
            }
            return [NSString stringWithFormat:@"%d %@", diff, NSLocalizedString(@"Ore fa", nil)];
        } else {
            NSInteger diff = round(time / 60 / 60 / 24);
            switch (diff) {
                case 1:{
                    if (uppercaseString) {
                        
                        return [[NSString stringWithFormat:@"%@",NSLocalizedString(@"Ieri", nil)] uppercaseString];
                    }
                    return [NSString stringWithFormat:@"%@",NSLocalizedString(@"Ieri", nil)];
                }
                    break;
                case 2:
                case 3:
                case 4:
                case 5:
                case 6: {
                    
                    if (uppercaseString) {
                        return [[NSString stringWithFormat:@"%ld %@", (long)diff, NSLocalizedString(@"Giorni fa", nil)] uppercaseString];
                    }
                    return [NSString stringWithFormat:@"%ld %@", (long)diff, NSLocalizedString(@"Giorni fa", nil)];
                }
                    break;
                default:{
                    
                    if (uppercaseString) {
                        return [[self stringWithFormat:@"d MMM"] uppercaseString];
                    }
                    return [self stringWithFormat:@"d MMM"];
                    
                }
                    break;
            }
        }
    }
    return @"";
}
@end
