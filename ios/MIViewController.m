//
//  MIViewController.m
//  Music Impacts Stories
//
//  Created by Jason Hughes on 11/5/14.
//  Copyright (c) 2014 Music Impacts. All rights reserved.
//

#import "MIViewController.h"

int const BASE_NAV_BAR_HEIGHT = 48;

@interface MIViewController ()

@end

@implementation MIViewController

@synthesize animator = _animator;
@synthesize userData = _userData;
@synthesize model = _model;
@synthesize client = _client;
@synthesize contentView = _contentView;
@synthesize isLoadingNewModel = _isLoadingNewModel;
@synthesize isRefreshing = _isRefreshing;
@synthesize navBar = _navBar;
@synthesize viewControllerID = _viewControllerID;


- (id)initWithModel:(NSDictionary *)data
{
    self = [super init];
    
    if (self) {
        _model = [NSDictionary dictionaryWithDictionary:data];
    }
    
    return self;
}

- (id)initWithUserData:(NSDictionary *)data
{
    self = [super init];
    
    if (self) {
        _userData = [NSDictionary dictionaryWithDictionary:data];
        
    }
    
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewControllerID = [NSString stringWithFormat:@"%i", (arc4random() % 100000000) + 1];
        
    if( self.navigationController ){
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
   
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    
    [self.view addSubview:_contentView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTabModelUpdated:) name:@"TabModelUpdated" object:nil];
}

- (void)onTabModelUpdated:(NSNotification*)note
{
    
}

- (void)popToRootView
{
    
}

- (void)reloadModel
{
    
}

- (void)onNavBarBackButtonTap:(id)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)prepareActivityViewControllerWithDataAndShow:(NSDictionary *)data
{
    ActivityViewFlagStory *flagStory = [[ActivityViewFlagStory alloc] init];
    ActivityViewOpenSafariStory *safariStory = [[ActivityViewOpenSafariStory alloc] init];
    ActivityViewCopyStory *copyStory = [[ActivityViewCopyStory alloc] init];
    
    RDActivityViewController *activityViewController = [[RDActivityViewController alloc] initWithDelegate:self maximumNumberOfItems:10 applicationActivities:@[copyStory,flagStory, safariStory]];
    
    NSArray *excludedActivities = @[UIActivityTypePostToWeibo,UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard];
    
    activityViewController.excludedActivityTypes = excludedActivities;
    activityViewController.subject = data[@"question"][@"text"];
    [activityViewController initActivityData];
    
    [self loadActivityData:data into:activityViewController];
    
    __weak RDActivityViewController *weakActivityViewController = activityViewController;
    
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed){
        weakActivityViewController.delegate = nil;
    }];
    
    [self presentModal:activityViewController animated:YES];
    
}

