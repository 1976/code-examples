//
//  MITableTableViewController.m
//  Music Impacts
//
//  Created by Jason Hughes on 9/11/14.
//  Copyright (c) 2014 Music Impacts. All rights reserved.
//

#import "MITableViewController.h"

NSString * const MI_CELL_REUSE_ID = @"mi_cell";

@interface MITableViewController ()

@end


@implementation MITableViewController

@synthesize results = _results;
@synthesize tableView = _tableView;
@synthesize appendResults = _appendResults;
@synthesize refreshControl = _refreshControl;
@synthesize loadingView = _loadingView;
@synthesize footerView = _footerView;
@synthesize cells = _cells;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView = [[UITableView alloc] initWithFrame:self.contentView.frame];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollsToTop = NO;
    _tableView.alpha = 0;
    
    [self.contentView addSubview:_tableView];
    
    _cells = [@[] mutableCopy];
    
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(_footerView.center.x - 15, 50 / 2 - 15, 30, 30)];
    loader.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    [loader startAnimating];
    
    [_footerView addSubview:loader];
    
    
   /* _refreshControl = [[MIPullToRefresh alloc] initWithFrame:CGRectMake(0, -50, self.view.width, 50)];
    [_refreshControl addTarget:self action:@selector(refreshModel) forControlEvents:UIControlEventEditingDidBegin];
    [_refreshControl addTarget:self action:@selector(stopRefreshModel) forControlEvents:UIControlEventEditingDidEnd];
    
    [_tableView addSubview:_refreshControl];*/
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tableView.scrollsToTop = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tableView.scrollsToTop = NO;
    
    [self pauseAllCells];
    
}

- (void)pauseAllCells
{
    for (MITableViewCell *cell in self.cells) {
        [cell pauseCell];
    }
}

- (void)reloadTableView
{
    [_tableView reloadData];
    
}

- (void)scrollToTop:(BOOL)animated
{
    [_tableView scrollRectToVisible:CGRectMake(0, 0, self.tableView.width, self.tableView.height) animated:animated];
}

- (void)stopRefreshModel
{
    [super stopRefreshModel];
    
   // [_refreshControl hideWithScrollView:_tableView];
    
}

- (void)onStatusBarTap
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}



#pragma mark - Update Model With new Data
- (void)onActionEventDataChangedStory:(NSNotification *)note
{
    [self updateResultsWithData:note.userInfo];
}

- (void)updateResultsWithData:(NSDictionary *)data
{
    NSString *contentID;
    
    if (data[@"id"]) {
        contentID = data[@"id"];
    } else if (data[@"storyID"]) {
         contentID = data[@"storyID"];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", contentID];
    NSArray *filteredResults = [self.results filteredArrayUsingPredicate:predicate];
    
    for (NSDictionary *result in filteredResults) {
       
        NSMutableDictionary *tempResult = [NSMutableDictionary dictionaryWithDictionary:result];
        
        if (data[@"commentCount"]) {
             tempResult[@"comment_count"] = data[@"commentCount"];
        }
        
        if (data[@"current_user_liked"]) {
            tempResult[@"current_user_liked"] = data[@"current_user_liked"];
            tempResult[@"like_count"] = data[@"like_count"];
        }
        
        if ( data[@"view_count"] ) {
            tempResult[@"view_count"] = data[@"view_count"];
        }
        
        NSUInteger dataIndex = [self.results  indexOfObject:result];
        
        [self.results replaceObjectAtIndex:dataIndex withObject:tempResult];
        
        for (MITableViewCell *cell in self.cells) {
            if ([cell.data[@"id"] isEqualToNumber:tempResult[@"id"]]) {
                [cell updateContentWithData:tempResult];
            }
        }
    }
}

#pragma - LOAD API DATA WITH PARAMETERS
- (void)loadDataAPI:(NSString *)apiName withParameters:(NSDictionary *)parameters;
{
    if (self.isRefreshing) return;
    
    self.model = nil;
    
    if(!self.client){
        self.client = [[MIAPIClient alloc] init];
    }
    
    self.isLoadingNewModel = YES;
    
    [_tableView dequeueReusableCellWithIdentifier:MI_CELL_REUSE_ID];
    
    if ([[MISyncEngine sharedInstance] loggedInUser]) {
        if ([[MISyncEngine sharedInstance] loggedInUser].logged_in) {
            [self.client setToken:[[MISyncEngine sharedInstance] loggedInUser].token];
        }
    }
    
    __weak MITableViewController *weakSelf = self;
    
    [self.client GETRequestForClass:apiName parameters:parameters success:^(NSDictionary *responseObject){
        
        weakSelf.model = [NSDictionary dictionaryWithDictionary:responseObject];
        
        if ([weakSelf.model[@"next"] isEqual:[NSNull null]]) {
            weakSelf.tableView.tableFooterView = nil;
        }else{
            weakSelf.tableView.tableFooterView = _footerView;
        }
        
        weakSelf.isLoadingNewModel = NO;
        
        [weakSelf onModelLoad];
        
    }failure:^(NSError *error){
        NSLog(@"failure  %@", error);
        if (error.code == -1009) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }else if(error.code == -1200){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];

        }else if(error.code == -1001){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        }
    }];
}

