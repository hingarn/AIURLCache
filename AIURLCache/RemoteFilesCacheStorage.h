//
//  RemoteFilesCacheStorage.h
//
//  Created by Alexey Ivlev on 8/2/12.
//  Copyright (c) 2012 Alexey Ivlev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoteFilesCacheStorage : NSObject
+ (RemoteFilesCacheStorage *) sharedStorage;

@property (nonatomic) NSInteger cacheAge; 
- (NSData *)fileForKey:(NSString *) key;
- (void)saveFileForKeyWrapper:(NSString *)key;
- (void)clearMemory;
- (void)clearDisk;
- (void)cleanDisk;
- (int)getSize; 
@end
