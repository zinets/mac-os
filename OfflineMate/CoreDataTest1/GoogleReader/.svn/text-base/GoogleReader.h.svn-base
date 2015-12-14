//
//  GoogleReader.h
//  OfflineMate
//
//  Created by Zinetz Victor on 9/15/12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLReader.h"

#import "GRSubscriptionItem.h"
#import "GRCategoryItem.h"
#import "GRFeedItem.h"

#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2WindowController.h"
#import "GTMHTTPFetcherLogging.h"

@interface GoogleReader : NSObject {
    NSManagedObjectContext * _managedObjectContext;
    NSArray * fetchedSubscriptions;
    NSArray * fetchedCategories;
    
    GTMOAuth2Authentication *_auth;
    NSWindow * _ownerWnd;
    
#define syncPreparing       1
#define syncSubscriptions   2
#define syncProgress        3
#define syncErrorAbort      96
#define syncError           97
#define syncErrorAuth       98
#define syncDone            99
    void (^progressBlock)(int, int, int, int, NSInteger, NSError *);
    
    int freshCount;
    BOOL isCanceled;
    NSString * continuation;
}

@property (retain, nonatomic) NSManagedObjectContext * managedObjectContext;

-(id)initWithWindow:(NSWindow *)wnd;

-(void)signOut;
-(void)syncWithCompletionHandler:(void (^)(int, int, int, int, int, NSError *))handler;
-(void)cancel;

-(void)test1;
-(void)test2;

@end
