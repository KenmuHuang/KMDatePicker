//
//  DateHelper.h
//  KMDatePicker
//
//  Created by KenmuHuang on 15/10/8.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTimeZoneUTC ([NSTimeZone timeZoneWithAbbreviation:@"UTC"])
#define kTimeZoneBeijing ([NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"])

@interface DateHelper : NSObject
/**
 *  获取本地当前时间
 *
 *  @return 本地当前时间
 */
+ (NSDate *)localeDate;

/**
 *  根据时间字符串和其格式，获取对应的时间
 *
 *  @param dateStr 时间字符串
 *  @param format  时间字符串格式（默认值为@"yyyy-MM-dd HH:mm"）
 *
 *  @return 对应的时间
 */
+ (NSDate *)dateFromString:(NSString *)dateStr format:(NSString *)format;

/**
 *  根据时间和其格式，获取对应的时间字符串
 *
 *  @param date    时间
 *  @param format  时间字符串格式（默认值为@"yyyy-MM-dd HH:mm"）
 *
 *  @return 对应的时间字符串
 */
+ (NSString *)dateToString:(NSDate *)date format:(NSString *)format;

/// 根据时间字符串和其格式，获取对应的时间（北京时间）
/// @param dateStr 时间字符串
/// @param format  时间字符串格式（默认值为@"yyyy-MM-dd HH:mm"）
/// @return
+ (NSDate *)dateFromBeijingString:(NSString *)dateStr format:(NSString *)format;

///
/// @param date 时间
/// @param format 时间字符串格式（默认值为@"yyyy-MM-dd HH:mm"）
/// @return 对应的时间字符串
+ (NSString *)dateToBeijingString:(NSDate *)date format:(NSString *)format;

/// 根据「年、月、日、时、分、秒」，获取对应的时间
/// @param year 年
/// @param month 月
/// @param day 日
/// @param hour 时
/// @param minute 分
/// @param second 秒
/// @return 对应的时间
+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                     day:(NSInteger)day
                    hour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second;

/// 根据「时、分」，获取对应的时间
/// @param hour 时
/// @param minute 分
/// @return 对应的时间
+ (NSDate *)dateWithHour:(NSInteger)hour minute:(NSInteger)minute;

/// 根据「时:分」字符串，获取对应的时间
/// @param time 「时:分」字符串
/// @return 对应的时间
+ (NSDate *)dateWithTime:(NSString *)time;

/// 根据秒数，获取对应格式化的时间字符串；例如：90 秒对应 00:01:30
/// @param seconds 秒数
/// @return 对应格式化的时间字符串
+ (NSString *)timeFormatFromSeconds:(NSTimeInterval)seconds;

///计算今天时间,比如 现在时间转换成 20200919 ,用于比较判断当日时间和处理逻辑
+ (NSInteger )todayTimeMark;

@end
