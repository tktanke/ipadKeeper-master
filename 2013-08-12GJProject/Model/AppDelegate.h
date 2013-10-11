//
//  AppDelegate.h
//  GJ
//
//  Created by apple NO5 on 13-6-18.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"
#import "XMPP.h"
#import "SettingData.h"
#import "BackgroundRunning.h"

@class ViewController;
@class LeveyTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate>{

    //xmpp
    XMPPStream* xmppStream;
    NSString* password;
    BOOL isOpen;
    NSDate * sentDate;
    NSInteger offset;
}

//全局的警告时间
@property int warningTime;//设置的提醒时间
@property int deadlineTime;//设置的报警时间（首页显示报警的Label，已被写死为60分钟）
//全局的开关状态
@property BOOL swicthIsOn;//监控开关的状态
@property BOOL passwordProtect;//密码保护的开启状态
@property int useTime_now;//此次监控已通过的时间

@property NSString *code;//密码

@property SettingData* setting_data;//设置类对象，用于读取设置信息

//导航条
@property(strong, nonatomic)IBOutlet LeveyTabBarController *leveyTabBarController;

@property(retain,nonatomic)IBOutlet UITabBarController *tabBar;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//xmpp
@property(nonatomic,readonly)XMPPStream* xmppStream;
@property(nonatomic)NSDate* sentDate;
@property(nonatomic,retain)NSMutableArray* passedDates;
@property NSInteger offset;
//rank
@property(nonatomic)NSInteger monthRank;
@property(nonatomic)NSInteger daysAvg;
@property(nonatomic)NSInteger selfAvg;
//cs connect data
@property NSString* server;
@property NSString* usr;
@property NSString* pwd;
@property NSString* sendSP;
@property NSString* rankSP;

@property NSInteger option;

//xmpp
-(BOOL)connect;
-(void)disconnect;
-(void)setupStream;
-(void)goOnline;
-(void)goOffline;
-(void)sendOneDatesLenToServer;
-(void)readDataToArray;
-(void)sendDataToServer;
-(void)init_cs_data;

-(void)queryNewRankAndAvg;
-(void)updateRankAndAvg;

-(NSString*)getHistoryRecordsAdvice:(NSInteger)index;
-(NSString*)getHelp;
-(NSString*)getServerIP;

@end
