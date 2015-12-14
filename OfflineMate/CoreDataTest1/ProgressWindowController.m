//
//  ProgressWindowController.m
//  OfflineMate
//
//  Created by Zinetz Victor on 9/16/12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import "ProgressWindowController.h"

@interface ProgressWindowController ()

@end

@implementation ProgressWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)onAbortClick:(id)sender {
    [NSApp endSheet:self.window];
}

@end
