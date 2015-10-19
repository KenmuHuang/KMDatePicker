//
//  ViewController.m
//  KMDatePicker
//
//  Created by KenmuHuang on 15/10/6.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import "ViewController.h"
#import "DateHelper.h"
#import "NSDate+CalculateDay.h"

@interface ViewController ()
- (void)layoutUI;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutUI {
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect = CGRectMake(0.0, 0.0, rect.size.width, 216.0);
    //年月日时分
    KMDatePicker *datePicker = [[KMDatePicker alloc]
                                initWithFrame:rect
                                delegate:self
                                datePickerStyle:KMDatePickerStyleYearMonthDayHourMinute];
    _txtFYearMonthDayHourMinute.inputView = datePicker;
    _txtFYearMonthDayHourMinute.delegate = self;
    
    //年月日
    datePicker = [[KMDatePicker alloc]
                  initWithFrame:rect
                  delegate:self
                  datePickerStyle:KMDatePickerStyleYearMonthDay];
    _txtFYearMonthDay.inputView = datePicker;
    _txtFYearMonthDay.delegate = self;
    
    //月日时分
    datePicker = [[KMDatePicker alloc]
                  initWithFrame:rect
                  delegate:self
                  datePickerStyle:KMDatePickerStyleMonthDayHourMinute];
    _txtFMonthDayHourMinute.inputView = datePicker;
    _txtFMonthDayHourMinute.delegate = self;
    
    //时分
    datePicker = [[KMDatePicker alloc]
                  initWithFrame:rect
                  delegate:self
                  datePickerStyle:KMDatePickerStyleHourMinute];
    _txtFHourMinute.inputView = datePicker;
    _txtFHourMinute.delegate = self;
    
    //年月日时分；限制时间范围
    datePicker = [[KMDatePicker alloc]
                  initWithFrame:rect
                  delegate:self
                  datePickerStyle:KMDatePickerStyleYearMonthDayHourMinute];
    datePicker.minLimitedDate = [[DateHelper localeDate] addMonthAndDay:-24 days:0];
    datePicker.maxLimitedDate = [datePicker.minLimitedDate addMonthAndDay:48 days:0];
    _txtFLimitedDate.inputView = datePicker;
    _txtFLimitedDate.delegate = self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _txtFCurrent = textField;
}

#pragma mark - KMDatePickerDelegate
- (void)datePicker:(KMDatePicker *)datePicker didSelectDate:(KMDatePickerDateModel *)datePickerDate {
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@ %@",
                         datePickerDate.year,
                         datePickerDate.month,
                         datePickerDate.day,
                         datePickerDate.hour,
                         datePickerDate.minute,
                         datePickerDate.weekdayName
                         ];
    _txtFCurrent.text = dateStr;
}

@end
