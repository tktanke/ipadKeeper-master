//
//  DataManager.m
//  儿童管家
//
//  Created by 老逸 on 13-8-1.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

/*
 time_len.xml:保存每天的总用时
 today_time.xml:保存当天的每次使用时间
 */
#import "DataManager.h"
#import "GDataXMLNode.h"
#import "ViewController.h"
#import "AppDelegate.h"

static NSString *_todayTimeStr = 0;
static NSString *_timeLengthStr = 0;

@interface DataManager()




@end

@implementation DataManager

+(NSString *)todayTimeStr
{
    if(_todayTimeStr == 0)
    {
        NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
         _todayTimeStr = [docPath stringByAppendingPathComponent:@"todayTime.xml"];
    }
    return _todayTimeStr;
}
+(NSString *)timeLengthStr
{
    if(_timeLengthStr == 0)
    {
        NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* docPath=[paths objectAtIndex:0];
        _timeLengthStr = [docPath stringByAppendingPathComponent:@"time_len.xml"];
    }
    return _timeLengthStr;
}


+(NSDate *)nowTimeWithInterval
{
    NSDate *now = [NSDate date];
    NSTimeZone *zone=[NSTimeZone systemTimeZone];
    NSInteger interval=[zone secondsFromGMTForDate:now];
    now=[now dateByAddingTimeInterval:interval];
    return now;
}


+(NSDate*)latestDate
{
    NSString *xmlFilePath = [DataManager todayTimeStr];
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:xmlFilePath];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * root=[doc rootElement];
    NSArray* arr=[root elementsForName:@"oneTime"];
    if ([arr count]>0) {
        NSString* sss=[[[arr objectAtIndex:0]attributeForName:@"begin"]stringValue];
        return [self convertNSStringToNSDate:sss];
    }
    return [self nowTimeWithInterval];
}

+(NSInteger) todayUsedTimes
{
    NSString *xmlFilePath = [DataManager todayTimeStr];
    NSLog(@"Getting today used times");
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:xmlFilePath];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    
    GDataXMLElement * root=[doc rootElement];
    NSArray* arr=[root elementsForName:@"oneTime"];
    int counter = 0;
    for(GDataXMLElement * ddd in arr)
    {
        ++counter;
    }
    return counter;

}

//获得当天过去已经使用的时间(分钟)
+(NSInteger) todayUsedMinutes
{
    NSString *xmlFilePath = [DataManager todayTimeStr];
    NSLog(@"Getting today used minutes");
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:xmlFilePath];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    
    NSInteger m_len=0;
    GDataXMLElement * root=[doc rootElement];
    NSArray* arr=[root elementsForName:@"oneTime"];
    for(GDataXMLElement * ddd in arr)
    {
        NSString* begin_time=[[ddd attributeForName:@"begin"] stringValue];
        NSString* end_time=[[ddd attributeForName:@"end"]stringValue];
        
        NSDateFormatter* datefff=[[NSDateFormatter alloc]init];
        [datefff setDateFormat:@"yyyy-MM-dd HH:mm:ss +zzzz"];
        NSDate* beginT=[datefff dateFromString:begin_time];
        NSDate* endT=[datefff dateFromString:end_time];
        //printf("b=%s\ne=%s\n",[beginT.description UTF8String],[endT.description UTF8String]);
        
        NSInteger len=(NSInteger)[endT timeIntervalSinceDate:beginT];
        //NSLog(@"begin: *%@*\nend: *%@*\n",beginT,end_time);
        m_len+=len;
        
        //printf("  #%d   ",len);
    }
    m_len=m_len/60;
    return m_len;
}

//新的一天开始时，清空todayTime.xml中的内容，以一个新的文件记录当天的各个时间段
+(void) clearTodayTime
{
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString *xmlFilePath = [DataManager todayTimeStr];
    NSString *copyToXmlFilePath = [docPath stringByAppendingPathComponent:@"copyToTodayTime.xml"];
    NSFileManager* fff=[NSFileManager defaultManager];
    NSError * err;
    [fff removeItemAtPath:xmlFilePath error:&err];
    [fff copyItemAtPath:copyToXmlFilePath toPath:xmlFilePath error:&err];
}

