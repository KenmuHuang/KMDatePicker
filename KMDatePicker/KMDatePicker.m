//
//  KMDatePicker.m
//  KMDatePicker:（自定义支持多种格式可控范围的时间选择器控件）
//
//  Created by 黄建武 on 15/10/6.
//  Copyright © 2015年 Kenmu. All rights reserved.
//

#import "KMDatePicker.h"
#import "NSDate+CalculateDay.h"
#import "DateHelper.h"

#define kDefaultMinLimitedDate @"1970-01-01 00:00"
#define kDefaultMaxLimitedDate @"2060-12-31 23:59"
#define kMonthCountOfEveryYear 12
#define kHourCountOfEveryDay 24
#define kMinuteCountOfEveryHour 60
#define kRowDisabledStatusColor [UIColor redColor]
#define kRowNormalStatusColor [UIColor blackColor]
#define kWidthOfTotal self.frame.size.width
#define kHeightOfButtonContentView 35.0
#define kButtonNormalStatusColor [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]

@interface KMDatePicker () {
    UIPickerView *pikV;
    
    //最小和最大限制时间、滚动到指定时间实体对象实例
    KMDatePickerDateModel *datePickerDateMinLimited;
    KMDatePickerDateModel *datePickerDateMaxLimited;
    KMDatePickerDateModel *datePickerDateScrollTo;
    
    //存储时间数据源的数组
    NSMutableArray *mArrYear;
    NSMutableArray *mArrMonth;
    NSMutableArray *mArrDay;
    NSMutableArray *mArrHour;
    NSMutableArray *mArrMinute;
    
    //时间数据源的数组中，选中元素的索引
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger minuteIndex;
}

- (void)addUnitLabel:(NSString *)text withPointX:(CGFloat)pointX;
- (NSUInteger)daysOfMonth;
- (void)reloadDayArray;
- (void)loadData;
- (void)scrollToDateIndexPosition;
- (void)playDelegateAfterSelectedRow;
- (BOOL)validatedDate:(NSDate *)date;
- (BOOL)canShowScrollToNowButton;
- (void)cancel:(UIButton *)sender;
- (void)scrollToNowDateIndexPosition:(UIButton *)sender;
- (void)confirm:(UIButton *)sender;
- (UIColor *)monthRowTextColor:(NSInteger)row;
- (UIColor *)dayRowTextColor:(NSInteger)row;
- (UIColor *)hourRowTextColor:(NSInteger)row;
- (UIColor *)minuteRowTextColor:(NSInteger)row;

@end

@implementation KMDatePicker

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<KMDatePickerDelegate>)delegate datePickerStyle:(KMDatePickerStyle)datePickerStyle {
    _delegate = delegate;
    _datePickerStyle = datePickerStyle;
    return [self initWithFrame:frame];
}

#pragma mark - 自定义方法
- (void)addUnitLabel:(NSString *)text withPointX:(CGFloat)pointX {
    CGFloat pointY = pikV.frame.size.height/2 - 10.0 + kHeightOfButtonContentView;
    UILabel *lblUnit = [[UILabel alloc] initWithFrame:CGRectMake(pointX, pointY, 20.0, 20.0)];
    lblUnit.text = text;
    lblUnit.textAlignment = NSTextAlignmentCenter;
    lblUnit.textColor = [UIColor blackColor];
    lblUnit.backgroundColor = [UIColor clearColor];
    lblUnit.font = [UIFont systemFontOfSize:18.0];
    lblUnit.layer.shadowColor = [[UIColor whiteColor] CGColor];
    lblUnit.layer.shadowOpacity = 0.5;
    lblUnit.layer.shadowRadius = 5.0;
    [self addSubview:lblUnit];
}

- (NSUInteger)daysOfMonth {
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-01 00:00", mArrYear[yearIndex], mArrMonth[monthIndex]];
    return [[DateHelper dateFromString:dateStr withFormat:@"yyyy-MM-dd HH:mm"] daysOfMonth];
}

- (void)reloadDayArray {
    mArrDay = [NSMutableArray new];
    for (NSUInteger i=1, len=[self daysOfMonth]; i<=len; i++) {
        [mArrDay addObject:[NSString stringWithFormat:@"%02ld", (long)i]];
    }
}

