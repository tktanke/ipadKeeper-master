//
//  OneTime.m
//  Time_xml_file
//
//  Created by new239 on 13-6-22.
//  Copyright (c) 2013年 scut.zero. All rights reserved.
//

#import "OneTime.h"
#import "DataManager.h"

@implementation OneTime

@synthesize beginTime=_beginTime;
@synthesize endTime=_endTime;

- (id)init
{
    self = [super init];
    if (self) {
        self.beginTime=[NSDate date];

        self.endTime=[NSDate date];
    }
    return self;
}

- (id)initWithBegin:(NSDate *)begin
{
    self = [super init];
    if (self) {
        _beginTime=begin;
    }
    return self;
}
-(id)initWithBegin:(NSDate *)begin andEnd:(NSDate *)end{
    self = [super init];
    if (self) {
        _beginTime=begin;
        _endTime=end;
    }
    return self;
}
-(NSInteger) minuteLength{
    NSTimeInterval sec=[_endTime timeIntervalSinceDate:_beginTime];
    return (((NSInteger)sec)/60);
}

-(void)write_thisTime_to_today
{
    /*NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString *todayXmlFilePath = [docPath stringByAppendingPathComponent:@"todayTime.xml"];*/
    NSString *todayXmlFilePath = [DataManager todayTimeStr];
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:todayXmlFilePath];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * today=[doc rootElement];
    //printf("***********########\n");
    GDataXMLElement* b=[GDataXMLElement attributeWithName:@"begin" stringValue:_beginTime.description];
    GDataXMLElement* e=[GDataXMLElement attributeWithName:@"end" stringValue:_endTime.description];
    GDataXMLElement* one_time=[GDataXMLElement elementWithName:@"oneTime"];
    [one_time addAttribute:b];
    [one_time addAttribute:e];
    [today addChild:one_time];
    NSData* data=doc.XMLData;
    [data writeToFile:todayXmlFilePath atomically:YES];       
}


@end
