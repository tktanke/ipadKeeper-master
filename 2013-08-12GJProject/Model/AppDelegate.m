//
//  AppDelegate.m
//  GJ
//
//  Created by apple NO5 on 13-6-18.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AppDelegate.h"
#import "DataManager.h"

#import "ViewController.h"
#import "TableViewController.h"
#import "settingViewController.h"
#import "allViewController.h"

#import "YouMiConfig.h"

#import "LeveyTabBarController.h"

@implementation AppDelegate

@synthesize window=_window;
//@synthesize navController =_navControler;
@synthesize tabBar;
@synthesize leveyTabBarController;
@synthesize warningTime;
@synthesize deadlineTime;
@synthesize useTime_now;

@synthesize code;
@synthesize setting_data;

//xmpp
@synthesize xmppStream;
@synthesize sentDate;
@synthesize passedDates;
@synthesize offset;
//rank
@synthesize monthRank;
@synthesize daysAvg;
@synthesize selfAvg;
//cs connenct data
@synthesize server;
@synthesize usr;
@synthesize pwd;
@synthesize sendSP;
@synthesize rankSP;

@synthesize option;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark get advice and help
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString*)getHistoryRecordsAdvice:(NSInteger)index{
    NSString* xmlPath=[[NSBundle mainBundle]pathForResource:@"advice.xml" ofType:nil inDirectory:nil];
    NSData* xmlData=[NSData dataWithContentsOfFile:xmlPath];
    GDataXMLDocument* doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement* root=[doc rootElement];
    //NSLog(@"root:%@\n",root);
    NSArray* historyRecordsAdvice_arr=[root elementsForName:@"historyRecordsAdvice"];
    GDataXMLElement* historyRecordsAdvice=[historyRecordsAdvice_arr objectAtIndex:0];
    NSArray* option_arr=[historyRecordsAdvice elementsForName:@"option"];
    GDataXMLElement* Option=[option_arr objectAtIndex:index];
    //NSLog(@"%d....%@\n",index,[Option stringValue]);
    return [Option stringValue];
}


