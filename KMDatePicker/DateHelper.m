//
//  DateHelper.m
//  KMDatePicker
//
//  Created by KenmuHuang on 15/10/8.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

+ (NSDate *)localeDate {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    return [date dateByAddingTimeInterval:interval];
}

+ (NSDate *)dateFromString:(NSString *)dateStr format:(NSString *)format {
    return [self dateFromString:dateStr
                     withFormat:format
                      isBeijing:NO];
}

+ (NSString *)dateToString:(NSDate *)date format:(NSString *)format {
    return [self dateToString:date
                   withFormat:format
                    isBeijing:NO];
}

+ (NSDate *)dateFromBeijingString:(NSString *)dateStr format:(NSString *)format {
    return [self dateFromString:dateStr
                     withFormat:format
                      isBeijing:YES];
}

+ (NSString *)dateToBeijingString:(NSDate *)date format:(NSString *)format {
    return [self dateToString:date
                   withFormat:format
                    isBeijing:YES];
}

+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                     day:(NSInteger)day
                    hour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.calendar = calendar;
    components.timeZone = kTimeZoneUTC;
    components.year = year;
    components.month = month;
    components.day = day;
    components.hour = hour;
    components.minute = minute;
    components.second = second;

    return [components date];
}

+ (NSDate *)dateWithHour:(NSInteger)hour minute:(NSInteger)minute {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:now];
    components.timeZone = kTimeZoneUTC;
    components.hour = hour;
    components.minute = minute;

    NSDate *newDate = [calendar dateFromComponents:components];
    return newDate;
}

+ (NSDate *)dateWithTime:(NSString *)time {
    NSArray<NSString *> *timeArray = [time componentsSeparatedByString:@":"];
    if (timeArray.count != 2) {
        return nil;
    }

    NSInteger hour = timeArray[0].integerValue;
    NSInteger minute = timeArray[1].integerValue;
    return [self dateWithHour:hour minute:minute];
}

#pragma mark - Private Method
+ (NSDate *)dateFromString:(NSString *)dateStr withFormat:(NSString *)format isBeijing:(BOOL)isBeijing {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeZone = isBeijing ? kTimeZoneBeijing : kTimeZoneUTC;
    formatter.dateFormat = format ?: @"yyyy-MM-dd HH:mm";
    return [formatter dateFromString:dateStr];
}

+ (NSString *)dateToString:(NSDate *)date withFormat:(NSString *)format isBeijing:(BOOL)isBeijing {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeZone = isBeijing ? kTimeZoneBeijing : kTimeZoneUTC;
    formatter.dateFormat = format ?: @"yyyy-MM-dd HH:mm";
    return [formatter stringFromDate:date];
}

+ (NSString *)timeFormatFromSeconds:(NSTimeInterval)seconds {
    NSInteger secondsInt = (NSInteger)seconds;
    NSString *hour = [NSString stringWithFormat:@"%02ld", secondsInt / 3600];
    NSString *minutes = [NSString stringWithFormat:@"%02ld", (secondsInt %  3600) / 60];
    NSString *second = [NSString stringWithFormat:@"%02ld", secondsInt % 60];
    return [NSString stringWithFormat:@"%@:%@:%@", hour, minutes, second];
}

+ (NSInteger )todayTimeMark {
    return [[self dateToString:[NSDate date] format:@"yyyyMMdd"] integerValue];
}

@end
