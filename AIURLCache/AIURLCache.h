//
//  AIURLCache.h
//
//  Created by Alexey Ivlev on 8/2/12.
//  Copyright (c) 2012 Alexey Ivlev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    javascript,
    css,
    png,
    jpeg,
    all,
    allImages
} MIMETypes;

@interface AIURLCache : NSURLCache
- (void) cacheResourcesForURL: (NSString *) urlString withMIMEType: (MIMETypes) mimeType; 
@end
