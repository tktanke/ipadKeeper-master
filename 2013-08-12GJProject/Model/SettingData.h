//
//  SettingData.h
//  Time_xml_file
//
//  Created by new239 on 13-6-24.
//  Copyright (c) 2013年 scut.zero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingData : NSObject

@property NSInteger settingTimeLength;//设置一天的提醒时间长度，最小单位是（分钟），默认为2小时即120分钟
@property(nonatomic,strong) NSString* userIdName;//用户的id，默认为“00000000”
@property(nonatomic,strong)  NSString* userPassword;//默认为“123”
@property BOOL pswProtection;
@property NSInteger deadline;
//xmpp
@property(nonatomic) NSString* sentDataAutomaticly;//是否默认自动发送数据，值为“0”时默认自动，其他值默认需每次询问才能发送数据

-(id)init;
//更改settingTime并把新的值写到settingData.xml
-(void)set_a_new_settingTime:(NSInteger) minutes;
//更改idName并把新的值写到settingData.xml
-(void)set_a_new_userIdName:(NSString*)name;
//更改password并把新的值写到settingData.xml
-(void)set_a_new_userPassword:(NSString *)psword;
//更改密码保护开关
-(void)set_psw_protection:(BOOL)switchOn;
//设定报警时间
-(void)set_deadline_time:(int)minute;
//恢复默认设置
-(void)backTodefault;
//xmpp
//更改sentDataAutomaticly并把新的值写到settingData.xml
-(void)set_a_new_sentDataAutomaticly:(NSString*)SDA;

@end
