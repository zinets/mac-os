//
//  GoogleReader+OutlineSupport.m
//  OfflineMate
//
//  Created by Zinetz Victor on 9/15/12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import "GoogleReader+OutlineSupport.h"

@implementation GoogleReader (OutlineSupport)

#pragma mark - outline delegates

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (!item)
        return [fetchedCategories count];
    else {
        GRCategoryItem * ci = (GRCategoryItem *) item;
        return ci.subscriptions.count;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        return [fetchedCategories objectAtIndex:index];
    } else {
        GRCategoryItem * ci = (GRCategoryItem *) item;
        NSArray * arr = [ci.subscriptions sortedArrayUsingDescriptors:nil];
        return [arr objectAtIndex:index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (item && [item isKindOfClass:[GRCategoryItem class]]) {
        return YES;
    }
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[GRCategoryItem class]]) {
        GRCategoryItem * ci = item;
        return ci.title;
    } else if ([item isKindOfClass:[GRSubscriptionItem class]]) {
        GRSubscriptionItem * si = item;
        return si.title;
    }
}

@end
