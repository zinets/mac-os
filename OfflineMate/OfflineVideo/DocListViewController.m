//
//  DocListViewController.m
//  OfflineMate
//
//  Created by Victor Zinetz on 10.10.12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import "DocListViewController.h"

@interface DocListViewController () {

}

@end

@implementation DocListViewController

-(id)initWithList:(NSArray *) list {
    self = [super initWithNibName:@"DocListView"
                           bundle:nil];
    if (self) {
        self.docList = list;
    }
    
    return self;
}

- (void)dealloc
{
    [_docList release];
    _delegate = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - table routines

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_docList)
        return [_docList count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"Cell"] autorelease];
    }
    NSString * fn = [_docList objectAtIndex:indexPath.row];
    cell.textLabel.text = [fn lastPathComponent];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate)
        [_delegate docItemTapped:[_docList objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
