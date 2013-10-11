//
//  ViewController.m
//  GJ
//
//  Created by apple NO5 on 13-6-18.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

/*
 usetime:今天到目前为止已记录的使用时间（正在计时的这次不算）
 app.usetime_now:本次正在计时的时间
 app.warningTime:设置的报警时间
 onetime.beginTime:本次计时的开始时间
 onetime.end_time:本次计时的停止时间
 app.deadlineTime:设置的警告标语出现时间
 */
#define SNAIL_START_POS_X 50
#define SNAIL_POS_Y 210
#define SNAIL_END_POS_X 626
#define SNAIL_SIZE_W 150
#define SNAIL_SIZE_H 109
#import "ViewController.h"
#import "BackgroundRunning.h"
#import "YouMiView.h"
#import "LeveyTabBarController.h"
#import "TableViewController.h"
#import "DataManager.h"
#import "SoundPlayer.h"

static ViewController * _sharedViewController = nil;

@interface ViewController ()

@property BOOL isTimeOut;
@property (strong) NSTimer *snailTimer;
@property (strong) NSTimer *lightTimer;
@property BOOL isLightLighter;
@property int lightWaiter;

-(void)showPasswordFieldwithTag:(int)tag;
-(void)reflashUseTimeToday;
-(void)letTheSnailGo;
@end

@implementation ViewController

@synthesize isTimeOut = _isTimeOut;

//@synthesize hour_min;

@synthesize timeLabel;
@synthesize passwordField;
@synthesize enter_back_time;
@synthesize enter_fore_time;

@synthesize  useTime_now;
@synthesize label_warning_hour;
@synthesize label_warning_minute;

@synthesize timer;
@synthesize snailTimer = _snailTimer;
@synthesize nowLabel;

@synthesize usetime;
@synthesize code;

@synthesize  notification;

@synthesize one_time;

