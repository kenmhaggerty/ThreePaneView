//
//  ThreePaneViewController.h
//  SandboxTwo
//
//  Created by Ken M. Haggerty on 2/1/13.
//  Copyright (c) 2013 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Public) //

//  This UIViewController creates a three-pane sliding UI,
//  wherein a sideView is hidden behind a double-height
//  containerView (private) that contains a mainView and
//  a topView. The mainView is the primary view. The
//  topView is a secondary view that can be viewed by
//  sliding the containerView down. The sideView is a
//  tertiary view that can be viewed by sliding the
//  containerView to the right. The containerView contains
//  two CustomButtons that can be tapped to animated the
//  containerView to reveal the topView or sideView.

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>
#import "CustomButton.h"

#pragma mark - // PROTOCOLS //

#import "ThreePaneViewControllerProtocol.h"
#import "ThreePaneChildViewProtocol.h"

#pragma mark - // DEFINITIONS (Public) //

@interface ThreePaneViewController : UIViewController <ThreePaneViewControllerProtocol, CustomButtonDelegate>
@property (nonatomic, strong) UIViewController <ThreePaneChildViewProtocol> *mainViewController;
@property (nonatomic, strong) UIViewController <ThreePaneChildViewProtocol> *topViewController;
@property (nonatomic, strong) UIViewController <ThreePaneChildViewProtocol> *sideViewController;
@property (nonatomic, strong) IBOutlet CustomButton *buttonTopView;
@property (nonatomic, strong) IBOutlet CustomButton *buttonSideView;
@property (nonatomic) BOOL canViewMainView;
@property (nonatomic) BOOL canViewTopView;
@property (nonatomic) BOOL canViewSideView;
- (void)viewMainView;
- (void)viewTopView;
- (void)viewSideView;
- (void)popMainView;
- (void)popTopView;
- (void)popSideView;
- (void)setAsMainViewController:(UIViewController <ThreePaneChildViewProtocol> *)viewController;
- (void)setAsTopViewController:(UIViewController <ThreePaneChildViewProtocol> *)viewController;
- (void)setAsSideViewController:(UIViewController <ThreePaneChildViewProtocol> *)viewController;
- (void)setAsContainerViewBackground:(UIImage *)backgroundImage;
@end