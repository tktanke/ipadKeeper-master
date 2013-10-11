//
//  settingViewController.m
//  GJ
//
//  Created by apple NO5 on 13-7-2.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import "settingViewController.h"
#import "ViewController.h"
#import "SoundPlayer.h"
#import <QuartzCore/QuartzCore.h>

@interface settingViewController ()

@property (nonatomic, strong) NSString *ackpassword;
@property BOOL isSettingNewPassword;

@end

extern int warningTime;

@implementation settingViewController
@synthesize oldpassword;
@synthesize ackpassword = _ackpassword;
@synthesize isSettingNewPassword = _isSettingNewPassword;

-(void)showPasswordFieldWithTitle:(NSString *)title
                         alertTag:(int)alertTag
                         fieldTag:(int)fieldTag
{
    UIAlertView *passwordAlert;
    //if(self.isSettingNewPassword == NO)
    passwordAlert=[[UIAlertView alloc]initWithTitle:title
                                            message:@"\n\n\n"
                                           delegate:self
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:@"取消", nil];
    /*else
     passwordAlert=[[UIAlertView alloc]initWithTitle:title
     message:@"\n\n\n"
     delegate:self
     cancelButtonTitle:@"确定"
     otherButtonTitles:nil, nil];
     */ 
    
    oldpassword=[[UITextField alloc]initWithFrame:CGRectMake(12,80,260,30)];
    oldpassword.borderStyle=UITextBorderStyleBezel;
    oldpassword.backgroundColor=[UIColor whiteColor];
    oldpassword.keyboardType=UIKeyboardTypeNumberPad;
    oldpassword.tag=fieldTag;
    oldpassword.secureTextEntry=YES;
    [oldpassword becomeFirstResponder];
    passwordAlert.tag=alertTag;
    [passwordAlert addSubview:oldpassword];
    [passwordAlert show];
}

-(void)setPswProtectSwitcherState:(BOOL)onOrOff
{
    if(onOrOff)
    {
        [self.pswProtectSwitcher setImage:[UIImage imageNamed:@"开启状态" ] forState:UIControlStateNormal];
        [self.lockStateImage setImage:[UIImage imageNamed:@"密保已开启.png"]];
        [self.resetBtn setAlpha:1.0f];
    }
    else
    {
        [self.pswProtectSwitcher setImage:[UIImage imageNamed:@"关闭状态"] forState:UIControlStateNormal];
        [self.lockStateImage setImage:[UIImage imageNamed:@"密保已关闭.png"]];
        [self.resetBtn setAlpha:0.0f];
    }
    
}
- (IBAction)pswSwitch:(UISwitch *)sender
{
    [SoundPlayer playButtonSound];
    if(app.passwordProtect == NO)
    {
        if([app.code isEqualToString:@""])
        {
            self.isSettingNewPassword = YES;
            [self showPasswordFieldWithTitle:@"请输入新密码" alertTag:2 fieldTag:107];
        }
        else
        {
            self.isSettingNewPassword = NO;
            [self setPswProtectSwitcherState:YES];
            app.passwordProtect = YES;
            [app.setting_data set_psw_protection:app.passwordProtect];
        }
    }
    else
    {
        [self showPasswordFieldWithTitle:@"请输入密码" alertTag:7 fieldTag:106];
    }
    return ;
}

- (IBAction)resetPassword:(UIButton *)sender
{
    [SoundPlayer playButtonSound];
    [self showPasswordFieldWithTitle:@"请输入新密码" alertTag:2 fieldTag:107];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //点击确定时的处理
    if(buttonIndex==0){
        //用tag来区别不同情况下的弹框按键事件
        switch (alertView.tag) {
                //更改密码时再次确认新密码
            case 2:
            {
                self.ackpassword = [NSString stringWithString:oldpassword.text];
                if([self.ackpassword isEqualToString:@""])
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示"
                                                                 message:@"密码不能为空" delegate:self
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil,
                                        nil];
                    alert.tag = 4;
                    [alert show];
                }
                else
                {
                    [self showPasswordFieldWithTitle:@"请确认新密码" alertTag:3 fieldTag:106];
                }
            }
                break;
                //判断密码是否一致
            case 3:
                //如果两次密码相同，则确定修改密码
                if([self.ackpassword isEqualToString:oldpassword.text])
                {
                    //更新密码
                    app.code=oldpassword.text;
                    //写入文件
                    [app.setting_data set_a_new_userPassword:app.code];
                    UIAlertView *suc=[[UIAlertView alloc]initWithTitle:@"提示" message:@"密码修改成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [suc show];
                    if(self.isSettingNewPassword == YES)
                    {
                        [self setPswProtectSwitcherState:YES];
                        app.passwordProtect = YES;
                        [app.setting_data set_psw_protection:app.passwordProtect];
                        self.isSettingNewPassword = NO;
                    }
                }
                else
                {
                    UIAlertView *a=[[UIAlertView alloc]initWithTitle:@"警告" message:@"密码不一致" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    a.tag = 6;
                    [a show];
                    
                }
                break;
                
            case 4:
                [self showPasswordFieldWithTitle:@"请输入新密码" alertTag:2 fieldTag:107];
                break;
            case 6:
                [self showPasswordFieldWithTitle:@"请输入新密码" alertTag:2 fieldTag:107];
                break;
                
            case 7:
                if([oldpassword.text isEqualToString:app.code])
                {
                    [self setPswProtectSwitcherState:NO];
                    app.passwordProtect = NO;
                    [app.setting_data set_psw_protection:app.passwordProtect];
                    
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"密码错误" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                
            default:
                break;
        }
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    [self setPswProtectSwitcherState:app.setting_data.pswProtection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
}
@end