//
+(void)dealWithDaysGaps:(NSInteger) gapCount
{
    NSDate* latestDate=[self latestDate];
    NSInteger len=[DataManager todayUsedMinutes];
    
    NSTimeInterval sec=24*3600;
    
    //NSString* timeFilePath=[docPath stringByAppendingPathComponent:@"time_len.xml"];
    NSString *timeFilePath = [DataManager timeLengthStr];
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:timeFilePath];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * root=[doc rootElement];
    
    
    //add latestDate
    GDataXMLElement* ddd=[GDataXMLElement attributeWithName:@"date" stringValue:latestDate.description];
    GDataXMLElement* lll=[GDataXMLElement attributeWithName:@"len" stringValue:[NSString stringWithFormat:@"%d",len]];

    GDataXMLElement* times = [GDataXMLElement attributeWithName:@"times" stringValue:[NSString stringWithFormat:@"%d", [self todayUsedTimes] ]];
    GDataXMLElement* one=[GDataXMLElement elementWithName:@"oneDay"];
    [one addAttribute:ddd];
    [one addAttribute:lll];
    [one addAttribute:times];
    [root addChild:one];
    //printf("addLatest\n");
    
    NSDate* dateTemp;
    NSInteger nnn=0;
    if (gapCount>160) {
        nnn=gapCount-160;
    }
    for (int i=nnn; i<gapCount-1; i++)
    {
        dateTemp=[[NSDate alloc]initWithTimeInterval:(i+1)*sec sinceDate:latestDate];
        //printf("**%d**dateTemp=%s\n",i,[dateTemp.description UTF8String]);
        ddd=[GDataXMLElement attributeWithName:@"date" stringValue:dateTemp.description];
        lll=[GDataXMLElement attributeWithName:@"len" stringValue:[NSString stringWithFormat:@"0"]];
        times = [GDataXMLElement attributeWithName:@"times" stringValue:@"0"];
        one=[GDataXMLElement elementWithName:@"oneDay"];
        [one addAttribute:ddd];
        [one addAttribute:lll];
        [one addAttribute:times];
        [root addChild:one];
    }
    
    NSArray* arr1=[root elementsForName:@"oneDay"];
    NSInteger dayCount=[arr1 count];
    if (dayCount>320)
    {
        printf("***********didi*****\n");
        for (int i=0;i<[arr1 count]/2;i++) {
            [root removeChild:[arr1 objectAtIndex:i]];
        }
    }
    
    NSData* data=doc.XMLData;
    [data writeToFile:timeFilePath atomically:YES];
}

//获得两个日期之差
+(NSInteger) towDaysGap:(NSDate*) nowDate andThePassedDate:(NSDate*) passedDate
{
    
    NSTimeInterval n=[nowDate timeIntervalSinceReferenceDate];
    NSTimeInterval p=[passedDate timeIntervalSinceReferenceDate];
    printf("nowddd=%s\n",[nowDate.description UTF8String]);
    NSInteger now=((NSInteger)n/3600)/24;
    NSInteger passed=((NSInteger)p/3600)/24;
    
    return (now-passed);
    
    
}

//判断是否是新的一天

+(NSInteger) isNewDay:(NSDate*) nowDate
{
    NSDate* latest=[self latestDate];
    return [self towDaysGap:nowDate andThePassedDate:latest];
}


//获取过去days天内每天使用时间，返回数组
+(NSArray*)usedMinutesInPassDays:(int)days
{
    NSString *filePath = [DataManager timeLengthStr];
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * root=[doc rootElement];
    
    NSArray* arr1=[root elementsForName:@"oneDay"];
    NSMutableArray* Arr=[[NSMutableArray alloc]init];
    NSInteger nnn;
    days += 1;
    if ([arr1 count]>=days)
    {
        nnn=days;
        for (int i=[arr1 count]-1; i>[arr1 count]-nnn; i--)
        {
            [Arr addObject:  [[[arr1 objectAtIndex:i] attributeForName:@"len"]stringValue] ];
        }
    }
    else
    {
        nnn=[arr1 count];
        for (int i=nnn-1; i>=0; i--) {
            [Arr addObject:[[[arr1 objectAtIndex:i] attributeForName:@"len"]stringValue]];
        }
        
        for (int i=0; i<days-nnn; i++) {
            [Arr addObject:[NSString stringWithFormat:@"%d",0]];
        }
    }
    
    return Arr;
}

//获取过去days天内每天使用次数，返回数组
+(NSArray*)usedTimesInPassDays:(int)days
{
    NSString* filePath = [DataManager timeLengthStr];
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * root=[doc rootElement];
    
    NSArray* arr1=[root elementsForName:@"oneDay"];
    NSMutableArray* Arr=[[NSMutableArray alloc]init];
    NSInteger nnn;
    days += 1;
    if ([arr1 count]>=days)
    {
        nnn=days;
        for (int i=[arr1 count]-1; i>[arr1 count]-nnn; i--)
        {
            [Arr addObject:  [[[arr1 objectAtIndex:i] attributeForName:@"times"]stringValue] ];
        }
    }
    else
    {
        nnn=[arr1 count];
        for (int i=nnn-1; i>=0; i--) {
            [Arr addObject:[[[arr1 objectAtIndex:i] attributeForName:@"times"]stringValue]];
        }
        
        for (int i=0; i<days-nnn; i++) {
            [Arr addObject:[NSString stringWithFormat:@"%d",0]];
        }
    }
    
    return Arr;
}