-(NSString*)getHelp{
    NSString* xmlPath=[[NSBundle mainBundle]pathForResource:@"help.xml" ofType:nil inDirectory:nil];
    NSData* xmlData=[NSData dataWithContentsOfFile:xmlPath];
    GDataXMLDocument* doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement* root=[doc rootElement];
    //NSLog(@"root:%@\n",root);
    NSArray* item_arr=[root elementsForName:@"item"];
    GDataXMLElement* item=[item_arr objectAtIndex:0];
    //NSLog(@"helpAAA...%@\n",[item stringValue]);
    return [item stringValue];
}
-(NSString*)getServerIP{
    NSString* xmlPath=[[NSBundle mainBundle]pathForResource:@"IP.xml" ofType:nil inDirectory:nil];
    NSData* xmlData=[NSData dataWithContentsOfFile:xmlPath];
    GDataXMLDocument* doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement* root=[doc rootElement];
    //NSLog(@"root:%@\n",root);
    NSArray* item_arr=[root elementsForName:@"item"];
    GDataXMLElement* item=[item_arr objectAtIndex:0];
    //NSLog(@"helpAAA...%@\n",[item stringValue]);
    return [item stringValue];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark get ranks from server
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//rank:
//(void)init_cs_data
//didReceiveIQ

//update rank and avg data in cs_data.xml
-(void)updateRankAndAvg{
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"csData.xml"];
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    NSXMLDocument *doc=[[NSXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    NSXMLElement * root=[doc rootElement];
    NSArray* arr1=[root elementsForName:@"data"];
    
    [[[arr1 objectAtIndex:0] attributeForName:@"monthRank"] setStringValue:[NSString stringWithFormat:@"%d",monthRank]];
    [[[arr1 objectAtIndex:0] attributeForName:@"daysAvg"] setStringValue:[NSString stringWithFormat:@"%d",daysAvg]];
    [[[arr1 objectAtIndex:0] attributeForName:@"selfAvg"] setStringValue:[NSString stringWithFormat:@"%d",selfAvg]];
    
    xmlData=doc.XMLData;
    [xmlData writeToFile:filePath atomically:YES];
}

-(void)queryNewRankAndAvg{
    
//    NSDate *d=[NSDate date];
//    NSTimeZone *zone=[NSTimeZone systemTimeZone];
//    NSTimeInterval interval=[zone secondsFromGMTForDate:d];
//    d=[d dateByAddingTimeInterval:interval];
//    if ([self towDaysGap:d andThePassedDate:sentDate]==0) {
//        printf("###no query\n");
//        return;
//    }
    printf("###query for rank\n");
    NSXMLElement* sp=[NSXMLElement elementWithName:@"query"];
    [sp addAttributeWithName:@"xmlns" stringValue:rankSP];
    
    NSXMLElement* iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"from" stringValue:usr];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:usr];
    
    [iq addChild:sp];
    
    [[self xmppStream]sendElement:iq];
    printf("###query new rank and avg\n");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark sent importence to server
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)readDataToArray{
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"time_len.xml"];
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    NSXMLDocument *doc=[[NSXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    NSXMLElement * root=[doc rootElement];
    NSArray* arr1=[root elementsForName:@"oneDay"];
    //int count=[arr1 count];
    
    NSDate *d=[NSDate date];
    NSTimeZone *zone=[NSTimeZone systemTimeZone];
    NSTimeInterval interval=[zone secondsFromGMTForDate:d];
    d=[d dateByAddingTimeInterval:interval];
    
    NSTimeInterval n=[d timeIntervalSinceReferenceDate];
    NSTimeInterval p=[sentDate timeIntervalSinceReferenceDate];
    printf("###sentDate:%s\n",[sentDate.description UTF8String]);
    NSInteger now=((NSInteger)n)/3600/24;
    NSInteger passed=((NSInteger)p)/3600/24;
    NSInteger gap=now-passed;
    //    printf("###count=%d gap=%d\n",count,gap);
    passedDates=[[NSMutableArray alloc]init];
    for (int i=0; i<MIN(MIN([arr1 count], gap), 30); i++) {
        [passedDates addObject:[arr1 objectAtIndex:i]];
    }
    printf("###readDataToArray\n");
    
}


//把最久的没发的一天的使用时间发给服务器
-(void)sendOneDatesLenToServer{
    if (offset>[passedDates count]-1) {
        return;
    }
    printf("offset=%d,sentDate=%s\n",offset,[sentDate.description UTF8String]);
    NSXMLElement* oneDay=[passedDates objectAtIndex:offset];
    NSLog(@"##:\n%@\n",oneDay);
    NSString* dateStr=[[oneDay attributeForName:@"date"]stringValue];
    dateStr=[dateStr substringToIndex:10];
    NSString* lenStr=[[oneDay attributeForName:@"len"]stringValue];
    
    //NSXMLElement* new_oneDay=[NSXMLElement elementWithName:@"record"];
    NSXMLElement* date_node=[NSXMLElement elementWithName:@"date"];
    [date_node setStringValue:dateStr];
    NSXMLElement* len_node=[NSXMLElement elementWithName:@"time"];
    [len_node setStringValue:lenStr];
    //[new_oneDay addChild:date_node];
    //[new_oneDay addChild:len_node];
    
    NSXMLElement* sp=[NSXMLElement elementWithName:@"query"];
    [sp addAttributeWithName:@"xmlns" stringValue:sendSP];
    
    NSXMLElement* iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"from" stringValue:usr];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:usr];
    
    [iq addChild:sp];
    //[iq addChild:new_oneDay];
    [iq addChild:date_node];
    [iq addChild:len_node];
    
    [[self xmppStream]sendElement:iq];
    NSLog(@"###sendOneDateLenToServer iq:\n%@\n",iq);
}

