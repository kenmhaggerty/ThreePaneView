//
//  ThreePaneViewController.h
//  ThreePaneView
//
//  Created by Ken M. Haggerty on 1/30/17.
//  Copyright © 2017 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // KMHPaneViewProtocol //

#pragma mark Protocol

@protocol KMHPaneViewProtocol <NSObject>
@optional
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sideViewButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *topViewButton;
@end

#pragma mark - // InitialViewController //

#pragma mark Public Interface

@interface InitialViewController : UIViewController <KMHPaneViewProtocol>
@property (nonatomic, strong) IBOutlet UIViewController *mainViewController;
@property (nonatomic, strong) IBOutlet UIViewController *sideViewController;
@property (nonatomic, strong) IBOutlet UIViewController *topViewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sideViewButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *topViewButton;
@end

#pragma mark - // KMHPaneViewController //

#pragma mark Public Interface

@interface KMHPaneViewController : UIViewController <KMHPaneViewProtocol>
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sideViewButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *topViewButton;
@end

#pragma mark - // ThreePaneViewController //

#pragma mark Forward References

@class ThreePaneViewController;

#pragma mark Protocols

@protocol ThreePaneViewDelegate <NSObject>
@optional
- (void)threePaneViewWillChangePosition:(ThreePaneViewController *)sender;
- (void)threePaneViewDidChangePosition:(ThreePaneViewController *)sender;
@end

#pragma mark Public Interface

@interface ThreePaneViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, weak) id <ThreePaneViewDelegate> delegate;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *sideView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) IBOutlet UIScrollView *horizontalScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *verticalScrollView;
//@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sideViewButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *topViewButton;
@property (nonatomic, getter=sideViewIsOpen) BOOL sideViewOpen;
@property (nonatomic, getter=topViewIsOpen) BOOL topViewOpen;
@property (nonatomic) CGFloat sideViewWidth;
@property (nonatomic) BOOL bouncesTop;
@property (nonatomic) BOOL bouncesBottom;
@property (nonatomic) BOOL bouncesOpen;
@property (nonatomic) BOOL bouncesClosed;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGSize scrollPadding;
@property (nonatomic) CGFloat overlap;

// INITS //

- (id)initWithMainView:(UIView *)mainView sideView:(UIView *)sideView topView:(UIView *)topView;

// SETTERS //

- (void)setSideViewOpen:(BOOL)sideViewOpen animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;
- (void)setTopViewOpen:(BOOL)sideViewOpen animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;
- (void)setSideViewWidth:(CGFloat)sideViewWidth animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;
- (void)setKeyboardHeight:(CGFloat)keyboardHeight animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;

// ACTIONS //

- (IBAction)toggleSideView:(id)sender;
- (IBAction)toggleTopView:(id)sender;
- (IBAction)popSideViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;
- (IBAction)popTopViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;

@end
