//
//  KMDatePickerDateModel.h
//  KMDatePicker
//
//  Created by 黄建武 on 15/10/6.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMDatePickerDateModel : NSObject
@property (copy, nonatomic) NSString *year;
@property (copy, nonatomic) NSString *month;
@property (copy, nonatomic) NSString *day;
@property (copy, nonatomic) NSString *hour;
@property (copy, nonatomic) NSString *minute;
@property (copy, nonatomic) NSString *weekdayName;

- (instancetype)initWithDate:(NSDate *)date;

@end
