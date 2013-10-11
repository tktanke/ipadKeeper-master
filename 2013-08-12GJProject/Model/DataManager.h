//
//  DataManager.h
//  儿童管家
//
//  Created by 老逸 on 13-8-1.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MINUTE_OUT_OF_RANGE 180 //minutes
#define UPPER_BOUND 186

@interface DataManager : NSObject

//获取todayTime文件的路径
+(NSString *)todayTimeStr;
//获取time_len文件的路径
+(NSString *)timeLengthStr;
//获取当前时区的时间
+(NSDate *)nowTimeWithInterval;
//获取最近前一天的日期
+(NSDate*)latestDate;
//获取今天已使用的次数
+(NSInteger) todayUsedTimes;
//获取今天已使用的时间（已记录的时间）
+(NSInteger) todayUsedMinutes;
//清空今天的使用时间
+(void) clearTodayTime;
//处理日期变更问题
+(void)dealWithDaysGaps:(NSInteger) gapCount;
//获取当前日期与记录的最近日期之差
+(NSInteger) towDaysGap:(NSDate*) nowDate andThePassedDate:(NSDate*) passedDate;
//检测是否新一天，返回值大于0为True
+(NSInteger) isNewDay:(NSDate*) nowDate;
//过去days天内的使用总时间
+(NSArray*)usedMinutesInPassDays:(int)days;
//过去days天内的使用总次数
+(NSArray*)usedTimesInPassDays:(int)days;
//过去15天内每天的使用时间（柱状图使用）
+(NSArray*) the_passed_9_days_timeLen;
//完成字符串到NSDate的转换
+(NSDate*)convertNSStringToNSDate:(NSString*)sss;
//初始化数据文件
+(void) initFile;


@end
