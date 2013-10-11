//
//  settingViewController.h
//  GJ
//
//  Created by apple NO5 on 13-7-2.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface settingViewController : UIViewController<UIAlertViewDelegate>{
    AppDelegate *app;
    NSDate *pushDate;
}

- (IBAction)pswSwitch:(id)sender;
- (IBAction)resetPassword:(UIButton *)sender;

@property (nonatomic, strong) UITextField *oldpassword;
@property (weak, nonatomic) IBOutlet UIButton *pswProtectSwitcher;
@property (weak, nonatomic) IBOutlet UIImageView *lockStateImage;

@property (weak, nonatomic) IBOutlet UIButton *resetBtn;


@end
