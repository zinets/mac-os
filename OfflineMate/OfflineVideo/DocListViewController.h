//
//  DocListViewController.h
//  OfflineMate
//
//  Created by Victor Zinetz on 10.10.12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DocSelectorDelegate

- (void)docItemTapped:(NSString*)docName;

@end

@interface DocListViewController : UITableViewController {
    
}

@property (retain, nonatomic) NSArray * docList;
@property (assign) id <DocSelectorDelegate>delegate;

-(id)initWithList:(NSArray *) list;

@end