+(ViewController *)sharedViewController
{
    if(_sharedViewController == nil)
    {
        _sharedViewController = [[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
    }
    return _sharedViewController;
}

-(void)showPasswordFieldwithTag:(int)settingTag
{
    UIAlertView *passwordAlert=[[UIAlertView alloc]initWithTitle:@"请输入密码" message:@"\n\n\n" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    passwordField=[[UITextField alloc]initWithFrame:CGRectMake(12,80,260,30)];
    passwordField.borderStyle=UITextBorderStyleBezel;
    passwordField.backgroundColor=[UIColor whiteColor];
    passwordField.keyboardType=UIKeyboardTypeNumberPad;
    passwordField.tag=106;
    passwordField.secureTextEntry=YES;
    [passwordField becomeFirstResponder];
    [passwordAlert addSubview:passwordField];
    passwordAlert.tag=settingTag;
    [passwordAlert show];
}

-(void)reflashDeadlineLabel
{
    if(usetime > app.deadlineTime)
    {
        [self.deadlineLabel setAlpha:1];
        [self.deadlineCircle setAlpha:1];
    }
    else
    {
        [self.deadlineLabel setAlpha:0];
        [self.deadlineCircle setAlpha:0];
    }
    return;
}

-(void)reflashUseTimeToday
{
    NSString *timestr=[NSString stringWithFormat:@"%02d  %02d ",usetime/(60*60),(usetime/60)%60];
    [timeLabel setText:timestr];
    [self reflashDeadlineLabel];
    return;
}

-(void)letTheSnailGo
{
    if([self.snailTimer isValid] == NO)
    {
        self.snailTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/5.0f target:self selector:@selector(changeFrames:) userInfo:nil repeats:YES];
    }
    [self.cloudPic setImage:[UIImage imageNamed:@"cloudTimeNoOut.png"]];
}

-(void)letTheSnailStop
{
    
        [self.snailTimer invalidate];
    if(self.isTimeOut)
    {
        [self.cloudPic setImage:[UIImage imageNamed:@"cloudTimeOut.png"]];
    }
}

-(void)reflashWarningTime
{
    //设定提醒时间的显示
    int hour = app.warningTime / 3600;
    int minute = (app.warningTime % 3600) / 60;

    if(hour ==0)
    {
        [self.label_warning_hour setAlpha:0];
        [self.label_warning_minute setAlpha:1];
        [self.label_warning_minute setCenter:CGPointMake(686, 110)];
    }
    else if(minute == 0)
    {
        [self.label_warning_minute setAlpha:0];
        [self.label_warning_hour setAlpha:1];
        [self.label_warning_hour setCenter:CGPointMake(686, 110)];
    }
    else
    {
        [self.label_warning_hour setAlpha:1];
        [self.label_warning_minute setAlpha:1];
        [self.label_warning_minute setCenter:CGPointMake(686, 126)];
        [self.label_warning_hour setCenter:CGPointMake(686, 94)];
    }
    NSString * hourstr=[NSString stringWithFormat:@"%d小时",hour];
    NSString * minuteStr = [NSString stringWithFormat:@"%d分钟", minute];
    [self.label_warning_hour setText:hourstr];
    [self.label_warning_minute setText:minuteStr];
    return;
}

-(void)clearNotification
{
    UIApplication *ap = [UIApplication sharedApplication];
    NSArray *previousNotification = [ap scheduledLocalNotifications];
    if([previousNotification count] > 0 )
    {
        [ap cancelAllLocalNotifications];
    }
    return;
}

-(void)pushNotification
{
    [self clearNotification];
    int time=app.warningTime - app.useTime_now;
    if(time <= 0)
        return;
    NSDate *date=[NSDate dateWithTimeIntervalSinceNow:time];
    UILocalNotification *notifi = [[UILocalNotification alloc]init];
    notifi.fireDate = date;
    notifi.repeatInterval = 0;
    notifi.timeZone = [NSTimeZone defaultTimeZone];
    notifi.soundName = @"Pure Music.wav";
    //notifi.soundName = @"/System/Library/Audio/UISounds/ReceivedMessage.caf";
    notifi.alertBody = @"时间到了!";
    notifi.alertAction = @"时间到了!";
    [[UIApplication sharedApplication]scheduleLocalNotification:notifi];
    
    return;
}

-(NSDate *)nowTimeWithInterval
{
    NSDate *now = [NSDate date];
    zone=[NSTimeZone systemTimeZone];
    interval=[zone secondsFromGMTForDate:now];
    now=[now dateByAddingTimeInterval:interval];
    return now;
}

-(void)changeMainBtn
{
    if(app.swicthIsOn)
    {
        [self.mainBtn setBackgroundImage:[UIImage imageNamed:@"end_background.png"] forState:UIControlStateNormal];
        [self.lightTimer invalidate];
        [self.lightCircle setAlpha:0];
    }
    else
    {
        [self.mainBtn setBackgroundImage:[UIImage imageNamed:@"start_background.png"] forState:UIControlStateNormal];
        self.lightTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/10.0f target:self selector:@selector(lightShine:) userInfo:nil repeats:YES];
    }
}

-(void)lightShine:(NSTimer *)timer
{
    if(self.lightWaiter != 0)
    {
        --self.lightWaiter;
        return;
    }
    if(self.isLightLighter)
    {
        [self.lightCircle setAlpha:[self.lightCircle alpha] - 0.07];
        if([self.lightCircle alpha] <= 0.1)
        {
            //[self.lightCircle setAlpha:0];
            self.isLightLighter = NO;
            self.lightWaiter = 10;
        }
    }
    else
    {
        [self.lightCircle setAlpha:[self.lightCircle alpha] + 0.07];
        if([self.lightCircle alpha] >= 0.9)
        {
            self.isLightLighter = YES;
            self.lightWaiter = 10;
        }
    }
}

-(void)showTimeSelector:(BOOL)yesOrNo
{
    if(yesOrNo)
    {
        [self.timeSelectorBackground setAlpha:1];
        [self.view bringSubviewToFront:self.timeSelectorBackground];
        [self.timeSelectOKBtn setAlpha:1];
        [self.view bringSubviewToFront:self.timeSelectOKBtn];
        [self.timeSelector setAlpha:1];
        [self.view bringSubviewToFront:self.timeSelector];
    }
    else
    {
        [self.timeSelectOKBtn setAlpha:0];
        [self.timeSelector setAlpha:0];
        [self.timeSelectorBackground setAlpha:0];
    }
}

- (IBAction)SetTime:(UIButton *)sender
{
 
    [SoundPlayer playButtonSound];

    [self showTimeSelector:YES];
}

- (IBAction)timeSelectOK:(UIButton *)sender
{
    [SoundPlayer playButtonSound];
    
    app.warningTime=self.timeSelector.countDownDuration;
    [app.setting_data set_a_new_settingTime:app.warningTime/60];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"设置成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    if(app.swicthIsOn)
    {
        [self pushNotification];
        
    }
    [self reflashWarningTime];
    [self showTimeSelector:NO];

}

//计时调用的函数
-(void)onTimer{
    //usetime+=1;
    app.useTime_now+=1;
    if(app.useTime_now>app.warningTime)
    {
        NSLog(@"On timer:time out");
        self.isTimeOut = YES;
        app.useTime_now = app.warningTime;
        //[self.spot setOn:NO];
        [self switchOn:nil];
    }
    
    //本次使用时间
    NSString *timestr=[NSString stringWithFormat:@"%02d  %02d  %02d ",app.useTime_now/(60*60),(app.useTime_now/60)%60,app.useTime_now%60];
    [nowLabel setText:timestr];
}

//打开关闭开关的动作
-(IBAction)switchOn:(id)sender
{
    [SoundPlayer playButtonSound];
    BOOL isButtonOn = YES;
    if(app.swicthIsOn)
        isButtonOn = NO;
    app.swicthIsOn=isButtonOn;
    [self changeMainBtn];
    
    //判断开关的状态
    if(isButtonOn){
        
        //判断是否是新的一天，即该时段是否是当天的第一个时段，若是则清空oneTime.xml
        NSDate *d=[self nowTimeWithInterval];
        
        NSInteger nnn=[DataManager isNewDay:d];
        if (nnn>0)
        {
            NSLog(@"isNewDay****%d\n",nnn);
            [DataManager dealWithDaysGaps:nnn];
            [DataManager clearTodayTime];
            self.usetime = 0;
            [self reflashUseTimeToday];
        }
        
        //获取开始时间
        self.one_time.beginTime=[self nowTimeWithInterval];
        
        /////////////////
        //for testing
        app.useTime_now=0;
        
        
        [self pushNotification];
        [self reflashWarningTime];
        
        
        //如果定时器已经无效，则再次开启
        if(![timer isValid])
        {
            timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
        }
        self.isTimeOut = NO;
        [self.timeSettingBtn setAlpha:0];
        [self letTheSnailGo];
    }
    //关闭开关需要输入密码
    else
    {
        if(app.passwordProtect && self.isTimeOut == NO)
            [self showPasswordFieldwithTag:4];
        else
            [self closeTimer];
    }
}

-(void)closeTimer
{
    [self.timeSettingBtn setAlpha:1];
    //停止计时器
    [timer invalidate];
    //记下停止时间
    self.one_time.endTime= [self.one_time.beginTime dateByAddingTimeInterval:app.useTime_now];
    //本日使用时间递增
    usetime += app.useTime_now;
    [self reflashUseTimeToday];
    //把endTime写入文件
    [one_time write_thisTime_to_today];
    //取消原来的推送
    [self clearNotification];
    return;
}

-(void)showWrongAnswerAlert
{
    UIAlertView *al=[[UIAlertView alloc]initWithTitle:@"警告" message:@"密码错误" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [al show];
    return;
}


//对于所有弹出警告框按键事件的处理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //点击取消时的处理
    if(buttonIndex!=0 && alertView.tag==4)
    {
        //[switch_s setOn:YES];
        app.swicthIsOn=YES;
        [self letTheSnailGo];
        [self changeMainBtn];
    }
    //点击确定时的处理
    if(buttonIndex==0)
    {
        //用tag来区别不同情况下的弹框按键事件
        switch (alertView.tag)
        {
                //关闭计时时需要验证密码
            case 4:
                //验证密码正确
                if([app.code isEqualToString:passwordField.text])
                {
                    [self closeTimer];
                }
                //验证密码错误
                else
                {
                    [self showWrongAnswerAlert];
                    app.swicthIsOn=YES;
                    [self changeMainBtn];
                    [self letTheSnailGo];
                }
                break;
                
            case 7:
                temp=@"0";
                break;
            case 8:
                if([app.code isEqualToString:passwordField.text])
                {
                    [self showTimeSelector:YES];
                }
                else
                {
                    [self showWrongAnswerAlert];
                }
                
                break;
            default:
                break;
        }
    }
    
}

-(void)snailAnimations
{
    if (!_snail) {
        _snail = [[NSMutableArray alloc]init];
    }
    
    for(int i = 1; i <= SNAILAMOUNT; ++i)
    {
        UIImage *snailTemp = [UIImage imageNamed:[NSString stringWithFormat:@"蜗牛000%d.png", i] ];
        [_snail addObject:snailTemp];
    }
    NSLog(@"%d",_snail.count);
    snailAnimation.image = [UIImage imageNamed:[NSString stringWithFormat:@"蜗牛0010.png"]];
}

-(void)changeFrames:(NSTimer *)timer
{
    if(app.swicthIsOn == NO)
    {
        [self letTheSnailStop];
        
        if(self.isTimeOut)
            [snailAnimation setCenter:CGPointMake(SNAIL_END_POS_X, SNAIL_POS_Y)];
        snailAnimation.image = [UIImage imageNamed:[NSString stringWithFormat:@"蜗牛0010.png"]];
        return;
    }
    if (frameCount >= SNAILAMOUNT-1)frameCount = 0;
    snailAnimation.image = [_snail objectAtIndex:frameCount];
    frameCount++;
    snailSpace = ((float)app.useTime_now/(float)app.warningTime)*(SNAIL_END_POS_X - SNAIL_START_POS_X);
    [snailAnimation setCenter:CGPointMake(SNAIL_START_POS_X + snailSpace, SNAIL_POS_Y)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //time selector:
    [self showTimeSelector:NO];
    
    
    timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    [timer invalidate];
    enter_back_time=enter_fore_time=[self nowTimeWithInterval];
    
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    //----------------------
    
    //初始化文件
    [DataManager initFile];
    
    self.one_time=[[OneTime alloc]init];
    
    app.setting_data=[[SettingData alloc]init];
    app.warningTime=app.setting_data.settingTimeLength*60;
    app.code=app.setting_data.userPassword;
    app.passwordProtect = app.setting_data.pswProtection;
    app.deadlineTime = app.setting_data.deadline;
    
    //判断是否是新的一天，即该时段是否是当天的第一个时段，若是则清空oneTime.xml
    NSDate *d=[self nowTimeWithInterval];
    NSInteger nnn=[DataManager isNewDay:d];
    NSLog(@"isNewDay****%d\n",nnn);
    
    if (nnn>0)
    {
        [DataManager dealWithDaysGaps:nnn];
        [DataManager clearTodayTime];
        
    }   
    
    self.usetime=[DataManager todayUsedMinutes]*60;
    [self reflashUseTimeToday];
    
    //检测后台运行状态
    if([BackgroundRunning checkIfRunningBeforeExit])
    {
        app.swicthIsOn = NO;
        [self switchOn:self.mainBtn];
        self.one_time.beginTime = [BackgroundRunning startTime];
        NSDate *nowTime = [self nowTimeWithInterval];
        app.useTime_now = [nowTime timeIntervalSinceDate:self.one_time.beginTime];
        [self pushNotification];
        [BackgroundRunning clearPreviousState];
    }
    else
        [self changeMainBtn];

    //snail:
    frameCount = 0;
    if (!snailAnimation) {
        snailAnimation = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SNAIL_SIZE_W, SNAIL_SIZE_H)];
    }
    [snailAnimation setCenter:CGPointMake(SNAIL_START_POS_X, SNAIL_POS_Y)];
    [self.view addSubview:snailAnimation];
    [self snailAnimations];
    
    [self reflashWarningTime];
}
@end