#pragma mark SHARING
//SET ACTIVITY TYPE DATA FOR SHARING
- (void)loadActivityData:(NSDictionary *)cellData into:(RDActivityViewController *)activityViewController
{
    int userID = [cellData[@"user"][@"id"] intValue];
    
    NSURL *url = [NSURL URLWithString:cellData[@"web_url"]];
    NSString *userName = @"My";
    NSString *artistName;
    NSString *shareString;
    
    if ( userID != [[[MISyncEngine sharedInstance] loggedInUser].id intValue] ) {
        
        userName = [NSString stringWithFormat:@"%@", cellData[@"user"][@"first_name"] ];
    
    }
    
    artistName = cellData[@"music"][@"artistName"];
    
    if ( ![[artistName substringFromIndex:artistName.length - 1] isEqualToString:@"s"] ) {
        artistName = [NSString stringWithFormat:@"%@'s", artistName];
    }
    
    
    if ([cellData[@"question"][@"category"] isEqualToString:@"album"]) {
        shareString = [NSString stringWithFormat:@"%@ %@ answer: %@ %@.", cellData[@"question"][@"text"], userName,  artistName, cellData[@"music"][@"collectionName"]];
    }else if ([cellData[@"question"][@"category"] isEqualToString:@"track"]) {
        shareString = [NSString stringWithFormat:@"%@ %@ answer: %@ %@.", cellData[@"question"][@"text"], userName, artistName, cellData[@"music"][@"trackName"]];
    }else if ([cellData[@"question"][@"category"] isEqualToString:@"artist"]){
        shareString = [NSString stringWithFormat:@"%@ %@ answer: %@.", cellData[@"question"][@"text"], userName,  cellData[@"music"][@"artistName"]];
    }
    
    for (NSString *activityType in @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypeCopyToPasteboard, UIActivityTypeMail, UIActivityTypeMessage, @"FlagStory", @"CopyStory", @"OpenSafari" ]) {
        
        if([userName isEqualToString:@"Me"]) {
            userName = @"My";
        }

        NSMutableDictionary *data = activityViewController.activityData[activityType];
        
        if([activityType isEqualToString:UIActivityTypePostToFacebook]){
            if ( userID != [[[MISyncEngine sharedInstance] loggedInUser].id intValue] ) {
                // userName = [NSString stringWithFormat:@"%@'s", cellData[@"user"][@"first_name"] ];
            }
            
            if ([userName isEqualToString:@"My"]) userName = @"Me";
            
            shareString = [NSString stringWithFormat:@"%@ Music Impacts %@. What Music Impacts You?", artistName, userName];
            
            
        }else if([activityType isEqualToString:UIActivityTypePostToTwitter]){
            if ([userName isEqualToString:@"My"]) userName = @"Me";
            
            shareString = [NSString stringWithFormat:@"%@ Music Impacts %@. What Music Impacts You?", artistName, userName];
            
        }else if([activityType isEqualToString:UIActivityTypeMail]){
            shareString = [NSString stringWithFormat:@"<html><body><p>%@</p><p>Why? <a href='%@'>%@</a></p><p>%@",shareString, url, url, @"<a href='http://musicimpacts.me'>Download Music Impacts Stories</a></p></body></html>"];
        }else if([activityType isEqualToString:UIActivityTypeMessage]){
            data[@"message"]  = @"\r\nWhat Music Impacts You? Download the Music Impacts Stories app: http://musicimpacts.me";
            if(![userName isEqualToString:@"My"]){
                if ( ![[userName substringFromIndex:userName.length - 1] isEqualToString:@"s"] ) {
                    userName = [NSString stringWithFormat:@"%@'s", userName];
                }
            }
           // }
         
            shareString = [NSString stringWithFormat:@"%@ %@ answer: ", cellData[@"question"][@"text"], userName];
        } else if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]){
            
        }
        
        data[@"shareString"] = shareString;
        data[@"url"] = url;
        data[@"storyID"] = cellData[@"id"];
    }
}

- (NSArray *)activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType
{
    RDActivityViewController *vc = (RDActivityViewController *)activityViewController;
    NSMutableDictionary *data = vc.activityData[activityType];
    
    if(!data){
        data = vc.activityData[@"CopyURL"];
    }
    
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return @[data[@"shareString"], data[@"url"]];
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return @[data[@"shareString"], data[@"url"], @"via @Musicimpacts"];
    } else if([activityType isEqualToString:UIActivityTypeMail]){
        return @[data[@"shareString"]];
    } else if( [activityType isEqualToString:UIActivityTypeMessage] ){
        return @[data[@"shareString"], data[@"url"], data[@"message"]];
    } else if([activityType isEqualToString:UIActivityTypeMail]){
        return @[data[@"shareString"], data[@"url"]];
    } else if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]){
        return @[data[@"url"]];
    } else if ([activityType isEqualToString:@"FlagStory"]){
        [self flagContent:data[@"storyID"]];
        return nil;
    } else if ([activityType isEqualToString:@"CopyStory"]){
        return @[[data[@"url"] absoluteString]];
    } else if ([activityType isEqualToString:@"OpenSafari"]){
        return @[data[@"url"]];
    } else {
        return @[data[@"shareString"]];
    }
}

