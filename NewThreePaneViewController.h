//
//  NewThreePaneViewController.h
//  ThreePaneView
//
//  Created by Ken M. Haggerty on 1/30/17.
//  Copyright © 2017 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // NewThreePaneViewController //

#pragma mark Forward References

@class NewThreePaneViewController;

#pragma mark Protocols

@protocol ThreePaneViewDelegate <NSObject>
@optional
- (void)threePaneViewWillChangePosition:(NewThreePaneViewController *)sender;
- (void)threePaneViewDidChangePosition:(NewThreePaneViewController *)sender;
@end

#pragma mark Public Interface

@interface NewThreePaneViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, weak) id <ThreePaneViewDelegate> delegate;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *sideView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) IBOutlet UIScrollView *horizontalScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *verticalScrollView;
@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *leftButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *rightButton;
@property (nonatomic, getter=sideViewIsOpen) BOOL sideViewOpen;
@property (nonatomic, getter=topViewIsOpen) BOOL topViewOpen;
@property (nonatomic) CGFloat sideViewWidth;
@property (nonatomic) BOOL bouncesTop;
@property (nonatomic) BOOL bouncesBottom;
@property (nonatomic) BOOL bouncesOpen;
@property (nonatomic) BOOL bouncesClosed;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGSize scrollPadding;

// INITS //

- (id)initWithMainView:(UIView *)mainView sideView:(UIView *)sideView topView:(UIView *)topView;

// SETTERS //

- (void)setSideViewOpen:(BOOL)sideViewOpen animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;
- (void)setTopViewOpen:(BOOL)sideViewOpen animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;
- (void)setKeyboardHeight:(CGFloat)keyboardHeight animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;

// ACTIONS //

- (IBAction)popSideViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;
- (IBAction)popTopViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;

@end
