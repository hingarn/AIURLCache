//
//  ViewController.m
//  Demo
//
//  Created by Alexey Ivlev on 8/2/12.
//  Copyright (c) 2012 Alexey Ivlev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@end

@implementation ViewController
@synthesize webview;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://m.ign.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request]; 
}

- (void)viewDidUnload
{
    [self setWebview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
