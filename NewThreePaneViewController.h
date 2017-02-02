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

#pragma mark - // ThreePaneOffset //

#pragma mark Public Constants

typedef enum : NSUInteger {
    ThreePaneUnitPoints,
    ThreePaneUnitPercent
} ThreePaneOffsetUnit;

typedef enum : NSUInteger {
    ThreePaneDirectionIn,
    ThreePaneDirectionOut
} ThreePaneOffsetDirection;

#pragma mark Public Interface

@interface ThreePaneOffset : NSObject
@property (nonatomic) CGFloat value;
@property (nonatomic) ThreePaneOffsetUnit units;
@property (nonatomic) ThreePaneOffsetDirection direction;

// INITS //

- (id)initWithOffset:(CGFloat)offset units:(ThreePaneOffsetUnit)units direction:(ThreePaneOffsetDirection)direction NS_DESIGNATED_INITIALIZER;
- (id)init NS_UNAVAILABLE;

@end

#pragma mark - // NewThreePaneViewController //

#pragma mark Public Interface

@interface NewThreePaneViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet UIScrollView *horizontalScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *verticalScrollView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *leftButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *rightButton;
@property (nonatomic, getter=sideViewIsOpen) BOOL sideViewOpen;
@property (nonatomic, getter=topViewIsOpen) BOOL topViewOpen;
@property (nonatomic) ThreePaneOffset *horizontalOffset;
@property (nonatomic) BOOL bouncesTop;
@property (nonatomic) BOOL bouncesBottom;
@property (nonatomic) BOOL bouncesOpen;
@property (nonatomic) BOOL bouncesClosed;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGSize scrollPadding;

// SETTERS //

- (void)setSideViewOpen:(BOOL)sideViewOpen animated:(BOOL)animated;
- (void)setTopViewOpen:(BOOL)sideViewOpen animated:(BOOL)animated;
- (void)setKeyboardHeight:(CGFloat)keyboardHeight animated:(BOOL)animated;

@end
