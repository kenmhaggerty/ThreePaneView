//
//  ThreePaneViewControllerProtocol.h
//  SandboxTwo
//
//  Created by Ken M. Haggerty on 2/1/13.
//  Copyright (c) 2013 Ken M. Haggerty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreePaneChildViewProtocol.h"

@protocol ThreePaneChildViewProtocol;

@protocol ThreePaneViewControllerProtocol <NSObject>
@property (nonatomic) BOOL canViewMainView;
@property (nonatomic) BOOL canViewTopView;
@property (nonatomic) BOOL canViewSideView;
- (id)initWithMainVC:(UIViewController <ThreePaneChildViewProtocol> *)mainVC topVC:(UIViewController <ThreePaneChildViewProtocol> *)topVC sideVC:(UIViewController <ThreePaneChildViewProtocol> *)sideVC;
- (void)viewMainView;
- (void)viewTopView;
- (void)viewSideView;
- (void)popMainView;
- (void)popTopView;
- (void)popSideView;
- (void)setAsMainViewController:(UIViewController *)viewController;
- (void)setAsTopViewController:(UIViewController *)viewController;
- (void)setAsSideViewController:(UIViewController *)viewController;
@end