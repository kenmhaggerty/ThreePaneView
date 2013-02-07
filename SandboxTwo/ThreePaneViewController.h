//
//  ThreePaneViewController.h
//  SandboxTwo
//
//  Created by Ken M. Haggerty on 2/1/13.
//  Copyright (c) 2013 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#import "ThreePaneViewControllerProtocol.h"
#import "ThreePaneChildViewProtocol.h"
#import "ThreePaneMainViewProtocol.h"

#pragma mark - // DEFINITIONS (Public) //

@interface ThreePaneViewController : UIViewController <ThreePaneViewControllerProtocol>
@property (nonatomic, strong) UIViewController <ThreePaneMainViewProtocol> *mainViewController;
@property (nonatomic, strong) UIViewController <ThreePaneChildViewProtocol> *topViewController;
@property (nonatomic, strong) UIViewController <ThreePaneChildViewProtocol> *sideViewController;
@property (nonatomic) BOOL canViewMainView;
@property (nonatomic) BOOL canViewTopView;
@property (nonatomic) BOOL canViewSideView;
- (void)viewMainView;
- (void)viewTopView;
- (void)viewSideView;
- (void)popMainView;
- (void)popTopView;
- (void)popSideView;
- (void)setAsMainViewController:(UIViewController <ThreePaneMainViewProtocol> *)viewController;
- (void)setAsTopViewController:(UIViewController <ThreePaneChildViewProtocol> *)viewController;
- (void)setAsSideViewController:(UIViewController <ThreePaneChildViewProtocol> *)viewController;
- (void)setAsContainerViewBackground:(UIImage *)backgroundImage;
@end