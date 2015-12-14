//
//  AppDelegate.h
//  CoreDataTest1
//
//  Created by Victor Zinetz on 14.09.12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GoogleReader+TableSupport.h"
#import "GoogleReader+OutlineSupport.h"

#import "ProgressWindowController.h"

#import "WebKit/WebKit.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    GoogleReader * googleReader;
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign) IBOutlet NSTableView *idTable;
@property (assign) IBOutlet NSOutlineView *idOutline;
@property (assign) IBOutlet WebView * idWebView;

- (IBAction)saveAction:(id)sender;
- (IBAction)test1:(id)sender;
- (IBAction)deleteTest:(id)sender;
- (IBAction)testSync:(id)sender;
- (IBAction)onLoadWebview:(id)sender;

@end
