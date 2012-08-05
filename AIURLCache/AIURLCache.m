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

- (NSDictionary *) mimeTypes
{
    if (!_mimeTypes) {
        NSDictionary *types = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"application/javascript", @"js",
                               @"text/css", @"css",
                               @"image/png", @"png",
                               @"image/jpeg", @"jpeg",
                               @"text/html", @"html",
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
    NSNumber *mimeTypeNumber = [NSNumber numberWithInt:mimeType];
    NSDictionary *cachePath = [[NSDictionary alloc] initWithObjectsAndKeys:urlString, @"path", mimeTypeNumber, @"MIMEType", nil];
    NSMutableArray *tempPaths = [[NSMutableArray alloc] initWithArray:self.cacheURLAndMIMETypes];
    [tempPaths addObject:cachePath];
    self.cacheURLAndMIMETypes = tempPaths;
}

- (BOOL) doesMIMETypeMatchRequestedType: (NSNumber *) type inURLString: (NSString *) pathString
{
    MIMETypes mime = [type intValue];
    
    switch (mime) {
        case javascript:
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

- (BOOL) shouldSubstituteRemoteFileForLocal: (NSString *) pathString
{
    BOOL should = NO;
    for (NSDictionary *urlAndMIMEType in self.cacheURLAndMIMETypes) {
        if ([pathString rangeOfString:[urlAndMIMEType valueForKey:@"path"]].location != NSNotFound) {
           should = [self doesMIMETypeMatchRequestedType: (NSNumber *)[urlAndMIMEType valueForKey:@"MIMEType"] inURLString:pathString];
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
    
	if (![self shouldSubstituteRemoteFileForLocal:pathString])
	{
        NSLog(@"not caching: %@", pathString);
		return [super cachedResponseForRequest:request];
	}
    
    NSData *data = [[RemoteFilesCacheStorage sharedStorage] fileForKey:pathString];
    
	if (data)
	{
        NSURLResponse *response =
		[[NSURLResponse alloc]
         initWithURL:[request URL]
         MIMEType:[self mimeTypeForPath:pathString]
         expectedContentLength:[data length]
         textEncodingName:nil];
        [self removeCachedResponseForRequest:request];
        NSLog(@"retrieving %@", pathString);
		return [[NSCachedURLResponse alloc] initWithResponse:response data:data];
	} else {
        NSLog(@"caching: %@", pathString);
        [[RemoteFilesCacheStorage sharedStorage] saveFileForKeyWrapper:pathString];
        return [super cachedResponseForRequest:request];
    }
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [super removeCachedResponseForRequest:request];
    });
}

- (void)dealloc
{
    
}

@end
