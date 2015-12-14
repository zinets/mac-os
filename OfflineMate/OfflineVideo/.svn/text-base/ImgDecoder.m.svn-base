//
//  ImgDecoder.m
//  OfflineMate
//
//  Created by Victor Zinetz on 11.10.12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import "ImgDecoder.h"

@implementation ImageDecoder

- (void)dealloc {
    [frameIndex release];
    if (fileHandle)
        [fileHandle closeFile];
    [fileHandle release];
    [super dealloc];
}

- (id)initWithFilename:(NSString *)fileName {
    self = [super init];
    if (self) {
        NSDictionary * dict = [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil];
        NSNumber * n = [dict objectForKey:NSFileSize];
        long long fileSize = [n longLongValue];
        
        FILE * file = fopen([fileName cStringUsingEncoding:NSUTF8StringEncoding], "r");
        if (file) {
            frameIndex = [[NSMutableArray array] retain];
            int len;
            long p = 0;
            
            while (p < fileSize) {
                [frameIndex addObject:[NSNumber numberWithLong:p]];
                fread(&len, 4, 1, file);
                fseek(file, len, SEEK_CUR);
                p = ftell(file);
            };
            
            fclose(file);
        } else {
            [self release];
            return nil;
        }
        
        fileHandle = [[NSFileHandle fileHandleForReadingAtPath:fileName] retain];
        if (fileHandle) {
            
        } else {
            [self release];
            return nil;
        }
    }
    return self;
}

#pragma mark -

- (NSInteger)count {
    if (frameIndex)
        return [frameIndex count];
    else
        return 0;
}

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
- (UIImage *)imageForIndex:(NSInteger)index {
    if (index < 0) index = 0; else
        if (index >= [frameIndex count]) index = [frameIndex count] - 1;
    
    NSData * data = nil;
    NSNumber * offset = [frameIndex objectAtIndex:index];
    [fileHandle seekToFileOffset:[offset intValue]];
    
    data = [fileHandle readDataOfLength:4];
    NSUInteger len = *(NSUInteger *)([data bytes]);
    
    return [[[UIImage alloc] initWithData:[fileHandle readDataOfLength:len]] autorelease];
}
#else
- (NSImage *)imageForIndex:(NSInteger)index {
    if (index < 0) index = 0; else
        if (index >= [frameIndex count]) index = [frameIndex count] - 1;
    
    NSData * data = nil;
    NSNumber * offset = [frameIndex objectAtIndex:index];
    [fileHandle seekToFileOffset:[offset intValue]];
    
    data = [fileHandle readDataOfLength:4];
    NSUInteger len = *(NSUInteger *)([data bytes]);
    
    return [[[NSImage alloc] initWithData:[fileHandle readDataOfLength:len]] autorelease];
}
#endif

@end