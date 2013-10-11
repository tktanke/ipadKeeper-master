//
//  SettingData.m
//  Time_xml_file
//
//  Created by new239 on 13-6-24.
//  Copyright (c) 2013年 scut.zero. All rights reserved.
//

#import "SettingData.h"
#import "GDataXMLNode.h"

@implementation SettingData

@synthesize userIdName;
@synthesize userPassword;
@synthesize settingTimeLength;
@synthesize sentDataAutomaticly;

- (id)init
{
    self = [super init];
    if (self) {
        NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* docPath=[paths objectAtIndex:0];
        NSString* filePath=[docPath stringByAppendingPathComponent:@"settingData.xml"];
        
        NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
        
        GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
        GDataXMLElement * setting=[doc rootElement];
        
        NSArray* arr1=[setting elementsForName:@"settingTime"];
        NSString* sss=[[[arr1 objectAtIndex:0] attributeForName:@"len"] stringValue];
        NSLog(@"sss=%@\n",sss);
        self.settingTimeLength=[sss integerValue];
        
        NSArray* arr2=[setting elementsForName:@"user"];
        NSString* idNameStr=[[[arr2 objectAtIndex:0] attributeForName:@"idName"] stringValue];
        self.userIdName=idNameStr;
        NSString* pswordStr=[[[arr2 objectAtIndex:0] attributeForName:@"password"] stringValue];
        self.userPassword=pswordStr;
        NSString* pswProStr=[[[arr2 objectAtIndex:0] attributeForName:@"pswProtection"] stringValue];
        
        if([pswProStr isEqualToString:@"0"])
        {
            self.pswProtection = NO;
        }
        else
        {
            self.pswProtection = YES;
        }
        int num = 0;
        if(self.pswProtection)
            num = 1;
        NSLog(@"From file:pswProtection:%d", num);
        NSString *deadStr = [[[arr2 objectAtIndex:0] attributeForName:@"deadlineTime"] stringValue];
        self.deadline = [deadStr integerValue];
        NSString* sentStr=[[[arr2 objectAtIndex:0] attributeForName:@"ifSentDataAutomaticly"] stringValue];
        self.sentDataAutomaticly=sentStr;
        //NSLog(@"%@\n",sentStr);
        
    }
    return self;
}

-(void)set_a_new_settingTime:(NSInteger)minutes{
    NSInteger nnn =minutes;
    if(nnn==self.settingTimeLength)
        return;
    //printf("len=%d ***\n",minutes);

    self.settingTimeLength=nnn;
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"settingData.xml"];
    
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * setting=[doc rootElement];
    
    NSArray* arr1=[setting elementsForName:@"settingTime"];
    [[[arr1 objectAtIndex:0] attributeForName:@"len"] setStringValue:[NSString stringWithFormat:@"%d",self.settingTimeLength]];
    
    NSData* data=doc.XMLData;
    [data writeToFile:filePath atomically:YES];
    
}

-(void) set_a_new_userIdName:(NSString *)name{
    
    if([self.userPassword isEqualToString:name])
        return;
    
    self.userIdName=name;
    
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"settingData.xml"];
    
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * setting=[doc rootElement];
    
    NSArray* arr1=[setting elementsForName:@"user"];
    [[[arr1 objectAtIndex:0] attributeForName:@"idName"] setStringValue:[NSString stringWithFormat:@"%@",self.userIdName]];
    
    NSData* data=doc.XMLData;
    [data writeToFile:filePath atomically:YES];
}

-(void) set_a_new_userPassword:(NSString *)psword{
    if ([self.userPassword isEqualToString: psword]) {
        return;
    }
    
    self.userPassword=psword;
    
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"settingData.xml"];
    
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * setting=[doc rootElement];
    
    NSArray* arr1=[setting elementsForName:@"user"];
    [[[arr1 objectAtIndex:0] attributeForName:@"password"] setStringValue:[NSString stringWithFormat:@"%@",self.userPassword]];
    
    NSData* data=doc.XMLData;
    [data writeToFile:filePath atomically:YES];
}

-(void)set_psw_protection:(BOOL)switchOn
{
    if(self.pswProtection == switchOn)
    {
        return;
    }
    self.pswProtection=switchOn;
    int num = 0;
    if(switchOn)
    {
        num = 1;
    }
    NSLog(@"write to file:pswProSwitch:%d", num);
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"settingData.xml"];
    
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * setting=[doc rootElement];
    
    NSArray* arr1=[setting elementsForName:@"user"];
    [[[arr1 objectAtIndex:0] attributeForName:@"pswProtection"] setStringValue:[NSString stringWithFormat:@"%d",num]];
    
    NSData* data=doc.XMLData;
    [data writeToFile:filePath atomically:YES];
}

-(void)set_deadline_time:(NSInteger)minute
{
    if(self.deadline == minute)
        return;
    
    self.deadline=minute;
    
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"settingData.xml"];
    
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * setting=[doc rootElement];
    
    NSArray* arr1=[setting elementsForName:@"user"];
    [[[arr1 objectAtIndex:0] attributeForName:@"deadlineTime"] setStringValue:[NSString stringWithFormat:@"%d",self.deadline]];
    
    NSData* data=doc.XMLData;
    [data writeToFile:filePath atomically:YES];

}

-(void)backTodefault{
    NSFileManager* fff=[NSFileManager defaultManager];
    NSError * err;
    
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"settingData.xml"];
    NSString* defaultFilePath=[docPath stringByAppendingPathComponent:@"defaultSettingData.xml"];
    
    [fff removeItemAtPath:filePath error:&err];
    [fff copyItemAtPath:defaultFilePath toPath:filePath error:&err];

}

-(void)set_a_new_sentDataAutomaticly:(NSString *)SDA{
    if ([self.sentDataAutomaticly isEqualToString:SDA]) {
        return;
    }
    
    self.sentDataAutomaticly=SDA;
    
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath=[paths objectAtIndex:0];
    NSString* filePath=[docPath stringByAppendingPathComponent:@"settingData.xml"];
    
    NSData* xmlData=[[NSData alloc]initWithContentsOfFile:filePath];
    
    GDataXMLDocument *doc=[[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    GDataXMLElement * setting=[doc rootElement];
    
    NSArray* arr1=[setting elementsForName:@"user"];
    [[[arr1 objectAtIndex:0] attributeForName:@"ifSentDataAutomaticly"] setStringValue:[NSString stringWithFormat:@"%@",self.sentDataAutomaticly]];
    
    NSData* data=doc.XMLData;
    [data writeToFile:filePath atomically:YES];
}

@end
