//
//  ViewController.h
//  KMDatePicker
//
//  Created by KenmuHuang on 15/10/6.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMDatePicker.h"

@interface ViewController : UIViewController <UITextFieldDelegate, KMDatePickerDelegate>
@property (nonatomic, strong) UITextField *txtFCurrent;

@property (nonatomic, weak) IBOutlet UITextField *txtFYearMonthDayHourMinute;
@property (nonatomic, weak) IBOutlet UITextField *txtFMonthDayHourMinute;
@property (nonatomic, weak) IBOutlet UITextField *txtFYearMonthDay;
@property (nonatomic, weak) IBOutlet UITextField *txtFHourMinute;
@property (nonatomic, weak) IBOutlet UITextField *txtFLimitedDate;

@end

