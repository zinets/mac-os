//
//  ImgDecoder.h
//  OfflineMate
//
//  Created by Victor Zinetz on 11.10.12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageDecoder : NSObject {
    NSFileHandle * fileHandle;
    NSMutableArray * frameIndex;
}

- (id)initWithFilename:(NSString *)fileName;

- (NSInteger)count;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
- (UIImage *)imageForIndex:(NSInteger)index;
#else
- (NSImage *)imageForIndex:(NSInteger)index;
#endif

@end
