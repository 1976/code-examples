//
//  MITableTableViewController.h
//  Music Impacts
//
//  Created by Jason Hughes on 9/11/14.
//  Copyright (c) 2014 Music Impacts. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const MI_CELL_REUSE_ID;

@interface MITableViewController : MIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *results;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MIPullToRefresh *refreshControl;
@property (strong, nonatomic) MILoadingView *loadingView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) NSMutableArray *cells;

@property (nonatomic) BOOL appendResults;


- (void)loadPaginatedData;
- (void)reloadTableView;
- (void)onPaginationResultsLoad;

- (void)onActionEventDataChangedStory:(NSNotification *)note;

- (void)updateResultsWithData:(NSDictionary *)data;

- (void)pauseAllCells;

- (void)onStatusBarTap;


@end
