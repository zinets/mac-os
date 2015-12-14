//
//  GRSubscriptionItem.h
//  OfflineMate
//
//  Created by Zinetz Victor on 9/15/12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GRCategoryItem, GRFeedItem;

@interface GRSubscriptionItem : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * unreaded;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *feeds;
@end

@interface GRSubscriptionItem (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(GRCategoryItem *)value;
- (void)removeCategoriesObject:(GRCategoryItem *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addFeedsObject:(GRFeedItem *)value;
- (void)removeFeedsObject:(GRFeedItem *)value;
- (void)addFeeds:(NSSet *)values;
- (void)removeFeeds:(NSSet *)values;

@end
