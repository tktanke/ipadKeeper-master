//
//  TableViewController.m
//  GJ
//
//  Created by apple NO5 on 13-6-27.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import "TableViewController.h"
#import "DataManager.h"

static TableViewController* _sharedViewController;

@interface  TableViewController()

@end

@implementation TableViewController

+(TableViewController *)sharedViewController
{
    if(_sharedViewController == Nil)
    {
        _sharedViewController = [[TableViewController alloc]init];
    }
    return _sharedViewController;
}

//同步数据
-(IBAction)update:(id)sender{
    [app readDataToArray];
    if ([app.passedDates count]==0) {
        //弹窗“数据已同步”
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"数据已同步" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [app connect];
    app.option=1;//option=1表示选择发送数据
}

-(void)reflashStage
{
    NSArray *useTimeInPassSevenDay = [DataManager usedMinutesInPassDays:6];
    int counter = 0;
    for (NSString *timesStr in useTimeInPassSevenDay)
    {
        if([timesStr intValue] > 60)
            ++counter;
    }
    self.stageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.stageLabel.numberOfLines = 0;
    if ([ViewController sharedViewController].usetime > 3600)
    {
        ++counter;
    }
    if(counter > 0)
    {
        
    [self.stageImage setImage:[UIImage imageNamed:@"bad.png"]];
        [self.stageLabel setText:[NSString stringWithFormat:@"最近一周有%d天使用时间超过一小时，请控制孩子iPad的使用时间，保护孩子的眼睛", counter]];
    }
    else
    {
        [self.stageImage setImage:[UIImage imageNamed:@"good.png"]];
        [self.stageLabel setText:@"最近一周iPad使用时间控制良好\n     "];
    }
}

-(void)paint{
    [self reflashStage];
    [barChart removeFromSuperlayer];
    barChart = [[CPTXYGraph alloc]initWithFrame:CGRectZero];//创建图形的边框
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];//
    CPTXYGraph *graph = (CPTXYGraph *)[theme newGraph];
    
    graph.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    //[barChart applyTheme:theme];//设定图形的背景主题
    
    
    //self.view由UIView变为可加载CPTGraph的CPTGraphHostingView
    CGRect frame=CGRectMake(0, 330, 800, 600);
    hostingView=[[CPTGraphHostingView alloc]initWithFrame:frame];
    hostingView.hostedGraph = barChart;//视图
    [self.view addSubview:hostingView];
    
    //CPTGraph在hostingView中的偏移
    barChart.paddingBottom = 0.0;
    barChart.paddingTop =0.0;
    barChart.paddingLeft = barChart.paddingRight =10.0;
    
    //绘图区在CPTGraph中的偏移
    barChart.plotAreaFrame.paddingLeft = 40.0;
    barChart.plotAreaFrame.paddingRight = 5.0;
    barChart.plotAreaFrame.paddingTop = 20.0;
    barChart.plotAreaFrame.paddingBottom =80.0;
    
    //图形边框：无
    barChart.plotAreaFrame.borderLineStyle = nil;
    barChart.plotAreaFrame.cornerRadius = 0.0f;
    
    //绘图区
    plotSpace = (CPTXYPlotSpace *)barChart.defaultPlotSpace;
    //允许滚动
    plotSpace.allowsUserInteraction =NO;
//    [hostingView setAllowPinchScaling:NO];
    //绘图区的范围
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(202)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromFloat(18.5)];
    
    //线条风格
    CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc]init];
    //lineStyle.lineColor = [CPTColor colorWithComponentRed:50.0f green:150.0f blue:150.0f alpha:1.0f];
    lineStyle.lineColor = [CPTColor clearColor];
    lineStyle.lineWidth = 0.0f;
    
    //xy坐标系
    CPTXYAxisSet *axisset = (CPTXYAxisSet *)barChart.axisSet;
    CPTXYAxis *x = axisset.xAxis;
    x.axisLineStyle = lineStyle;
    x.labelingPolicy=CPTAxisLabelingPolicyNone;
    x.axisConstraints=[CPTConstraints constraintWithLowerOffset:0.0];
    x.majorTickLineStyle = nil;//大刻度线线型
    x.majorTickLength = 10;//大刻度线长度
    x.minorTickLineStyle = nil;//小刻度线
    x.majorIntervalLength = CPTDecimalFromString(@"5");//大刻度线间隔单位
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");//原点坐标
    CPTMutableTextStyle *text=[CPTMutableTextStyle textStyle];
    text.color=[CPTColor blackColor];
    text.fontSize=21.0f;
    x.titleTextStyle=text;
    //x.title=@"最近30天使用情况（1表示今天）";
    
    x.axisConstraints=[CPTConstraints constraintWithLowerOffset:0];
    x.tickDirection=CPTSignNegative;
    x.labelingPolicy=CPTAxisLabelingPolicyNone;
    
    NSMutableArray *lab=[NSMutableArray arrayWithCapacity:day];
    
    static CPTMutableTextStyle *lts=nil;
    lts=[[CPTMutableTextStyle alloc]init];
    lts.color=[CPTColor blackColor];
    lts.fontSize=13.0;
    
    for(int i=day;i>0;i--){
        CPTAxisLabel *label=[[CPTAxisLabel alloc]initWithText:[NSString stringWithFormat:@"%d",i] textStyle:lts];
        label.tickLocation=CPTDecimalFromInt(i);
        label.offset=x.labelOffset+x.majorTickLength;
        [lab addObject:label];
    }
    