- (void)loadData {
    //初始化最小和最大限制时间、滚动到指定时间实体对象实例
    if (!_minLimitedDate) {
        _minLimitedDate = [DateHelper dateFromString:kDefaultMinLimitedDate withFormat:nil];
    }
    datePickerDateMinLimited = [[KMDatePickerDateModel alloc] initWithDate:_minLimitedDate];
    
    if (!_maxLimitedDate) {
        _maxLimitedDate = [DateHelper dateFromString:kDefaultMaxLimitedDate withFormat:nil];
    }
    datePickerDateMaxLimited = [[KMDatePickerDateModel alloc] initWithDate:_maxLimitedDate];
    
    //滚动到指定时间；默认值为当前时间。如果是使用自定义时间小于最小限制时间，这时就以最小限制时间为准；如果是使用自定义时间大于最大限制时间，这时就以最大限制时间为准
    if (!_scrollToDate) {
        _scrollToDate = [DateHelper localeDate];
    }
    if ([_scrollToDate compare:_minLimitedDate] == NSOrderedAscending) {
        _scrollToDate = _minLimitedDate;
    } else if ([_scrollToDate compare:_maxLimitedDate] == NSOrderedDescending) {
        _scrollToDate = _maxLimitedDate;
    }
    datePickerDateScrollTo = [[KMDatePickerDateModel alloc] initWithDate:_scrollToDate];
    
    //初始化存储时间数据源的数组
    //年
    mArrYear = [NSMutableArray new];
    for (NSInteger beginVal=[datePickerDateMinLimited.year integerValue], endVal=[datePickerDateMaxLimited.year integerValue]; beginVal<=endVal; beginVal++) {
        [mArrYear addObject:[NSString stringWithFormat:@"%ld", (long)beginVal]];
    }
    yearIndex = [datePickerDateScrollTo.year integerValue] - [datePickerDateMinLimited.year integerValue];
    
    //月
    mArrMonth = [[NSMutableArray alloc] initWithCapacity:kMonthCountOfEveryYear];
    for (NSInteger i=1; i<=kMonthCountOfEveryYear; i++) {
        [mArrMonth addObject:[NSString stringWithFormat:@"%02ld", (long)i]];
    }
    monthIndex = [datePickerDateScrollTo.month integerValue] - 1;
    
    //日
    [self reloadDayArray];
    dayIndex = [datePickerDateScrollTo.day integerValue] - 1;
    
    //时
    mArrHour = [[NSMutableArray alloc] initWithCapacity:kHourCountOfEveryDay];
    for (NSInteger i=0; i<kHourCountOfEveryDay; i++) {
        [mArrHour addObject:[NSString stringWithFormat:@"%02ld", (long)i]];
    }
    hourIndex = [datePickerDateScrollTo.hour integerValue];
    
    //分
    mArrMinute = [[NSMutableArray alloc] initWithCapacity:kMinuteCountOfEveryHour];
    for (NSInteger i=0; i<kMinuteCountOfEveryHour; i++) {
        [mArrMinute addObject:[NSString stringWithFormat:@"%02ld", (long)i]];
    }
    minuteIndex = [datePickerDateScrollTo.minute integerValue];
}

- (void)scrollToDateIndexPosition {
    NSArray *arrIndex;
    switch (_datePickerStyle) {
        case KMDatePickerStyleYearMonthDayHourMinute: {
            arrIndex = @[
                         [NSNumber numberWithInteger:yearIndex],
                         [NSNumber numberWithInteger:monthIndex],
                         [NSNumber numberWithInteger:dayIndex],
                         [NSNumber numberWithInteger:hourIndex],
                         [NSNumber numberWithInteger:minuteIndex]
                         ];
            break;
        }
        case KMDatePickerStyleYearMonthDay: {
            arrIndex = @[
                         [NSNumber numberWithInteger:yearIndex],
                         [NSNumber numberWithInteger:monthIndex],
                         [NSNumber numberWithInteger:dayIndex]
                         ];
            break;
        }
        case KMDatePickerStyleMonthDayHourMinute: {
            arrIndex = @[
                         [NSNumber numberWithInteger:monthIndex],
                         [NSNumber numberWithInteger:dayIndex],
                         [NSNumber numberWithInteger:hourIndex],
                         [NSNumber numberWithInteger:minuteIndex]
                         ];
            break;
        }
        case KMDatePickerStyleHourMinute: {
            arrIndex = @[
                         [NSNumber numberWithInteger:hourIndex],
                         [NSNumber numberWithInteger:minuteIndex]
                         ];
            break;
        }
    }

    for (NSUInteger i=0, len=arrIndex.count; i<len; i++) {
        [pikV selectRow:[arrIndex[i] integerValue] inComponent:i animated:YES];
    }
}

