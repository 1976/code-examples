//
//  MIViewController.h
//  Music Impacts Stories
//
//  Created by Jason Hughes on 11/5/14.
//  Copyright (c) 2014 Music Impacts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIPullToRefresh.h"
#import "MILoadingView.h"
#import "LoginViewController.h"
#import "DPLDeepLink.h"
#import "ActivityViewFlagStory.h"
#import "ActivityViewCopyStory.h"
#import "ActivityViewOpenSafariStory.h"
#import "RDActivityViewController.h"
#import "MINavigationBar.h"

extern int const BASE_NAV_BAR_HEIGHT;

@interface MIViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSObject *animator;

@property (strong, nonatomic) MINavigationBar *navBar;
@property (strong, nonatomic) UIView *contentView;

@property (strong, nonatomic) NSDictionary *model;
@property (strong, nonatomic) NSDictionary *userData;

@property (strong, nonatomic) MIAPIClient *client;

@property (nonatomic) BOOL isLoadingNewModel;
@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) NSString *viewControllerID;


- (id)initWithModel:(NSDictionary *)data;
- (id)initWithUserData:(NSDictionary *)data;

- (void)onNavBarBackButtonTap:(id)sender;

- (void)loadOnUserData;

- (void)reloadModel;

- (void)refreshModel;
- (void)stopRefreshModel;
- (void)stopLoadingModel;

- (void)prepareActivityViewControllerWithDataAndShow:(NSDictionary *)data;

- (void)flagContent:(NSString *)contentID;

- (void)popToRootView;

- (void)loadDataAPI:(NSString *)apiName withParameters:(NSDictionary *)parameters;
- (void)loadDataURL:(NSString *)url withParameters:(NSDictionary *)parameters;

- (void)performActionWithDeepLink:(DPLDeepLink *)link pageID:(NSString *)pageID;

-(void)presentModal:(UIViewController *)viewController animated:(BOOL)animated;

- (void)onModelLoad;

-(void)showStatusBarMessage:(NSString *)message hideAfter:(NSTimeInterval)delay;

- (void)scrollToTop:(BOOL)animated;

- (void)onTabModelUpdated:(NSNotification*)note;


@end