//    x.axisLabels = [NSSet setWithArray:lab];
    
    CPTXYAxis *y = axisset.yAxis; 
    y.axisLineStyle = lineStyle;
    y.majorTickLineStyle = lineStyle;
    
    lineStyle.lineColor=[CPTColor redColor];
    y.minorTickLineStyle = nil;
    y.majorIntervalLength = CPTDecimalFromString(@"60");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    CPTMutableTextStyle *tempTextStyle = [[CPTMutableTextStyle alloc]init];
    tempTextStyle.color = [CPTColor clearColor];
    y.labelTextStyle = tempTextStyle ;
    
    y.majorGridLineStyle=lineStyle;
    CPTPlotRange *range=[CPTPlotRange plotRangeWithLocation:CPTDecimalFromString(@"0") length:CPTDecimalFromString(@"32")];
    y.gridLinesRange=range;
    
    
    //柱状图的格式
    barPlot = [[CPTBarPlot alloc]init];
    barPlot.lineStyle = nil;
    //barPlot.fill = [CPTFill fillWithImage:[CPTImage imageForPNGFile:@"blue_filled.png" ]];
    barPlot.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.42f green:0.79f blue:0.99f alpha:1.0f]];

    //barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:96.0f green:178.0f blue:224.0f alpha:1] horizontalBars:NO];
    barPlot.baseValue = CPTDecimalFromString(@"0");//柱状图开始绘制的基值（大于向上，小于向下）
    barPlot.barOffset = CPTDecimalFromDouble(1.6);//偏移
    barPlot.barWidth = CPTDecimalFromDouble(0.7);//设定柱子的宽度
    
    CPTMutableTextStyle *textStyle=[CPTMutableTextStyle textStyle];
    textStyle.color=[CPTColor blackColor];
    textStyle.fontSize=29;
    barPlot.labelTextStyle=textStyle;
    
    barPlot.dataSource = self;//数据源，必须实现CPPlotDataSource协议
    [barChart addPlot:barPlot toPlotSpace:plotSpace];//将柱状图添加到绘图空间
    [self.view setNeedsDisplay];
}

-(CPTLayer*)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index{
    NSDecimalNumber *num = nil;
    NSArray *list=[DataManager  the_passed_9_days_timeLen];

    todayTime = [ViewController sharedViewController].usetime;
    todayTime /= 60;

    mu=[[NSMutableArray alloc]init];
    
    NSNumber *n=[[NSNumber alloc]initWithInt:todayTime];
    [mu addObject:n];
    [mu addObjectsFromArray:list];
    num = (NSDecimalNumber*)[NSDecimalNumber numberWithInteger:[mu[day - 1 - index] intValue]];
    CPTTextLayer *label=[[CPTTextLayer alloc]initWithText:[NSString stringWithFormat:@"%d",[num intValue]]];
    CPTMutableTextStyle *textstyle=[label.textStyle mutableCopy];

    textstyle.fontSize = 15;
    textstyle.color=[CPTColor blackColor];
    
    label.textStyle=textstyle;
    return label;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //count=0;
    
    //app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
	// Do any additional setup after loading the view, typically from a nib.
    //更新排名
    //[app init_cs_data];
    [self paint];
    
}

-(void)viewDidAppear:(BOOL)animated{

    NSInteger todayTime_now = [ViewController sharedViewController].usetime;
    todayTime_now /= 60;

    if(todayTime_now!=todayTime)
        [self paint];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark Plot Data Source Methods
//柱状图个数
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    return day;
}

//柱状图数据,每个点都要返回两个值即X轴与Y轴
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = nil;
    NSArray *list=[DataManager  the_passed_9_days_timeLen];
    
    todayTime = [ViewController sharedViewController].usetime ;
    todayTime /= 60;

    mu=[[NSMutableArray alloc]init];
    
    NSNumber *n=[[NSNumber alloc]initWithInt:todayTime];
    [mu addObject:n];
    [mu addObjectsFromArray:list];
    
    NSArray *oldArray=mu;
    int tempNum;
    if([plot isKindOfClass:[CPTBarPlot class]])
    {
        switch (fieldEnum)
        {
            case CPTBarPlotFieldBarLocation://X轴位置
                num = (NSDecimalNumber*)[NSDecimalNumber numberWithUnsignedInteger:index];
                break;
            case CPTBarPlotFieldBarTip://Y轴位置
                tempNum = [oldArray[day - index - 1] intValue];
                if(tempNum > MINUTE_OUT_OF_RANGE)
                {
                    tempNum = UPPER_BOUND;
                }
                num = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:tempNum] decimalValue]];
                //num = [NSDecimalNumber decimalNumberWithDecimal:[NSNumber numberWithInt: tempNum]];
            default:
                break;
        }
    }
    return num;
}

@end
