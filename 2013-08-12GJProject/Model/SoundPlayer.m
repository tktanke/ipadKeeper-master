//
//  SoundPlayer.m
//  儿童管家
//
//  Created by 老逸 on 13-8-10.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import "SoundPlayer.h"
#import <AudioToolbox/AudioToolbox.h>

static BOOL firstTime = YES;
static SystemSoundID audioEffect;
@implementation SoundPlayer

+(void)playButtonSound
{
    if(firstTime)
    {
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"buttonSound2" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(pathURL), &audioEffect);
        firstTime = NO;
    }
    AudioServicesPlaySystemSound(audioEffect);
    // call the following function when the sound is no longer used
    // (must be done AFTER the sound is done playing)
    //AudioServicesDisposeSystemSoundID(audioEffect);
}

@end