-(void)sentDatePlus{
    NSLog(@"!!! in sentDatePlus\n");
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"csData.xml"];
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    NSXMLDocument *doc=[[NSXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    NSXMLElement * root=[doc rootElement];
    NSArray* arr1=[root elementsForName:@"data"];
    
    NSTimeInterval nnn=3600*24;
    sentDate=[sentDate initWithTimeInterval:nnn sinceDate:sentDate];
    offset++;
    [[[arr1 objectAtIndex:0] attributeForName:@"sentDate"] setStringValue:sentDate.description];
    xmlData=doc.XMLData;
    [xmlData writeToFile:filePath atomically:YES];
    NSLog(@"sentDate:%@",sentDate.description);
}

//init CS_data
-(void)init_cs_data{
    NSLog(@"#initCSData\n");
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"csData.xml"];
    
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * csData=[doc rootElement];
    //    NSLog(@"#Data\n");
    NSArray* arr1=[csData elementsForName:@"data"];
    NSString* sss=[[[arr1 objectAtIndex:0] attributeForName:@"sentDate"] stringValue];
    //NSLog(@"sentData sss=%@\n",sss);
    if ([sss isEqualToString:@""]) {
        NSDate *d=[NSDate date];
        NSTimeZone *zone=[NSTimeZone systemTimeZone];
        NSTimeInterval interval=[zone secondsFromGMTForDate:d];
        sentDate=[d dateByAddingTimeInterval:interval];
    }
    else
        sentDate=[DataManager convertNSStringToNSDate:sss];
    offset=0;
    //[self readDataToArray];
       
    //rankData
    sss=[[[arr1 objectAtIndex:0] attributeForName:@"monthRank"] stringValue];
    monthRank=[sss integerValue];
    sss=[[[arr1 objectAtIndex:0] attributeForName:@"daysAvg"] stringValue];
    daysAvg=[sss integerValue];
    sss=[[[arr1 objectAtIndex:0] attributeForName:@"selfAvg"] stringValue];
    selfAvg=[sss integerValue];
    //    NSLog(@"#connect datas\n");
    //connect datas
    NSArray* arr2=[csData elementsForName:@"csLinkInfo"];
    usr=[[[arr2 objectAtIndex:0] attributeForName:@"usr"] stringValue];
    server=[[[arr2 objectAtIndex:0] attributeForName:@"server"] stringValue];
    pwd=[[[arr2 objectAtIndex:0] attributeForName:@"pwd"] stringValue];
    sendSP=[[[arr2 objectAtIndex:0] attributeForName:@"sendSP"] stringValue];
    rankSP=[[[arr2 objectAtIndex:0] attributeForName:@"rankSP"] stringValue];
//    NSString* serverName=[[[arr2 objectAtIndex:0] attributeForName:@"serName"] stringValue];
    
    if ([usr isEqualToString:@""]) {
        usr= @"wcc16711";
        pwd= @"12345";
    }
    
    
}

//向服务端发送数据
-(void)sendDataToServer{
    
//    NSDate *d=[NSDate date];
//    NSTimeZone *zone=[NSTimeZone systemTimeZone];
//    NSTimeInterval interval=[zone secondsFromGMTForDate:d];
//    d=[d dateByAddingTimeInterval:interval];
    
    if (offset>[passedDates count]-1) {
        printf("###no send\n");
        [self queryNewRankAndAvg];
        [self updateRankAndAvg];
        return;
    }
    
    if ([xmppStream isConnected ]) {
        printf("##c is connected\n");
        [self sendOneDatesLenToServer];
    }
    else{
        printf("##c is disconnected\n");
    }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark client connect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupStream{
    
    //初始化XMPPStream
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
    
}

-(void)goOnline{
    
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    
}

-(void)goOffline{
    
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
    
}

-(BOOL)connect
{
    
    [self setupStream];
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (usr == nil || pwd == nil) {
        return NO;
    }
    
    //设置用户
    [xmppStream setMyJID:[XMPPJID jidWithString:usr]];
    //设置服务器
    [xmppStream setHostName:server];
    //密码
    password = pwd;
    
    //连接服务器
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:3 error:&error]) {
        NSLog(@"cant connect to ... %@", server);
        return NO;
    }
    else{
        NSLog(@"connected...\n");
    }
    
    return YES;
    
}

-(void)disconnect{
    
    [self goOffline];
    [xmppStream disconnect];
    
}
//--------------
//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    isOpen = YES;
    NSError *error = nil;
    
    //验证密码
    [[self xmppStream] authenticateWithPassword:password error:&error];
    
    NSLog(@"did_connected\nID:%@\npswd:%@\n",usr,pwd);
    
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    //弹出窗口“连接网络失败！”
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"连接网络失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

//验证not通过
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    //NSLog(@"didNotAuthenticate:\n%@\n",error);
    NSError *error2 = nil;
    if ([xmppStream registerWithPassword:password error:&error2]) {
        [[self xmppStream] authenticateWithPassword:password error:&error2];
    }
}
//DidRegister
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"DidRegister\n");
    NSError *error = nil;
    //验证密码
    [[self xmppStream] authenticateWithPassword:password error:&error];
}

//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    [self goOnline];
    NSLog(@"did_authenticate\n");
    
    //发送
    if (option==1) {
        [self sendDataToServer];
        option=0;
    }

}

