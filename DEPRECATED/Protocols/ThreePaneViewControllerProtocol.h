//
//  ThreePaneViewControllerProtocol.h
//  ThreePaneView
//
//  Created by Ken M. Haggerty on 2/1/13.
//  Copyright (c) 2013-2017 Ken M. Haggerty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreePaneChildViewProtocol.h"

@protocol ThreePaneChildViewProtocol;

@protocol ThreePaneViewControllerProtocol <NSObject>
@property (nonatomic, strong) UIView *view;
@property (nonatomic) BOOL canViewMainView;
@property (nonatomic) BOOL canViewTopView;
@property (nonatomic) BOOL canViewSideView;
- (id)initWithMainVC:(UIViewController <ThreePaneChildViewProtocol> *)mainVC topVC:(UIViewController <ThreePaneChildViewProtocol> *)topVC sideVC:(UIViewController <ThreePaneChildViewProtocol> *)sideVC;
- (BOOL)isViewingMainView;
- (BOOL)isViewingTopView;
- (BOOL)isViewingSideView;
- (void)viewMainView:(BOOL)animated;
- (void)viewTopView:(BOOL)animated;
- (void)viewSideView:(BOOL)animated;
- (void)popMainView:(BOOL)animated;
- (void)popTopView:(BOOL)animated;
- (void)popSideView:(BOOL)animated;
- (void)setAsMainViewController:(UIViewController *)viewController;
- (void)setAsTopViewController:(UIViewController *)viewController;
- (void)setAsSideViewController:(UIViewController *)viewController;
- (void)mainViewIsBeingDragged:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)topViewIsBeingDragged:(UIPanGestureRecognizer *)gestureRecognizer;
@end