- (BOOL)validatedDate:(NSDate *)date {
    NSString *minDateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",
                            datePickerDateMinLimited.year,
                            datePickerDateMinLimited.month,
                            datePickerDateMinLimited.day,
                            datePickerDateMinLimited.hour,
                            datePickerDateMinLimited.minute
                            ];
    
    return !([date compare:[DateHelper dateFromString:minDateStr withFormat:nil]] == NSOrderedAscending ||
             [date compare:_maxLimitedDate] == NSOrderedDescending);
}

- (BOOL)canShowScrollToNowButton {
    return [self validatedDate:[DateHelper localeDate]];
}

- (void)cancel:(UIButton *)sender {
    UIViewController *delegateVC = (UIViewController *)self.delegate;
    [delegateVC.view endEditing:YES];
}

- (void)scrollToNowDateIndexPosition:(UIButton *)sender {
    //为了区别最大最小限制范围外行的标签颜色，这里需要重新加载所有组件列
    [pikV reloadAllComponents];
    
    _scrollToDate = [DateHelper localeDate];
    datePickerDateScrollTo = [[KMDatePickerDateModel alloc] initWithDate:_scrollToDate];
    yearIndex = [datePickerDateScrollTo.year integerValue] - [datePickerDateMinLimited.year integerValue];
    monthIndex = [datePickerDateScrollTo.month integerValue] - 1;
    dayIndex = [datePickerDateScrollTo.day integerValue] - 1;
    hourIndex = [datePickerDateScrollTo.hour integerValue];
    minuteIndex = [datePickerDateScrollTo.minute integerValue];
    [self scrollToDateIndexPosition];
}

- (void)confirm:(UIButton *)sender {
    [self playDelegateAfterSelectedRow];
    
    [self cancel:sender];
}

- (UIColor *)monthRowTextColor:(NSInteger)row {
    UIColor *color = kRowNormalStatusColor;
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-01 00:00",
                         mArrYear[yearIndex],
                         mArrMonth[row]
                         ];
    NSDate *date = [DateHelper dateFromString:dateStr withFormat:nil];
    
    NSString *minDateStr = [NSString stringWithFormat:@"%@-%@-01 00:00",
                         datePickerDateMinLimited.year,
                         datePickerDateMinLimited.month
                         ];
    
    if ([date compare:[DateHelper dateFromString:minDateStr withFormat:nil]] == NSOrderedAscending ||
        [date compare:_maxLimitedDate] == NSOrderedDescending) {
        color = kRowDisabledStatusColor;
    }
    
    return color;
}

- (UIColor *)dayRowTextColor:(NSInteger)row {
    UIColor *color = kRowNormalStatusColor;
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ 00:00",
                         mArrYear[yearIndex],
                         mArrMonth[monthIndex],
                         mArrDay[row]
                         ];
    NSDate *date = [DateHelper dateFromString:dateStr withFormat:nil];
    
    NSString *minDateStr = [NSString stringWithFormat:@"%@-%@-%@ 00:00",
                            datePickerDateMinLimited.year,
                            datePickerDateMinLimited.month,
                            datePickerDateMinLimited.day
                            ];
    
    if ([date compare:[DateHelper dateFromString:minDateStr withFormat:nil]] == NSOrderedAscending ||
        [date compare:_maxLimitedDate] == NSOrderedDescending) {
        color = kRowDisabledStatusColor;
    }
    
    return color;
}