//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    NSLog(@"message = %@", message);
    
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:msg forKey:@"msg"];
    [dict setObject:from forKey:@"sender"];
    
    //消息委托(这个后面讲)
    //[messageDelegate newMessageReceived:dict];
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    NSLog(@"#receive#iq= %@\n",iq);
    
    NSXMLElement* back=[iq elementForName:@"back"];
    NSString* typeStr=[[back attributeForName:@"type"]stringValue];
    
    printf("backType:%s\n",[typeStr UTF8String]);
    if ([typeStr isEqualToString:@"success"]) {
        [self sentDatePlus];
        [self sendDataToServer];
    }
    NSString* sss;
    if ([typeStr isEqualToString:@"rank"]) {
        sss=[[back elementForName:@"rank"]stringValue];
        NSInteger rank=[sss integerValue];
        sss=[[back elementForName:@"allAvgTime"]stringValue];
        NSInteger all_avg=[sss integerValue];
        sss=[[back elementForName:@"avgTime"]stringValue];
        NSInteger self_avg=[sss integerValue];
        sss=[[back elementForName:@"num"]stringValue];
        NSInteger numOfUsers=[sss integerValue];
        
        selfAvg=self_avg;
        daysAvg=all_avg;
        monthRank=rank/numOfUsers*100+1;
        [self updateRankAndAvg];
        //弹窗“数据已同步”
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"数据已同步" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark others
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [ViewController sharedViewController];
    
    ViewController *one;
    TableViewController *two;
    settingViewController *three;
    allViewController *four;
    
    one=[ViewController sharedViewController];    
    two = [TableViewController sharedViewController];    
    three=[[settingViewController alloc]init];
    four=[[allViewController alloc]init];    
    NSArray *ctrlArr = [NSArray arrayWithObjects:one,two,three,four,nil];

	NSMutableDictionary *imgDic = [NSMutableDictionary dictionaryWithCapacity:3];
	[imgDic setObject:[UIImage imageNamed:@"首页-2.png"] forKey:@"Default"];
	[imgDic setObject:[UIImage imageNamed:@"首页.png"] forKey:@"Highlighted"];
	[imgDic setObject:[UIImage imageNamed:@"首页.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic2 = [NSMutableDictionary dictionaryWithCapacity:3];
	[imgDic2 setObject:[UIImage imageNamed:@"图表-2.png"] forKey:@"Default"];
	[imgDic2 setObject:[UIImage imageNamed:@"图表-1.png"] forKey:@"Highlighted"];
	[imgDic2 setObject:[UIImage imageNamed:@"图表-1.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic3 = [NSMutableDictionary dictionaryWithCapacity:3];
	[imgDic3 setObject:[UIImage imageNamed:@"设置2.png"] forKey:@"Default"];
	[imgDic3 setObject:[UIImage imageNamed:@"设置1.png"] forKey:@"Highlighted"];
	[imgDic3 setObject:[UIImage imageNamed:@"设置1.png"] forKey:@"Seleted"];
	NSMutableDictionary *imgDic4 = [NSMutableDictionary dictionaryWithCapacity:3];
	[imgDic4 setObject:[UIImage imageNamed:@"指南-1.png"] forKey:@"Default"];
	[imgDic4 setObject:[UIImage imageNamed:@"指南-2.png"] forKey:@"Highlighted"];
	[imgDic4 setObject:[UIImage imageNamed:@"指南-2.png"] forKey:@"Seleted"];
	
	NSArray *imgArr = [NSArray arrayWithObjects:imgDic,imgDic2,imgDic3,imgDic4,nil];
	
	leveyTabBarController = [[LeveyTabBarController alloc] initWithViewControllers:ctrlArr imageArray:imgArr];
	[leveyTabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tab_background.png"]];
	[leveyTabBarController setTabBarTransparent:YES];
    self.window.rootViewController = leveyTabBarController;
        
    //youmi:
    [YouMiConfig launchWithAppID:@"[Your AppID]" appSecret:@"[Your AppSecret]"];

    [self.window makeKeyAndVisible];
    
    [YouMiConfig setFullScreenWindow:self.window];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"app will resign active");
    self.viewController.enter_back_time=[NSDate date];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(self.swicthIsOn)
    {
        [BackgroundRunning recordRunningState:self.viewController.one_time.beginTime];
    }
    else
    {
        [BackgroundRunning clearPreviousState];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"enter forground function called!");
    self.viewController.enter_fore_time=[NSDate date];
  
    if(self.swicthIsOn)
    {
        NSLog(@"adding time:%f", [self.viewController.enter_fore_time timeIntervalSinceDate:self.viewController.enter_back_time]);
        self.useTime_now += [self.viewController.enter_fore_time timeIntervalSinceDate:self.viewController.enter_back_time];
    }
    [BackgroundRunning clearPreviousState];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"notification received!");
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:notification.alertBody message:notification.alertAction delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
}


@end
