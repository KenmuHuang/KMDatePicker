//
//  KMDatePickerDateModel.m
//  KMDatePicker
//
//  Created by KenmuHuang on 15/10/6.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import "KMDatePickerDateModel.h"
#import "NSDate+CalculateDay.h"

@implementation KMDatePickerDateModel

- (instancetype)initWithDate:(NSDate *)date {
    if (self = [super init]) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        formatter.dateFormat = @"yyyyMMddHHmm";
        NSString *dateStr = [formatter stringFromDate:date];
        
        _year = [dateStr substringWithRange:NSMakeRange(0, 4)];
        _month = [dateStr substringWithRange:NSMakeRange(4, 2)];
        _day = [dateStr substringWithRange:NSMakeRange(6, 2)];
        _hour = [dateStr substringWithRange:NSMakeRange(8, 2)];
        _minute = [dateStr substringWithRange:NSMakeRange(10, 2)];
        _weekdayName = [date weekdayNameCN:YES];
    }
    return self;
}

@end
