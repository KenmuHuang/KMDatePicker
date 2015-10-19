//
//  ViewController.h
//  KMDatePicker
//
//  Created by 黄建武 on 15/10/6.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMDatePicker.h"

@interface ViewController : UIViewController <UITextFieldDelegate, KMDatePickerDelegate>
@property (strong, nonatomic) UITextField *txtFCurrent;

@property (strong, nonatomic) IBOutlet UITextField *txtFYearMonthDayHourMinute;
@property (strong, nonatomic) IBOutlet UITextField *txtFMonthDayHourMinute;
@property (strong, nonatomic) IBOutlet UITextField *txtFYearMonthDay;
@property (strong, nonatomic) IBOutlet UITextField *txtFHourMinute;
@property (strong, nonatomic) IBOutlet UITextField *txtFLimitedDate;

@end