#pragma - LOAD URL DATA WITH PARAMETERS
- (void)loadDataURL:(NSString *)url withParameters:(NSDictionary *)parameters
{
    self.model = nil;
    
    if(!self.client){
        self.client = [[MIAPIClient alloc] init];
    }
    
    self.isLoadingNewModel = YES;
    
    [_tableView dequeueReusableCellWithIdentifier:MI_CELL_REUSE_ID];
    
    if ([[MISyncEngine sharedInstance] loggedInUser]) {
        if ([[MISyncEngine sharedInstance] loggedInUser].logged_in) {
            [self.client setToken:[[MISyncEngine sharedInstance] loggedInUser].token];
        }
    }
    __weak MITableViewController *weakSelf = self;
    
    [self.client GETRequestForURL:url parameters:parameters success:^(NSDictionary *responseObject){
        weakSelf.model = [NSDictionary dictionaryWithDictionary:responseObject];
        if ([weakSelf.model[@"next"] isEqual:[NSNull null]]) {
            weakSelf.tableView.tableFooterView = nil;
        }else{
            weakSelf.tableView.tableFooterView = _footerView;
        }
        
        weakSelf.isLoadingNewModel = NO;
        [weakSelf onModelLoad];
        
    }failure:^(NSError *error){
        
    }];

}

- (void)onModelLoad
{
    if(self.model[@"results"]){
        _results = [NSMutableArray arrayWithArray:self.model[@"results"]];
    }else{
        _results = [NSMutableArray arrayWithObject:self.model];
    }
    
    [self reloadTableView];
    
    if (self.isRefreshing){
        self.isRefreshing = NO;
        [self.refreshControl hideWithScrollView:_tableView];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _tableView.alpha = 1;
    }];

}

#pragma - LOAD PAGINATED DATA WITH PARAMETERS
- (void)loadPaginatedData
{
    if(self.isLoadingNewModel) return;
    
    if(!self.client){
        self.client = [[MIAPIClient alloc] init];
    }
    
    if ([[MISyncEngine sharedInstance] loggedInUser]) {
        if ([[MISyncEngine sharedInstance] loggedInUser].logged_in) {
            [self.client setToken:[[MISyncEngine sharedInstance] loggedInUser].token];
        }
    }
    
    __weak MITableViewController *weakSelf = self;
    
    [self.client GETRequestForURL:self.model[@"next"] parameters:nil success:^(NSDictionary *responseObject){
        weakSelf.appendResults = NO;
        weakSelf.model = [NSDictionary dictionaryWithDictionary:responseObject];
        
        if ([weakSelf.model[@"next"] isEqual:[NSNull null]]) {
            weakSelf.tableView.tableFooterView = nil;
        }
        
        [weakSelf onPaginationResultsLoad];
        
    }failure:^(NSError *error){
        
    }];
}

- (void)onPaginationResultsLoad
{
    for (NSDictionary *result in self.model[@"results"]) {
        [_results addObject:result];
    }
    
    [self reloadTableView];
}

#pragma mark - SCROLL VIEW DELEGATE
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[_refreshControl containingScrollViewDidScroll:scrollView];
    
    if(self.isLoadingNewModel || self.results.count == 0) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.results.count - 1 inSection:0];
    
    float cellHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
    
    float bottomEdge = scrollView.contentOffset.y + (scrollView.frame.size.height + (cellHeight * 2));
   
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
        
        if( self.model ){
            if (![self.model[@"next"] isEqual:[NSNull null]]) {
                if (!_appendResults) {
                    _appendResults = YES;
                    [self loadPaginatedData];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   // [_refreshControl containingScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //[_refreshControl containingScrollViewDidBeginDecelerating:scrollView];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUInteger count = 0;
    
    if ([_results count] > 0) {
        count = [_results count];
    }
    
    return  count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MITableViewCell *cell = (MITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MI_CELL_REUSE_ID forIndexPath:indexPath];
    
    NSInteger row = [indexPath row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *cellData = [NSDictionary dictionaryWithDictionary:[_results objectAtIndex:row] ];
    
    [cell updateContentWithData:cellData];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSDictionary *cellData = [NSDictionary dictionaryWithDictionary:[_results objectAtIndex:row] ];
    
    MITableViewCell *cell = (MITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MI_CELL_REUSE_ID];
    
    [cell updateContentWithData:cellData];
    
    return cell.height;
}



@end
