//
//  MainViewController.h
//  ThreePaneView
//
//  Created by Ken M. Haggerty on 2/1/13.
//  Copyright (c) 2013 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#import "ThreePaneViewControllerProtocol.h"

#pragma mark - // DEFINITIONS (Public) //

@interface MainViewController : UIViewController
@property (nonatomic, strong) UIViewController <ThreePaneViewControllerProtocol> *threePaneViewController;

- (IBAction)viewMainView:(UIButton *)sender;
- (IBAction)popMainView:(UIButton *)sender;
- (IBAction)addMainView:(UIButton *)sender;
- (IBAction)lockMainView:(UIButton *)sender;
- (IBAction)unlockMainView:(UIButton *)sender;

- (IBAction)viewTopView:(UIButton *)sender;
- (IBAction)popTopView:(UIButton *)sender;
- (IBAction)addTopView:(UIButton *)sender;
- (IBAction)lockTopView:(UIButton *)sender;
- (IBAction)unlockTopView:(UIButton *)sender;

- (IBAction)viewSideView:(UIButton *)sender;
- (IBAction)popSideView:(UIButton *)sender;
- (IBAction)addSideView:(UIButton *)sender;
- (IBAction)lockSideView:(UIButton *)sender;
- (IBAction)unlockSideView:(UIButton *)sender;

@end