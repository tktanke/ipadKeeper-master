//
//  BackgroundRunning.h
//  儿童管家
//
//  Created by 老逸 on 13-7-17.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"


@interface BackgroundRunning : NSObject

+(void)recordRunningState:(NSDate *)date;
+(BOOL)checkIfRunningBeforeExit;
+(NSDate *)startTime;
+(void)clearPreviousState;

@end
