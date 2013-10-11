//
//  allViewController.m
//  GJ
//
//  Created by apple NO5 on 13-7-2.
//  Copyright (c) 2013年 apple NO5. All rights reserved.
//

#import "allViewController.h"
#import "AppDelegate.h"
#import "SoundPlayer.h"

@interface allViewController ()

@end

@implementation allViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.aboutView setAlpha:0];
    [self.closeBtn setAlpha:0];
    // Do any additional setup after loading the view from its nib.
    //app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    //[help setText:[app getHelp]];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.closeBtn setAlpha:0];
    [self.aboutView setAlpha:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeAboutView:(id)sender
{
    [SoundPlayer playButtonSound];
    [self.closeBtn setAlpha:0];
    [self.aboutView setAlpha:0];
}

- (IBAction)aboutClick:(id)sender
{
    [SoundPlayer playButtonSound];
    [self.closeBtn setAlpha:1];
    [self.aboutView setAlpha:1];
}
@end
