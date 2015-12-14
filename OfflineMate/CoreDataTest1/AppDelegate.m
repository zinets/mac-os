//
//  AppDelegate.m
//  CoreDataTest1
//
//  Created by Victor Zinetz on 14.09.12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [_persistentStoreCoordinator release];
    [_managedObjectModel release];
    [_managedObjectContext release];
    [super dealloc];
}

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    googleReader = [[GoogleReader alloc] initWithWindow:_window];
    googleReader.managedObjectContext = self.managedObjectContext;
   
//    [_idTable setDelegate:googleReader];
//    [_idTable setDataSource:googleReader];
    
    [_idOutline setDelegate:googleReader];
    [_idOutline setDataSource:googleReader];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "info.hamster.CoreDataTest1" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"info.hamster.CoreDataTest1"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataTest1" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![[properties objectForKey:NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"CoreDataTest1.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] autorelease];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = [coordinator retain];
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)test1:(id)sender {
    [googleReader test1];
    [_idTable reloadData];
}

- (IBAction)deleteTest:(id)sender {
    NSString * d = @"2012-09-19T12:18:43Z";
//    NSDateFormatter * fmt = [[NSDateFormatter alloc] init];
//    [fmt setDateStyle:NSDateFormatterMediumStyle];
//    [fmt setTimeStyle:NSDateFormatterNoStyle];
//    [fmt setDateFormat:@"dd-MM-yyyy hh:mm:ss a"];
//    
//    NSDate * date = [fmt dateFromString:d];
//    NSLog(@"%@", date);
//    
//    [fmt release];
    NSString * dateString = @"2012-09-19T12:18:43Z";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss'Z'"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSLog(@"%@", dateFromString);
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSLog(@"%@", [dateFormatter stringFromDate:dateFromString]);
    [dateFormatter release];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    NSLog(@"did end");
    [sheet orderOut:self];
}

- (IBAction)testSync:(id)sender {
    ProgressWindowController * progress = [[ProgressWindowController alloc]
                                           initWithWindowNibName:@"ProgressWindowController"];

    [progress showWindow:self];
//    [NSApp beginSheet:progress.window
//       modalForWindow:_window
//        modalDelegate:self
//       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
//          contextInfo:nil];
//    [googleReader signOut];

    [googleReader syncWithCompletionHandler:^(int overall, int overallMax, int cur, int curMax, int phase, NSError * err) {
        
        switch (phase) {
            case syncErrorAuth: case syncError:
                [NSApp endSheet:progress.window];
                NSAlert * alert = [NSAlert alertWithError:err];
                [alert runModal];
                
                break;
            case syncPreparing:
                [progress.idOverallProgress setIndeterminate:YES];
                [progress.idOverallProgress startAnimation:nil];
                [progress.idSubscriptionProgress setIndeterminate:YES];
                [progress.idSubscriptionProgress startAnimation:nil];
                
                break;
            case syncSubscriptions:
                [progress.idOverallProgress setIndeterminate:NO];
                [progress.idOverallProgress stopAnimation:nil];
                [progress.idSubscriptionProgress setIndeterminate:NO];
                [progress.idSubscriptionProgress stopAnimation:nil];
                
                [progress.idOverallProgress setMaxValue:overallMax];
                [progress.idSubscriptionProgress setMaxValue:curMax];
                
                [_idOutline reloadData];
                
                break;
            case syncDone:
                [NSApp endSheet:progress.window];
                
                break;
            default:
                
                [progress.idOverallProgress setDoubleValue:overall];
                
                [progress.idSubscriptionProgress setDoubleValue:cur];
                break;
        }
        [progress.idOverallProgress setNeedsDisplay:YES];
        [progress.idSubscriptionProgress setNeedsDisplay:YES];
    }];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    NSLog(@"%@", message);
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSArray * arr = [NSArray arrayWithObjects:nil];
//    [[_idWebView windowScriptObject] callWebScriptMethod:@"initReading" withArguments:arr];
    
}

- (IBAction)onLoadWebview:(id)sender {
    
    [_idWebView setUIDelegate:self];
    [_idWebView setFrameLoadDelegate:self];
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"test"
                                                             ofType:@"html"];
    [[_idWebView mainFrame] loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL fileURLWithPath:templatePath]]];
    
}

@end
