//
//  TableViewController.h
//  GJ
//
//  Created by apple NO5 on 13-6-27.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//
//
//#import <UIKit/UIKit.h>
//#import "ViewController.h"
//
//@interface TableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
//
//@property(nonatomic,retain)NSArray  *dataList;
//@property(nonatomic,retain)UITableView *myTableView;
//
//@end


#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "ViewController.h"
#import "AppDelegate.h"

#define day 16

@interface TableViewController : UIViewController<CPTPlotDataSource>{
@private
    CPTXYGraph *barChart;//图形
    NSMutableArray *dataForPlot;//用来存储数据的数组
    NSInteger count;
    CPTGraphHostingView *hostingView;
    CPTXYPlotSpace *plotSpace;
    NSInteger todayTime;
    CPTBarPlot *barPlot;
    NSMutableArray *mu;
    AppDelegate *app;
}

-(IBAction)update:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *stageImage;
@property (weak, nonatomic) IBOutlet UILabel *stageLabel;

-(void)paint;

+(TableViewController *)sharedViewController;

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot;

@end