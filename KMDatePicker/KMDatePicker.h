//
//  KMDatePicker.h
//  KMDatePicker
//
//  Created by KenmuHuang on 15/10/6.
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
@property (nonatomic, weak) id<KMDatePickerDelegate> delegate;
@property (nonatomic, assign) KMDatePickerStyle datePickerStyle;
@property (nonatomic, strong) NSDate *minLimitedDate; ///< 最小限制时间；默认值为1970-01-01 00:00
@property (nonatomic, strong) NSDate *maxLimitedDate; ///< 最大限制时间；默认值为2060-12-31 23:59
@property (nonatomic, strong) NSDate *defaultLimitedDate; ///< 默认限制时间；默认值为最小限制时间，当选择时间不在指定范围，就滚动到此默认限制时间
@property (nonatomic, strong) NSDate *scrollToDate; ///< 滚动到指定时间；默认值为当前时间

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<KMDatePickerDelegate>)delegate datePickerStyle:(KMDatePickerStyle)datePickerStyle;

@end

@protocol KMDatePickerDelegate <NSObject>
@required
- (void)datePicker:(KMDatePicker *)datePicker didSelectDate:(KMDatePickerDateModel *)datePickerDate;

@end