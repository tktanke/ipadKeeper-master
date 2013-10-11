//
//  OneTime.h
//  Time_xml_file
//
//  Created by new239 on 13-6-22.
//  Copyright (c) 2013年 scut.zero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface OneTime : NSObject

@property(nonatomic,retain) NSDate* beginTime;
@property(nonatomic,retain) NSDate* endTime;

-(id)init;
-(id)initWithBegin:(NSDate*) begin;
-(id)initWithBegin:(NSDate *)begin andEnd:(NSDate*) end;
-(NSInteger) minuteLength;
-(void)write_thisTime_to_today;


@end
