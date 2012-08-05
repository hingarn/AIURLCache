//
//  AIURLCache.m
//
//  Created by Alexey Ivlev on 8/2/12.
//  Copyright (c) 2012 Alexey Ivlev. All rights reserved.
//

#import "AIURLCache.h"
#import "RemoteFilesCacheStorage.h"

@interface AIURLCache()
@property (nonatomic, strong) NSArray *cacheURLAndMIMETypes;
@property (nonatomic, strong) NSDictionary *mimeTypes;
@end

@implementation AIURLCache
@synthesize mimeTypes = _mimeTypes;
@synthesize cacheURLAndMIMETypes = _cacheURLAndMIMETypes;

- (void) setMaxCacheAge: (NSUInteger) age
{
    [RemoteFilesCacheStorage sharedStorage].cacheAge = age; 
}

- (NSDictionary *) mimeTypes
{
    if (!_mimeTypes) {
        NSDictionary *types = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"application/javascript", @"js",
                               @"text/css", @"css",
                               @"image/png", @"png",
                               @"image/jpeg", @"jpeg",
                               nil];
        _mimeTypes = types; 
    }
    
    return _mimeTypes;
}

- (NSArray *) cacheURLAndMIMETypes
{
    if (!_cacheURLAndMIMETypes) {
        _cacheURLAndMIMETypes = [[NSArray alloc] init]; 
    }
    
    return _cacheURLAndMIMETypes; 
}

- (void) cacheResourcesForURL: (NSString *) urlString withMIMEType: (MIMETypes) mimeType
{
    //adds url along with mime type into array for later use
    NSNumber *mimeTypeNumber = [NSNumber numberWithInt:mimeType];
    NSDictionary *cachePath = [[NSDictionary alloc] initWithObjectsAndKeys:urlString, @"path", mimeTypeNumber, @"MIMEType", nil];
    NSMutableArray *tempPaths = [[NSMutableArray alloc] initWithArray:self.cacheURLAndMIMETypes];
    [tempPaths addObject:cachePath];
    self.cacheURLAndMIMETypes = tempPaths;
}

- (BOOL) doesMIMETypeMatchRequestedType: (NSNumber *) type inURLString: (NSString *) pathString
{
    //only cache requested mime type for specified url
    MIMETypes mime = [type intValue];
    
    switch (mime) {
        case js:
            return ([[self.mimeTypes valueForKey:@"js"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case css:
            return ([[self.mimeTypes valueForKey:@"css"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case png:
            return ([[self.mimeTypes valueForKey:@"png"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case jpeg:
            return ([[self.mimeTypes valueForKey:@"jpeg"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case allImages:
            return (([[self.mimeTypes valueForKey:@"png"] isEqualToString:[self mimeTypeForPath:pathString]]) ||
                    [[self.mimeTypes valueForKey:@"jpeg"] isEqualToString:[self mimeTypeForPath:pathString]]);
            break;
        case all:
            return YES;
            break;
    }
    
    return NO;
}

- (BOOL) shouldCacheRemoteFileForURL: (NSString *) urlString
{
    //main check for both url and mime type specified by user
    BOOL should = NO;
    for (NSDictionary *urlAndMIMEType in self.cacheURLAndMIMETypes) {
        if ([urlString rangeOfString:[urlAndMIMEType valueForKey:@"path"]].location != NSNotFound) {
           should = [self doesMIMETypeMatchRequestedType: (NSNumber *)[urlAndMIMEType valueForKey:@"MIMEType"] inURLString:urlString];
        }
    }
    
    return should;
}

- (NSString *)mimeTypeForPath:(NSString *)originalPath
{
    if ([originalPath rangeOfString:@".png"].location != NSNotFound) {
        return [self.mimeTypes valueForKey:@"png"];
    } else if ([originalPath rangeOfString:@".jpg"].location != NSNotFound || [originalPath rangeOfString:@".jpeg"].location != NSNotFound){
        return [self.mimeTypes valueForKey:@"jpeg"];
    } else if ([originalPath rangeOfString:@".css"].location != NSNotFound){
        return [self.mimeTypes valueForKey:@"css"];
    } else if ([originalPath rangeOfString:@".js"].location != NSNotFound){
        return [self.mimeTypes valueForKey:@"js"];
    }
    
    return nil;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
	NSString *pathString = [[request URL] absoluteString];
    
	if (![self shouldCacheRemoteFileForURL:pathString])
	{
        NSLog(@"not caching: %@", pathString);
        //default webview caching
		return [super cachedResponseForRequest:request];
	}

    NSData *data = [[RemoteFilesCacheStorage sharedStorage] fileForKey:pathString];
    
	if (data)
	{
        NSLog(@"retrieving %@", pathString);
        
        NSURLResponse *response =
		[[NSURLResponse alloc]
         initWithURL:[request URL]
         MIMEType:[self mimeTypeForPath:pathString]
         expectedContentLength:[data length]
         textEncodingName:nil];
        
        //delete cached response from default cache to free up memory since we already stored it on disk 
        [self removeCachedResponseForRequest:request];
		return [[NSCachedURLResponse alloc] initWithResponse:response data:data];
	} else {
        NSLog(@"caching: %@", pathString);
        //save file on disk
        [[RemoteFilesCacheStorage sharedStorage] saveFileForKeyWrapper:pathString];
        return [super cachedResponseForRequest:request];
    }
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    //put deletion on background thread, otherwise use will experience choppy scrolling 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [super removeCachedResponseForRequest:request];
    });
}

@end
