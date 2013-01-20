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
    NSString *mapURLString = @"http://widgets.ign.com/tools/maps/interactivemap/the-elder-scrolls-5-skyrim/skyrim.html?title=false&fullscreen=false&slidingview=true&search=false&filters=false&editable=false&moderator=false&filter=false&externalLink=false&width=100%%&height=100%%&unloadInvisibleTiles=true&retina=false&disableClusteringAtZoom=4&clusterRadius=100";
    NSString *encodedString = [mapURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