- (UIColor *)hourRowTextColor:(NSInteger)row {
    UIColor *color = kRowNormalStatusColor;
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:00",
                         mArrYear[yearIndex],
                         mArrMonth[monthIndex],
                         mArrDay[dayIndex],
                         mArrHour[row]
                         ];
    NSDate *date = [DateHelper dateFromString:dateStr withFormat:nil];
    
    NSString *minDateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:00",
                            datePickerDateMinLimited.year,
                            datePickerDateMinLimited.month,
                            datePickerDateMinLimited.day,
                            datePickerDateMinLimited.hour
                            ];
    
    if ([date compare:[DateHelper dateFromString:minDateStr withFormat:nil]] == NSOrderedAscending ||
        [date compare:_maxLimitedDate] == NSOrderedDescending) {
        color = kRowDisabledStatusColor;
    }
    
    return color;
}

- (UIColor *)minuteRowTextColor:(NSInteger)row {
    NSString *format = @"yyyy-MM-dd HH:mm:ss";
    UIColor *color = kRowNormalStatusColor;
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:00",
                         mArrYear[yearIndex],
                         mArrMonth[monthIndex],
                         mArrDay[dayIndex],
                         mArrHour[hourIndex],
                         mArrMinute[row]
                         ];
    NSDate *date = [DateHelper dateFromString:dateStr withFormat:format];
    
    NSString *minDateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:00",
                            datePickerDateMinLimited.year,
                            datePickerDateMinLimited.month,
                            datePickerDateMinLimited.day,
                            datePickerDateMinLimited.hour,
                            datePickerDateMinLimited.minute
                            ];
    
    if ([date compare:[DateHelper dateFromString:minDateStr withFormat:format]] == NSOrderedAscending ||
        [date compare:_maxLimitedDate] == NSOrderedDescending) {
        color = kRowDisabledStatusColor;
    }
    
    return color;
}

#pragma mark - 绘制内容
- (void)drawRect:(CGRect)rect {
    //加载数据
    [self loadData];
    
    //初始化头部按钮（取消、现在时间、确定）
    UIView *buttonContentView = [[UIView alloc] initWithFrame:CGRectMake(-2.0, 0.0, kWidthOfTotal + 4.0, kHeightOfButtonContentView)];
    buttonContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    buttonContentView.layer.borderWidth = 0.5;
    [self addSubview:buttonContentView];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(2.0, 2.5, 60.0, kHeightOfButtonContentView - 5.0);
    btnCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:kButtonNormalStatusColor forState:UIControlStateNormal];
    [btnCancel addTarget:self
                  action:@selector(cancel:)
        forControlEvents:UIControlEventTouchUpInside];
    [buttonContentView addSubview:btnCancel];
    
    if ([self canShowScrollToNowButton]) {
        UIButton *btnScrollToNow = [UIButton buttonWithType:UIButtonTypeCustom];
        btnScrollToNow.frame = CGRectMake(buttonContentView.frame.size.width/2 - 50.0, 2.5, 100.0, kHeightOfButtonContentView - 5.0);
        btnScrollToNow.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btnScrollToNow setTitle:@"现在时间" forState:UIControlStateNormal];
        [btnScrollToNow setTitleColor:kButtonNormalStatusColor forState:UIControlStateNormal];
        [btnScrollToNow addTarget:self
                           action:@selector(scrollToNowDateIndexPosition:)
                 forControlEvents:UIControlEventTouchUpInside];
        [buttonContentView addSubview:btnScrollToNow];
    }
    
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    btnConfirm.frame = CGRectMake(kWidthOfTotal - 58.0, 2.5, 60.0, kHeightOfButtonContentView - 5.0);
    btnConfirm.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
    [btnConfirm setTitleColor:kButtonNormalStatusColor forState:UIControlStateNormal];
    [btnConfirm addTarget:self
                   action:@selector(confirm:)
         forControlEvents:UIControlEventTouchUpInside];
    [buttonContentView addSubview:btnConfirm];
    
    //初始化选择器视图控件
    if (!pikV) {
        pikV = [[UIPickerView alloc]initWithFrame:CGRectMake(0.0, kHeightOfButtonContentView, kWidthOfTotal, self.frame.size.height - kHeightOfButtonContentView)];
        pikV.showsSelectionIndicator = YES;
        pikV.backgroundColor = [UIColor clearColor];
        [self addSubview:pikV];
    }
    pikV.dataSource = self;
    pikV.delegate = self;
    
    //初始化滚动到指定时间位置
    [self scrollToDateIndexPosition];
}