- (void)flagContent:(NSString *)contentID
{
    
}


- (void)loadOnUserData
{

}

- (void)scrollToTop:(BOOL)animated
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_client) {
        [_client cancelAllOperation];
        _client = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshModel
{
    _isRefreshing = YES;
}

- (void)stopLoadingModel
{
    _isLoadingNewModel = NO;
    
    if (_client) {
        [_client cancelAllOperation];
    }
}

- (void)stopRefreshModel
{
    _isRefreshing = NO;
    
    [self stopLoadingModel];
  
}

-(void)presentModal:(UIViewController *)viewController animated:(BOOL)animated
{
    [self presentViewController:viewController animated:animated completion:nil];
}

- (void)performActionWithDeepLink:(DPLDeepLink *)link pageID:(NSString *)pageID {
    
}

#pragma - LOAD API DATA WITH PARAMETERS
- (void)loadDataAPI:(NSString *)apiName withParameters:(NSDictionary *)parameters;
{
    if (_isRefreshing) return;

    _model = nil;
    
    if(!_client){
        _client = [[MIAPIClient alloc] init];
    }
 
     _isLoadingNewModel = YES;
    
    if ([[MISyncEngine sharedInstance] loggedInUser]) {
        if ([[MISyncEngine sharedInstance] loggedInUser].logged_in) {
            [_client setToken:[[MISyncEngine sharedInstance] loggedInUser].token];
        }
    }
   
    __weak MIViewController *weakSelf = self;
    
    [_client GETRequestForClass:apiName parameters:parameters success:^(NSDictionary *responseObject){
        
        weakSelf.model = [NSDictionary dictionaryWithDictionary:responseObject];
        
        weakSelf.isLoadingNewModel = NO;
        
        [weakSelf onModelLoad];
    
    }failure:^(NSError *error){
        if (error.code == -1009) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

#pragma - LOAD URL DATA WITH PARAMETERS
- (void)loadDataURL:(NSString *)url withParameters:(NSDictionary *)parameters
{
    _model = nil;
    
    if(!_client){
        _client = [[MIAPIClient alloc] init];
    }
    
    _isLoadingNewModel = YES;
    
    if ([[MISyncEngine sharedInstance] loggedInUser]) {
        if ([[MISyncEngine sharedInstance] loggedInUser].logged_in) {
            [_client setToken:[[MISyncEngine sharedInstance] loggedInUser].token];
        }
    }
    
    __weak MIViewController *weakSelf = self;
    
    [_client GETRequestForURL:url parameters:parameters success:^(NSDictionary *responseObject){
        weakSelf.model = [NSDictionary dictionaryWithDictionary:responseObject];
    
        weakSelf.isLoadingNewModel = NO;
        
        [weakSelf onModelLoad];
        
    }failure:^(NSError *error){
        
    }];
}

- (void)onModelLoad
{
    if (_isRefreshing){
        _isRefreshing = NO;
    }
}

-(void)showStatusBarMessage:(NSString *)message hideAfter:(NSTimeInterval)delay {
    __block UIWindow *statusWindow = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    statusWindow.windowLevel = UIWindowLevelStatusBar + 1;
    UILabel *label = [[UILabel alloc] initWithFrame:statusWindow.frame];
    label.y = -2;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont ProximaSemiBoldWithSize:13];
    label.textColor = [UIColor whiteColor];
    label.text = message;
    [statusWindow addSubview:label];
    [statusWindow makeKeyAndVisible];
    label.layer.transform = CATransform3DMakeRotation(M_PI * 0.5, 1, 0, 0);
    [UIView animateWithDuration:0.7 animations:^{
        label.layer.transform = CATransform3DIdentity;
    }completion:^(BOOL finished){
        double delayInSeconds = delay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.5 animations:^{
                label.layer.transform = CATransform3DMakeRotation(M_PI * 0.5, -1, 0, 0);
            }completion:^(BOOL finished){
                statusWindow = nil;
                [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
            }];
        });
    }];
}


@end
