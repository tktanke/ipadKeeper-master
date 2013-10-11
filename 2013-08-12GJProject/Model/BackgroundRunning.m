//
//  BackgroundRunning.m
//  儿童管家
//
//  Created by 老逸 on 13-7-17.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import "BackgroundRunning.h"

@interface BackgroundRunning()

+(NSString *)getFilePath;

@end

@implementation BackgroundRunning

+(NSString *)getFilePath
{
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docDir=[paths objectAtIndex:0];
    NSString* filePath = [docDir stringByAppendingPathComponent:@"runningState.dat"];
    return filePath;
}

+(void)recordRunningState:(NSDate *)date
{
    [self clearPreviousState];
    NSString *dateStr = [date description];
    NSString *filePath = [self getFilePath];
    NSError *error;
    [dateStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

+(void)clearPreviousState
{
    NSString *filePath = [self getFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath])
    {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
    }
}
+(BOOL)checkIfRunningBeforeExit
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self getFilePath];
    if([fileManager fileExistsAtPath:filePath])
    {
        NSLog(@"Found running before exit");
        return YES;
    }
    NSLog(@"Not found running before exit");
    return NO;
}

+(NSDate *)startTime
{
    NSString *filePath = [self getFilePath];
    NSError *error;
    NSString *time = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSDateFormatter* dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss +zzzz"];
    NSDate* date=[dateFormatter dateFromString:time];
    NSLog(@"Get start time:%@", [date description]);
    return date;
}



@end
