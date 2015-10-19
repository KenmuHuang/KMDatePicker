//
//  KMDatePicker.h
//  KMDatePicker
//
//  Created by 黄建武 on 15/10/6.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMDatePickerDateModel.h"

typedef NS_ENUM(NSUInteger, KMDatePickerStyle) {
    KMDatePickerStyleYearMonthDayHourMinute,
    KMDatePickerStyleYearMonthDay,
    KMDatePickerStyleMonthDayHourMinute,
    KMDatePickerStyleHourMinute
};

@protocol KMDatePickerDelegate;
@interface KMDatePicker : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) id<KMDatePickerDelegate> delegate;
@property (assign, nonatomic) KMDatePickerStyle datePickerStyle;
@property (strong, nonatomic) NSDate *minLimitedDate; //最小限制时间；默认值为1970-01-01 00:00
@property (strong, nonatomic) NSDate *maxLimitedDate; //最大限制时间；默认值为2060-12-31 23:59
@property (strong, nonatomic) NSDate *scrollToDate; //滚动到指定时间；默认值为当前时间

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<KMDatePickerDelegate>)delegate datePickerStyle:(KMDatePickerStyle)datePickerStyle;

@end

@protocol KMDatePickerDelegate <NSObject>
@required
- (void)datePicker:(KMDatePicker *)datePicker didSelectDate:(KMDatePickerDateModel *)datePickerDate;

@end