#pragma mark - 执行 KMDatePickerDelegate 委托代理协议方法，用于回调传递参数
- (void)playDelegateAfterSelectedRow {
    if ([self.delegate respondsToSelector:@selector(datePicker:didSelectDate:)]) {
        [self.delegate datePicker:self
                    didSelectDate:datePickerDateScrollTo];
    }
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSInteger numberOfComponents = 0;
    switch (_datePickerStyle) {
        case KMDatePickerStyleYearMonthDayHourMinute: {
            numberOfComponents = 5;
            break;
        }
        case KMDatePickerStyleYearMonthDay: {
            numberOfComponents = 3;
            break;
        }
        case KMDatePickerStyleMonthDayHourMinute: {
            numberOfComponents = 4;
            break;
        }
        case KMDatePickerStyleHourMinute: {
            numberOfComponents = 2;
            break;
        }
    }
    return numberOfComponents;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    switch (_datePickerStyle) {
        case KMDatePickerStyleYearMonthDayHourMinute: {
            switch (component) {
                case 0:
                    numberOfRows = mArrYear.count;
                    break;
                case 1:
                    numberOfRows = kMonthCountOfEveryYear;
                    break;
                case 2:
                    numberOfRows = [self daysOfMonth];
                    break;
                case 3:
                    numberOfRows = kHourCountOfEveryDay;
                    break;
                case 4:
                    numberOfRows = kMinuteCountOfEveryHour;
                    break;
            }
            break;
        }
        case KMDatePickerStyleYearMonthDay: {
            switch (component) {
                case 0:
                    numberOfRows = mArrYear.count;
                    break;
                case 1:
                    numberOfRows = kMonthCountOfEveryYear;
                    break;
                case 2:
                    numberOfRows = [self daysOfMonth];
                    break;
            }
            break;
        }
        case KMDatePickerStyleMonthDayHourMinute: {
            switch (component) {
                case 0:
                    numberOfRows = kMonthCountOfEveryYear;
                    break;
                case 1:
                    numberOfRows = [self daysOfMonth];
                    break;
                case 2:
                    numberOfRows = kHourCountOfEveryDay;
                    break;
                case 3:
                    numberOfRows = kMinuteCountOfEveryHour;
                    break;
            }
            break;
        }
        case KMDatePickerStyleHourMinute: {
            switch (component) {
                case 0:
                    numberOfRows = kHourCountOfEveryDay;
                    break;
                case 1:
                    numberOfRows = kMinuteCountOfEveryHour;
                    break;
            }
            break;
        }
    }
    return numberOfRows;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat width = 50.0;
    CGFloat widthOfAverage;
    
    switch (_datePickerStyle) {
        case KMDatePickerStyleYearMonthDayHourMinute: {
            //规则一：平均宽度 = （总共宽度 - 年份相比多两个数字的宽度 - 分钟会是右对齐导致需偏移宽度来显示「分」这个文字） / 5等份
            widthOfAverage = (kWidthOfTotal - 20.0 - 25.0) / 5;
            switch (component) {
                case 0:
                    width = widthOfAverage + 20.0;
                    //规则二：单位标签的 X 坐标位置 = 列的水平居中 X 坐标 ＋ 偏移量
                    [self addUnitLabel:@"年" withPointX:width/2 + 24.0];
                    break;
                case 1:
                    width = widthOfAverage;
                    [self addUnitLabel:@"月" withPointX:(widthOfAverage + 20.0) + width/2 + 16.0];
                    break;
                case 2:
                    width = widthOfAverage;
                    [self addUnitLabel:@"日" withPointX:(2*widthOfAverage + 20.0) + width/2 + 22.0];
                    break;
                case 3:
                    width = widthOfAverage;
                    [self addUnitLabel:@"时" withPointX:(3*widthOfAverage + 20.0) + width/2 + 28.0];
                    break;
                case 4:
                    width = widthOfAverage;
                    [self addUnitLabel:@"分" withPointX:(4*widthOfAverage + 20.0) + width/2 + 32.0];
                    break;
            }
            break;
        }
        case KMDatePickerStyleYearMonthDay: {
            widthOfAverage = (kWidthOfTotal - 20.0 - 15.0) / 3;
            switch (component) {
                case 0:
                    width = widthOfAverage + 20.0;
                    [self addUnitLabel:@"年" withPointX:width/2 + 24.0];
                    break;
                case 1:
                    width = widthOfAverage;
                    [self addUnitLabel:@"月" withPointX:(widthOfAverage + 20.0) + width/2 + 16.0];
                    break;
                case 2:
                    width = widthOfAverage;
                    [self addUnitLabel:@"日" withPointX:(2*widthOfAverage + 20.0) + width/2 + 22.0];
                    break;
            }
            break;
        }
        case KMDatePickerStyleMonthDayHourMinute: {
            widthOfAverage = (kWidthOfTotal - 20.0) / 4;
            switch (component) {
                case 0:
                    width = widthOfAverage;
                    [self addUnitLabel:@"月" withPointX:width/2 + 11.0];
                    break;
                case 1:
                    width = widthOfAverage;
                    [self addUnitLabel:@"日" withPointX:widthOfAverage + width/2 + 17.0];
                    break;
                case 2:
                    width = widthOfAverage;
                    [self addUnitLabel:@"时" withPointX:2*widthOfAverage + width/2 + 23.0];
                    break;
                case 3:
                    width = widthOfAverage;
                    [self addUnitLabel:@"分" withPointX:3*widthOfAverage + width/2 + 27.0];
                    break;
            }
            break;
        }
        case KMDatePickerStyleHourMinute: {
            widthOfAverage = (kWidthOfTotal - 10.0) / 2;
            switch (component) {
                case 0:
                    width = widthOfAverage;
                    [self addUnitLabel:@"时" withPointX:width/2 + 12.0];
                    break;
                case 1:
                    width = widthOfAverage;
                    [self addUnitLabel:@"分" withPointX:widthOfAverage + width/2 + 18.0];
                    break;
            }
            break;
        }
    }
    return width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UILabel *lblCustom = (UILabel *)view;
    if (!lblCustom) {
        lblCustom = [UILabel new];
        lblCustom.textAlignment = NSTextAlignmentCenter;
        lblCustom.font = [UIFont systemFontOfSize:18.0];
    }
    
    NSString *text;
    UIColor *textColor = kRowNormalStatusColor;
    switch (_datePickerStyle) {
        case KMDatePickerStyleYearMonthDayHourMinute: {
            switch (component) {
                case 0:
                    text = mArrYear[row];
                    break;
                case 1:
                    text = mArrMonth[row];
                    textColor = [self monthRowTextColor:row];
                    break;
                case 2:
                    text = mArrDay[row];
                    textColor = [self dayRowTextColor:row];
                    break;
                case 3:
                    text = mArrHour[row];
                    textColor = [self hourRowTextColor:row];
                    break;
                case 4:
                    text = mArrMinute[row];
                    textColor = [self minuteRowTextColor:row];
                    break;
            }
            break;
        }
        case KMDatePickerStyleYearMonthDay: {
            switch (component) {
                case 0:
                    text = mArrYear[row];
                    break;
                case 1:
                    text = mArrMonth[row];
                    textColor = [self monthRowTextColor:row];
                    break;
                case 2:
                    text = mArrDay[row];
                    textColor = [self dayRowTextColor:row];
                    break;
            }
            break;
        }
        case KMDatePickerStyleMonthDayHourMinute: {
            switch (component) {
                case 0:
                    text = mArrMonth[row];
                    textColor = [self monthRowTextColor:row];
                    break;
                case 1:
                    text = mArrDay[row];
                    textColor = [self dayRowTextColor:row];
                    break;
                case 2:
                    text = mArrHour[row];
                    textColor = [self hourRowTextColor:row];
                    break;
                case 3:
                    text = mArrMinute[row];
                    textColor = [self minuteRowTextColor:row];
                    break;
            }
            break;
        }
        case KMDatePickerStyleHourMinute: {
            switch (component) {
                case 0:
                    text = mArrHour[row];
                    textColor = [self hourRowTextColor:row];
                    break;
                case 1:
                    text = mArrMinute[row];
                    textColor = [self minuteRowTextColor:row];
                    break;
            }
            break;
        }
    }
    lblCustom.text = text;
    lblCustom.textColor = textColor;
    return lblCustom;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSDate *scrollToDateTemp = _scrollToDate;
    KMDatePickerDateModel *datePickerDateScrollToTemp = datePickerDateScrollTo;
    
    switch (_datePickerStyle) {
        case KMDatePickerStyleYearMonthDayHourMinute: {
            switch (component) {
                case 0:
                    yearIndex = row;
                    break;
                case 1:
                    monthIndex = row;
                    break;
                case 2:
                    dayIndex = row;
                    break;
                case 3:
                    hourIndex = row;
                    break;
                case 4:
                    minuteIndex = row;
                    break;
            }
            if (component == 0 || component == 1) {
                [self reloadDayArray];
                if (mArrDay.count-1 < dayIndex) {
                    dayIndex = mArrDay.count-1;
                }
                //[pickerView reloadComponent:2];
            }
            break;
        }
        case KMDatePickerStyleYearMonthDay: {
            switch (component) {
                case 0:
                    yearIndex = row;
                    break;
                case 1:
                    monthIndex = row;
                    break;
                case 2:
                    dayIndex = row;
                    break;
            }
            if (component == 0 || component == 1) {
                [self reloadDayArray];
                if (mArrDay.count-1 < dayIndex) {
                    dayIndex = mArrDay.count-1;
                }
                //[pickerView reloadComponent:2];
            }
            break;
        }
        case KMDatePickerStyleMonthDayHourMinute: {
            switch (component) {
                case 0:
                    monthIndex = row;
                    break;
                case 1:
                    dayIndex = row;
                    break;
                case 2:
                    hourIndex = row;
                    break;
                case 3:
                    minuteIndex = row;
                    break;
            }
            if (component == 0) {
                [self reloadDayArray];
                if (mArrDay.count-1 < dayIndex) {
                    dayIndex = mArrDay.count-1;
                }
                //[pickerView reloadComponent:1];
            }
            break;
        }
        case KMDatePickerStyleHourMinute: {
            switch (component) {
                case 0:
                    hourIndex = row;
                    break;
                case 1:
                    minuteIndex = row;
                    break;
            }
            break;
        }
    }
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",
                         mArrYear[yearIndex],
                         mArrMonth[monthIndex],
                         mArrDay[dayIndex],
                         mArrHour[hourIndex],
                         mArrMinute[minuteIndex]
                         ];
    _scrollToDate = [DateHelper dateFromString:dateStr withFormat:nil];
    datePickerDateScrollTo = [[KMDatePickerDateModel alloc] initWithDate:_scrollToDate];
    
    //为了区别最大最小限制范围外行的标签颜色，这里需要重新加载所有组件列
    [pickerView reloadAllComponents];
    
    //如果选择时间不在最小和最大限制时间范围内就回滚
    if (![self validatedDate:_scrollToDate]) {
        _scrollToDate = scrollToDateTemp;
        datePickerDateScrollTo = datePickerDateScrollToTemp;
        yearIndex = [datePickerDateScrollTo.year integerValue] - [datePickerDateMinLimited.year integerValue];
        monthIndex = [datePickerDateScrollTo.month integerValue] - 1;
        dayIndex = [datePickerDateScrollTo.day integerValue] - 1;
        hourIndex = [datePickerDateScrollTo.hour integerValue];
        minuteIndex = [datePickerDateScrollTo.minute integerValue];
        [self scrollToDateIndexPosition];
    }
}

@end