//获得过去15天的使用时间，返回值是一个包含15个NSString类型的数组
+(NSArray*) the_passed_9_days_timeLen
{
    NSString* filePath = [DataManager timeLengthStr];
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * root=[doc rootElement];
    
    NSArray* arr1=[root elementsForName:@"oneDay"];
    NSMutableArray* Arr=[[NSMutableArray alloc]init];
    NSInteger nnn;
    if ([arr1 count]>=16) {
        nnn=16;
        for (int i=[arr1 count]-1; i>[arr1 count]-nnn; i--) {
            NSString *value = [[[arr1 objectAtIndex:i] attributeForName:@"len"]stringValue];
            
                [Arr addObject:value];
        }
    } else {
        nnn=[arr1 count];
        for (int i=nnn-1; i>=0; i--) {
            NSString *value = [[[arr1 objectAtIndex:i] attributeForName:@"len"]stringValue];
            
                [Arr addObject:value];
        }
        
        for (int i=0; i<16-nnn; i++) {
            [Arr addObject:[NSString stringWithFormat:@"%d",0]];
        }
    }
    
    return Arr;
    
    
}

//从NSString获得NSDate
+(NSDate*)convertNSStringToNSDate:(NSString*)sss
{
    NSDateFormatter* datefff=[[NSDateFormatter alloc]init];
    [datefff setDateFormat:@"yyyy-MM-dd HH:mm:ss +zzzz"];
    NSDate* beginT=[datefff dateFromString:sss];
    return beginT;
}

//文件初始化
+(void) initFile
{
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docDir=[paths objectAtIndex:0];
    NSString* todayTime_path=[docDir stringByAppendingPathComponent:@"todayTime.xml"];
    NSString* copyToTodayTime_path=[docDir stringByAppendingPathComponent:@"copyToTodayTime.xml"];
    NSString* settingData_path=[docDir stringByAppendingPathComponent:@"settingData.xml"];
    NSString* defaultSettingData_path=[docDir stringByAppendingPathComponent:@"defaultSettingData.xml"];
    NSString* time_len_path=[docDir stringByAppendingPathComponent:@"time_len.xml"];
    
    BOOL isDir;
    NSFileManager* fff=[NSFileManager defaultManager];
    if ([fff fileExistsAtPath:todayTime_path isDirectory:&isDir] && ! isDir) {
        
    } else {
        NSString* sss=@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><today></today>";
        NSData* fileData=[sss dataUsingEncoding:NSUTF8StringEncoding];
        [fff createFileAtPath:todayTime_path contents:fileData attributes:nil];
    }
    if ([fff fileExistsAtPath:copyToTodayTime_path isDirectory:&isDir] && ! isDir) {
        
    } else {
        NSString* sss=@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><today></today>";
        NSData* fileData=[sss dataUsingEncoding:NSUTF8StringEncoding];
        [fff createFileAtPath:copyToTodayTime_path contents:fileData attributes:nil];
    }
    if ([fff fileExistsAtPath:settingData_path isDirectory:&isDir] && ! isDir) {
        
    } else {
        NSString* sss=@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><setting><settingTime len=\"30\"/><user idName=\"00000000\" password=\"\" pswProtection=\"0\" deadlineTime=\"3600\" ifSentDataAutomaticly=\"1\"/></setting>";
        NSData* fileData=[sss dataUsingEncoding:NSUTF8StringEncoding];
        [fff createFileAtPath: settingData_path contents:fileData attributes:nil];
    }
    if ([fff fileExistsAtPath:defaultSettingData_path isDirectory:&isDir] && ! isDir) {
        
    } else {
        NSString* sss=@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><setting><settingTime len=\"30\"/><user idName=\"00000000\" password=\"\"  pswProtection=\"0\" deadlineTime=\"3600\" ifSentDataAutomaticly=\"1\"/></setting>";
        NSData* fileData=[sss dataUsingEncoding:NSUTF8StringEncoding];
        [fff createFileAtPath: defaultSettingData_path contents:fileData attributes:nil];
    }
    if ([fff fileExistsAtPath:time_len_path isDirectory:&isDir] && ! isDir) {
        
    } else {
        NSString* sss=@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><time_len></time_len>";
        
        NSData* fileData=[sss dataUsingEncoding:NSUTF8StringEncoding];
        [fff createFileAtPath:time_len_path contents:fileData attributes:nil];
    }
    //xmpp
    NSString* cs_path=[docDir stringByAppendingPathComponent:@"csData.xml"];
    if ([fff fileExistsAtPath:cs_path isDirectory:&isDir] && ! isDir) {
        
    } else {
        NSDate *d = [self nowTimeWithInterval];
        
        AppDelegate* app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
 
        NSString* sss=[[NSString alloc]initWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><csData><data sentDate=\"%@\" monthRank=\"1\" daysAvg=\"60\" selfAvg=\"0\"></data><csLinkInfo usr=\"\" pwd=\"123\" serName=\"fcl.com\"  server=\"%@\" sendSP=\"iosClient:iq:update\" rankSP=\"iosClient:iq:rank\"></csLinkInfo></csData>",d.description,[app getServerIP]];
        
        NSData* fileData=[sss dataUsingEncoding:NSUTF8StringEncoding];
        [fff createFileAtPath:cs_path contents:fileData attributes:nil];
    }
}

@end
