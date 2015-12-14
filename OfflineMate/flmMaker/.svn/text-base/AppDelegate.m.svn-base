//
//  AppDelegate.m
//  flmMaker
//
//  Created by Victor Zinetz on 11.10.12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

-(void)placeText:(NSString *)text onPic:(NSString *)picName {
    NSImage * img = [[NSImage alloc] initWithContentsOfFile:picName];
    
    float ar = 1024.0 / 768; // кадр надо вписать в это отношение сторон
    float w = img.size.width;
    float h = img.size.height;
    if (w > h)
        h = w / ar;
    else
        w = h * ar;
    NSImage * res = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
    [res lockFocus];
    
    [img drawInRect:NSMakeRect(0, 0, w, h)
           fromRect:NSMakeRect(0, 0, img.size.width, img.size.height)
          operation:NSCompositeSourceOver
           fraction:1.0];
    [text drawAtPoint:NSMakePoint(0, 0) withAttributes:nil];
    
    [res unlockFocus];
    [img release];

    [res lockFocus];
    NSBitmapImageRep * rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, w, h)];
    [res unlockFocus];

    NSData * data = [rep representationUsingType:NSPNGFileType properties:nil];
    [data writeToFile:[picName stringByAppendingString:@"_re.png"] atomically:YES];
}

-(IBAction)ontestPlaceText:(id)sender {
    [self placeText:@"test text" onPic:@"/Users/zinetz/Desktop/frame.png"];
}

-(BOOL)makeFlm:(NSString *)flmName from:(NSString *)pathToFiles error:(NSError **)error {
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    [fileMgr createFileAtPath:flmName
                     contents:nil
                   attributes:nil];
    NSFileHandle * h = [NSFileHandle fileHandleForWritingAtPath:flmName];
    if (h) {
        NSArray * files = [fileMgr contentsOfDirectoryAtPath:pathToFiles
                                                       error:error];
        if (error) {
            return NO;
        } else {
            for (NSString * fn in files) {
                if ([[fn lastPathComponent] isEqualToString:@".svn"])
                    continue;
                NSData * data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", pathToFiles, fn]];
                int len = [data length];
                
                [h writeData:[NSData dataWithBytes:&len length:4]];
                [h writeData:data];
            }
        }
        [h closeFile];
        return YES;
    } else {
        NSLog(@"some error when file opening");
        return NO;
    }
}


-(IBAction)onButtonClick:(id)sender {
    [self makeFlm:@"/Users/zinetz/Documents/film2.flm"
             from:@"/Users/zinetz/Documents/projects/home projects/mac/OfflineMate/flmMaker/files"
            error:nil];
}

-(IBAction)onButtonRestoreClick:(id)sender {
    ImageDecoder * idec = [[ImageDecoder alloc] initWithFilename:@"/Users/zinetz/Documents/film2.flm"];
    self.img.image = [idec imageForIndex:0];
    [idec release];
}

@end
