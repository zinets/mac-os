//
//  ProgressWindowController.h
//  OfflineMate
//
//  Created by Zinetz Victor on 9/16/12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProgressWindowController : NSWindowController

@property (assign) IBOutlet NSProgressIndicator *idOverallProgress;
@property (assign) IBOutlet NSProgressIndicator *idSubscriptionProgress;
@property (assign) IBOutlet NSButton *idAbort;


- (IBAction)onAbortClick:(id)sender;

@end
