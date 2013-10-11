//
//  ViewController.h
//  GJ
//
//  Created by apple NO5 on 13-6-18.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneTime.h"
#import "SettingData.h"
#import "OneTime.h"
#import "TableViewController.h"
#import "AppDelegate.h"
#define SNAILAMOUNT 9

@interface ViewController : UIViewController<UIAlertViewDelegate,UITabBarControllerDelegate>
{
    UITabBarController *tabBar;
    NSTimeZone *zone;
    NSInteger interval;
    NSDate *pushDate;
    AppDelegate *app;
    NSString *temp;
    
    //蜗牛动画
    UIImageView *snailAnimation;
    NSMutableArray * _snail;
    int frameCount;
    float snailSpace;

}
//@property IBOutlet UILabel *hour_min;
@property (weak, nonatomic) IBOutlet UIButton *timeSettingBtn;
//天空的那抹云彩
@property (weak, nonatomic) IBOutlet UIImageView *cloudPic;

////保存相关的密码
@property(retain,nonatomic)IBOutlet UITextField *passwordField;

//显示已设定的提醒时间
@property IBOutlet UILabel *label_warning_minute;
@property (weak, nonatomic) IBOutlet UILabel *label_warning_hour;

//显示今日总共所用时间
@property(retain,nonatomic)IBOutlet UILabel *timeLabel;

//显示本次已使用时间
@property(retain,nonatomic)IBOutlet UILabel *nowLabel;

@property(retain,nonatomic)NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIButton *mainBtn;
@property (weak, nonatomic) IBOutlet UIDatePicker *timeSelector;
@property (weak, nonatomic) IBOutlet UIImageView *timeSelectorBackground;
@property (weak, nonatomic) IBOutlet UIButton *timeSelectOKBtn;
@property (weak, nonatomic) IBOutlet UILabel *deadlineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *deadlineCircle;
@property (weak, nonatomic) IBOutlet UIImageView *lightCircle;

//本日已记录的累计使用时间
@property int usetime;
//本次使用时间
@property int useTime_now;

//输入的密码
@property NSString *code;
@property UILocalNotification *notification;
//记录进入后台的时间
@property NSDate *enter_back_time;
//记录进入前台的时间
@property NSDate *enter_fore_time;

//------------------------------
@property OneTime* one_time;



-(IBAction)switchOn:(id)sender;

- (IBAction)SetTime:(UIButton *)sender;
- (IBAction)timeSelectOK:(UIButton *)sender;



-(void)onTimer;

-(void)reflashWarningTime;
-(void)pushNotification;
-(void)clearNotification;
-(void)reflashDeadlineLabel;

+(ViewController *)sharedViewController;


@end
