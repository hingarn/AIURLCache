//
//  RemoteFilesCacheStorage.m
//
//  Created by Alexey Ivlev on 8/2/12.
//  Copyright (c) 2012 Alexey Ivlev. All rights reserved.
//

#import "RemoteFilesCacheStorage.h"
#import <CommonCrypto/CommonDigest.h>

static NSInteger cacheMaxCacheAge = 60*60*24*14; // 2 weeks
static NSString *filePath = @"Caches";
static RemoteFilesCacheStorage *_singleton;

@interface RemoteFilesCacheStorage()
@property (nonatomic, strong) NSString *diskCachePath;
@property (nonatomic, strong) NSMutableArray *downloadedFiles;
@property (nonatomic, strong) NSOperationQueue *operationsQueue;
@property (nonatomic, strong) NSOperationQueue *downloadQueue; 
@end

@implementation RemoteFilesCacheStorage
@synthesize diskCachePath = _diskCachePath;
@synthesize downloadedFiles = _downloadedFiles;
@synthesize operationsQueue = _operationsQueue;
@synthesize downloadQueue = _downloadQueue; 

+ (RemoteFilesCacheStorage *) sharedStorage
{
    if (_singleton == nil)
    {
        _singleton = [[RemoteFilesCacheStorage alloc] init];
    }
    
    return _singleton;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.downloadedFiles = [[NSMutableArray alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filePath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.diskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        
        self.operationsQueue = [[NSOperationQueue alloc] init];
        self.downloadQueue = [[NSOperationQueue alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (NSString *)cachePathForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    NSString *endPath = [self.diskCachePath stringByAppendingPathComponent:filename];
    
    return endPath;
}

- (void)saveFileForKeyWrapper:(NSString *)key
{
    if (self.operationsQueue.operationCount < 100) {
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(saveFileForKey:)
                                                                                  object:key];
        [self.operationsQueue addOperation:operation];
    }
}

- (void)saveFileForKey:(NSString *) key
{
    NSString *cachePathKey = [self cachePathForKey:key];
    
    if (self.downloadQueue.operationCount < 100 && ![self.downloadedFiles containsObject:cachePathKey]) {
        [self.downloadedFiles addObject:cachePathKey];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:key]];
            [NSURLConnection sendAsynchronousRequest:request queue:self.downloadQueue completionHandler:^(NSURLResponse *response,
                                                                                                    NSData *data,
                                                                                                    NSError *error){
                if (data != nil) {
                    [[NSFileManager defaultManager] createFileAtPath: cachePathKey contents:data attributes:nil];
                    [self.downloadedFiles removeObject:cachePathKey];
                } 
            }];  
        });
    }
}

- (NSData *)fileForKey:(NSString *) key
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePathForKey:key]]) {
        return [NSData dataWithContentsOfFile:[self cachePathForKey:key]];
    } else {
        return nil;
    }
    
}

- (void)removeFileForKey:(NSString *)key
{
    [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
}

- (void)clearMemory
{
    [self.operationsQueue cancelAllOperations];
    [self.downloadQueue cancelAllOperations];
}

- (void)clearDisk
{
    [self clearMemory]; 
    
    NSString *endPath = self.diskCachePath;
    
    [[NSFileManager defaultManager] removeItemAtPath:endPath error:nil];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:endPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

- (void) cleanDiskWithDirectoryEnumirator:(NSDirectoryEnumerator *) enumirator atPath:(NSString *) directory
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
    for (NSString *fileName in enumirator)
    {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

- (void)cleanDisk
{
    NSDirectoryEnumerator *fileEnumerator = nil;
    fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.diskCachePath];
    [self cleanDiskWithDirectoryEnumirator:fileEnumerator atPath: self.diskCachePath];
}

- (int)getSize
{
    int size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
