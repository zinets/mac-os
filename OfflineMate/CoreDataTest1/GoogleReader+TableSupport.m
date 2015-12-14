//
//  GoogleReader+TableSupport.m
//  OfflineMate
//
//  Created by Zinetz Victor on 9/15/12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import "GoogleReader+TableSupport.h"

@implementation GoogleReader (TableSupport)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [fetchedSubscriptions count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    GRSubscriptionItem * si = [fetchedSubscriptions objectAtIndex:row];
    
    return si.title;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    GRSubscriptionItem * si = [fetchedSubscriptions objectAtIndex:row];
    NSLog(@"cats: %d", si.categories.count);
    for (GRCategoryItem * ci in si.categories) {
        NSLog(@"   %@", ci.id);
    }
    
    return YES;
}

@end
