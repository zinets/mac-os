//
//  GRCategoryItem.h
//  OfflineMate
//
//  Created by Zinetz Victor on 9/15/12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GRSubscriptionItem;

@interface GRCategoryItem : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *subscriptions;
@end

@interface GRCategoryItem (CoreDataGeneratedAccessors)

- (void)addSubscriptionsObject:(GRSubscriptionItem *)value;
- (void)removeSubscriptionsObject:(GRSubscriptionItem *)value;
- (void)addSubscriptions:(NSSet *)values;
- (void)removeSubscriptions:(NSSet *)values;

@end
