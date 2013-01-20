//
//  AppDelegate.m
//  Demo
//
//  Created by Alexey Ivlev on 8/2/12.
//  Copyright (c) 2012 Alexey Ivlev. All rights reserved.
//

#import "AppDelegate.h"
#import "AIURLCache.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSTimeInterval assetsTimeout = 60*60*24*2;
    NSTimeInterval htmlTimeout = 60*5;
    
    AIURLCache *sharedCache = [[AIURLCache alloc] initWithMemoryCapacity:1024*1024*4 diskCapacity: 1024*1024*10 diskPath:@"urlCache"];
    [sharedCache cacheResourcesForURL:@"http://oyster.ignimgs.com/ignmedia/wikimaps" withMIMEType:allImages timeOutInterval:assetsTimeout];
    [sharedCache cacheResourcesForURL:@"http://oyster.ignimgs.com/mediawiki" withMIMEType:allImages timeOutInterval:assetsTimeout];
    [sharedCache cacheResourcesForURL:@"http://oystatic.ignimgs.com/src/ignmediamobile" withMIMEType:allImages timeOutInterval:assetsTimeout];
    [sharedCache cacheResourcesForURL:@"http://m.ign.com/wikis" withMIMEType:html timeOutInterval:htmlTimeout];
    [sharedCache cacheResourcesForURL:@"http://www.ign.com/maps" withMIMEType:html timeOutInterval:htmlTimeout];
    [sharedCache cacheResourcesForURL:@"http://oystatic.ignimgs.com" withMIMEType:css timeOutInterval:assetsTimeout];
    [sharedCache cacheResourcesForURL:@"http://oystatic.ignimgs.com" withMIMEType:js timeOutInterval:assetsTimeout];
    [NSURLCache setSharedURLCache:sharedCache];
    
    return YES;
}

@end
