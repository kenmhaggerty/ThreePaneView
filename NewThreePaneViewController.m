//
//  NewThreePaneViewController.m
//  ThreePaneView
//
//  Created by Ken M. Haggerty on 1/30/17.
//  Copyright © 2017 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "NewThreePaneViewController.h"

#pragma mark - // UIView (Custom) //

@interface UIView (Custom)
@property (nonatomic, weak, readonly) UIView *firstResponder;
- (void)iterateOverSubviews:(BOOL (^)(UIView *))block;
- (BOOL)eventuallyContainsSubview:(UIView *)view;
- (void)addConstraintsToCenterView:(UIView *)view;
- (void)addConstraintsToScaleView:(UIView *)view withScale:(CGFloat)scale;
- (void)fillWithView:(UIView *)view;
@end

#pragma mark Implementation

@implementation UIView (Custom)

#pragma mark // Setters and Getters (Subview) //

- (UIView *)firstResponder {
    __block UIView *firstResponder;
    [self iterateOverSubviews:^BOOL(UIView *subview) {
        firstResponder = subview.isFirstResponder ? subview : nil;
        return (firstResponder == nil);
    }];
    
    return firstResponder;
}

#pragma mark // Category Methods (Subview) //

- (void)iterateOverSubviews:(BOOL (^)(UIView *))block {
    NSMutableOrderedSet *subviews = [[NSMutableOrderedSet alloc] initWithArray:self.subviews];
    UIView *subview;
    BOOL iterate = YES;
    while (subviews.count && iterate) {
        subview = subviews.firstObject;
        iterate = block(subview);
        if (subview.subviews.count) {
            [subviews addObjectsFromArray:subview.subviews];
        }
        [subviews removeObject:subview];
    }
}

- (BOOL)eventuallyContainsSubview:(UIView *)view {
    if (!view) {
        return NO;
    }
    
    __block BOOL containsSubview;
    [self iterateOverSubviews:^BOOL(UIView *subview) {
        containsSubview = [view isEqual:subview];
        return !containsSubview;
    }];
    return containsSubview;
}

- (void)addConstraintsToCenterView:(UIView *)view {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
}

- (void)addConstraintsToScaleView:(UIView *)view withScale:(CGFloat)scale {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:scale constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:scale constant:0.0f]];
}

- (void)fillWithView:(UIView *)view {
    if (!view) {
        return;
    }
    
    [self addSubview:view];
    [self addConstraintsToCenterView:view];
    [self addConstraintsToScaleView:view withScale:1.0f];
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

@end

#pragma mark - // PassThroughScrollView //

#pragma mark Public Interface

@interface PassThroughScrollView : UIScrollView
@end

#pragma mark Implementation

@implementation PassThroughScrollView

#pragma mark // Overwritten Methods //

// via StackOverflow:
// http://stackoverflow.com/questions/3834301/ios-forward-all-touches-through-a-view
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

#pragma mark - // NewThreePaneViewController //

#pragma mark Private Constants

NSTimeInterval const ThreePaneAnimationDurationFast = 0.18f;
NSTimeInterval const ThreePaneAnimationDurationSlow = 0.25f;

#pragma mark Private Interface

@interface NewThreePaneViewController () <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UIView *mainViewContainer;
@property (nonatomic, strong) IBOutlet UIView *sideViewContainer;
@property (nonatomic, strong) IBOutlet UIView *topViewContainer;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraintSideViewWidth;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraintKeyboardHeight;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) BOOL viewHasLoaded;

// SETUP //

- (void)setup;
- (void)teardown;

// IBACTIONS //

- (IBAction)touchUpInside:(id)sender;

// GESTURES //

- (void)scrollViewDidPan:(UIPanGestureRecognizer *)gestureRecognizer;

// OBSERVERS //

- (void)addObserversToKeyboard;
- (void)removeObserversFromKeyboard;

// RESPONDERS //

- (void)keyboardFrameWillChange:(NSNotification *)notification;
- (void)keyboardWillDisappear:(NSNotification *)notification;

// OTHER //

- (void)setSideViewOpen:(BOOL)sideViewOpen withAnimationDuration:(NSTimeInterval)animationDuration completion:(void (^)(BOOL))completionBlock;
- (void)setTopViewOpen:(BOOL)topViewOpen withAnimationDuration:(NSTimeInterval)animationDuration completion:(void (^)(BOOL))completionBlock;
- (BOOL)directionForVelocity:(CGFloat)velocity withMinimum:(CGFloat)minimum andPosition:(CGFloat)position;

@end

#pragma mark Implementation

@implementation NewThreePaneViewController

#pragma mark // Setters and Getters (Public) //

- (void)setMainView:(UIView *)mainView {
    if ((!mainView && !self.mainView) || [mainView isEqual:self.mainView]) {
        return;
    }
    
    [self.mainView removeFromSuperview];
    
    _mainView = mainView;
    
    [self.mainViewContainer fillWithView:mainView];
}

- (void)setSideView:(UIView *)sideView {
    if ((!sideView && !self.sideView) || [sideView isEqual:self.sideView]) {
        return;
    }
    
    [self.sideView removeFromSuperview];
    
    _sideView = sideView;
    
    [self.sideViewContainer fillWithView:sideView];
}

- (void)setTopView:(UIView *)topView {
    if ((!topView && !self.topView) || [topView isEqual:self.topView]) {
        return;
    }
    
    [self.topView removeFromSuperview];
    
    _topView = topView;
    
    [self.topViewContainer fillWithView:topView];
}

- (void)setSideViewOpen:(BOOL)sideViewOpen {
    [self setSideViewOpen:sideViewOpen animated:NO completion:nil];
}

- (void)setTopViewOpen:(BOOL)topViewOpen {
    [self setTopViewOpen:topViewOpen animated:NO completion:nil];
}

- (void)setSideViewWidth:(CGFloat)sideViewWidth {
    [self setSideViewWidth:sideViewWidth animated:NO];
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight {
    [self setKeyboardHeight:keyboardHeight animated:NO completion:nil];
}

- (CGFloat)keyboardHeight {
    return self.constraintKeyboardHeight.constant;
}

#pragma mark // Inits and Loads //

- (void)dealloc {
    [self teardown];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithMainView:(UIView *)mainView sideView:(UIView *)sideView topView:(UIView *)topView {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setup];
        
        self.mainView = mainView;
        self.sideView = sideView;
        self.topView = topView;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.horizontalScrollView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidPan:)]];
    [self.verticalScrollView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidPan:)]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat topInset = CGRectGetMinY(self.sideViewContainer.frame);
    CGFloat bottomInset = CGRectGetHeight(self.sideViewContainer.superview.frame)-CGRectGetMaxY(self.sideViewContainer.frame);
    
    self.verticalScrollView.contentInset = UIEdgeInsetsMake(topInset, 0.0f, bottomInset, 0.0f);
    self.verticalScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0.0f, bottomInset, 0.0f);
    [self.verticalScrollView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:(self.viewHasLoaded ? 0.18f : 0.0f) animations:^{
        [self.verticalScrollView layoutIfNeeded];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.viewHasLoaded) {
        return;
    }
    
    CGFloat topInset = CGRectGetMinY(self.sideViewContainer.frame);
    CGFloat bottomInset = CGRectGetHeight(self.sideViewContainer.superview.frame)-CGRectGetMaxY(self.sideViewContainer.frame);
    
    self.verticalScrollView.contentInset = UIEdgeInsetsMake(topInset, 0.0f, bottomInset, 0.0f);
    self.verticalScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0.0f, bottomInset, 0.0f);
    self.topViewOpen = NO;
    
    self.sideViewOpen = NO;
    
    self.viewHasLoaded = YES;
}

#pragma mark // Public Methods (Setters) //

- (void)setSideViewOpen:(BOOL)sideViewOpen animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock {
    [self setSideViewOpen:sideViewOpen withAnimationDuration:(animated ? ThreePaneAnimationDurationSlow : 0.0f) completion:completionBlock];
}

- (void)setTopViewOpen:(BOOL)topViewOpen animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock {
    [self setTopViewOpen:topViewOpen withAnimationDuration:(animated ? ThreePaneAnimationDurationSlow : 0.0f) completion:completionBlock];
}

- (void)setSideViewWidth:(CGFloat)sideViewWidth animated:(BOOL)animated {
    if (sideViewWidth == self.sideViewWidth) {
        return;
    }
    
    _sideViewWidth = sideViewWidth;
    
    self.constraintSideViewWidth.constant = sideViewWidth;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:(animated ? ThreePaneAnimationDurationSlow : 0.0f) animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock {
    self.constraintKeyboardHeight.constant = keyboardHeight;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:self.animationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:completionBlock];
}

#pragma mark // Public Methods (Actions) //

- (IBAction)popSideViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completionBlock {
    [self setSideViewOpen:NO animated:animated completion:^(BOOL finished) {
        _sideView = nil;
    }];
}

- (IBAction)popTopViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completionBlock {
    [self setTopViewOpen:NO animated:animated completion:^(BOOL finished) {
        _topView = nil;
    }];
}

#pragma mark // Delegated Methods (UIScrollViewDelegate) //

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.viewHasLoaded) {
        return;
    }
    
    if ([scrollView isEqual:self.horizontalScrollView]) {
        if (!self.bouncesOpen) {
            [self.horizontalScrollView setContentOffset:CGPointMake(fmaxf(self.horizontalScrollView.contentOffset.x, -1.0f*self.horizontalScrollView.contentInset.left), self.horizontalScrollView.contentOffset.y)];
        }
        if (!self.bouncesClosed) {
            [self.horizontalScrollView setContentOffset:CGPointMake(fminf(self.horizontalScrollView.contentOffset.x, CGRectGetMinX(self.verticalScrollView.frame)-self.horizontalScrollView.contentInset.left), self.horizontalScrollView.contentOffset.y)];
        }
    }
    if ([scrollView isEqual:self.verticalScrollView]) {
        if (!self.bouncesTop) {
            [self.verticalScrollView setContentOffset:CGPointMake(self.verticalScrollView.contentOffset.x, fmaxf(self.verticalScrollView.contentOffset.y, -1.0f*self.verticalScrollView.contentInset.top))];
        }
        if (!self.bouncesBottom) {
            [self.verticalScrollView setContentOffset:CGPointMake(self.verticalScrollView.contentOffset.x, fminf(self.verticalScrollView.contentOffset.y, CGRectGetMinY(self.navigationBar.frame)-self.verticalScrollView.contentInset.top))];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([scrollView isEqual:self.horizontalScrollView] && self.horizontalScrollView.isScrollEnabled) {
        BOOL sideViewOpen = [self directionForVelocity:velocity.x withMinimum:40.0f andPosition:targetContentOffset->x/(self.horizontalScrollView.contentSize.width-CGRectGetWidth(self.horizontalScrollView.frame))];
        CGFloat offset = sideViewOpen ? 0.0f-self.horizontalScrollView.contentInset.left : CGRectGetMinX(self.verticalScrollView.frame);
        *targetContentOffset = CGPointMake(offset, targetContentOffset->y);
        [self setSideViewOpen:sideViewOpen withAnimationDuration:ThreePaneAnimationDurationFast completion:nil];
    }
    if ([scrollView isEqual:self.verticalScrollView] && self.verticalScrollView.isScrollEnabled) {
        BOOL topViewOpen = [self directionForVelocity:velocity.y withMinimum:40.0f andPosition:targetContentOffset->y/(self.verticalScrollView.contentSize.height-CGRectGetHeight(self.verticalScrollView.frame))];
        CGFloat offset = topViewOpen ? 0.0f-self.verticalScrollView.contentInset.top : CGRectGetMinY(self.navigationBar.frame);
        *targetContentOffset = CGPointMake(targetContentOffset->x, offset);
        [self setTopViewOpen:topViewOpen withAnimationDuration:ThreePaneAnimationDurationFast completion:nil];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    UIView *firstResponder = scrollView.firstResponder;
    if (!firstResponder || ![scrollView eventuallyContainsSubview:firstResponder]) {
        return;
    }
    
    CGRect firstResponderRect = [scrollView convertRect:firstResponder.frame fromView:firstResponder.superview];
    CGRect insetRect = CGRectInset(firstResponderRect, -1.0f*self.scrollPadding.width, -1.0f*self.scrollPadding.height);
    [scrollView scrollRectToVisible:insetRect animated:YES];
}

#pragma mark // Delegated Methods (UITextFieldDelegate) //

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet].invertedSet].length) {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark // Private Methods (Setup) //

- (void)setup {
    self.scrollPadding = CGSizeMake(0.0f, 8.0f);
    
    self.viewHasLoaded = NO;
    
    [self addObserversToKeyboard];
}

- (void)teardown {
    [self removeObserversFromKeyboard];
}

#pragma mark // Private Methods (IBActions) //

- (IBAction)touchUpInside:(id)sender {
    if ([sender isEqual:self.leftButton]) {
        [self setSideViewOpen:!self.sideViewIsOpen animated:YES completion:nil];
        return;
    }
    
    if ([sender isEqual:self.rightButton]) {
        [self setTopViewOpen:!self.topViewIsOpen animated:YES completion:nil];
        return;
    }
}

#pragma mark // Private Methods (Gestures) //

- (void)scrollViewDidPan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    BOOL horizontalEnabled, verticalEnabled;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            horizontalEnabled = (fabs(velocity.x) > fabs(velocity.y));
            self.horizontalScrollView.scrollEnabled = horizontalEnabled;
            verticalEnabled = (fabs(velocity.x) < fabs(velocity.y));
            self.verticalScrollView.scrollEnabled = verticalEnabled;
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            self.horizontalScrollView.scrollEnabled = YES;
            self.verticalScrollView.scrollEnabled = YES;
            break;
        default:
            break;
    }
}

- (IBAction)viewWasTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [self setSideViewOpen:NO animated:YES completion:nil];
}

#pragma mark // Private Methods (Observers) //

- (void)addObserversToKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObserversFromKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark // Private Methods (Responders) //

- (void)keyboardFrameWillChange:(NSNotification *)notification {
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.animationDuration = animationDuration;
    [self setKeyboardHeight:CGRectGetHeight(frame) animated:YES completion:nil];
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.animationDuration = animationDuration;
    [self setKeyboardHeight:0.0f animated:YES completion:nil];
}

#pragma mark // Private Methods (Other) //

- (void)setSideViewOpen:(BOOL)sideViewOpen withAnimationDuration:(NSTimeInterval)animationDuration completion:(void (^)(BOOL))completionBlock {
    _sideViewOpen = sideViewOpen;
    self.leftButton.title = sideViewOpen ? @"Done" : @"Side";
    if (self.delegate && [self.delegate respondsToSelector:@selector(threePaneViewWillChangePosition:)]) {
        [self.delegate threePaneViewWillChangePosition:self];
    }
    CGFloat contentOffSetX = sideViewOpen ? 0.0f : CGRectGetMinX(self.verticalScrollView.frame);
    [UIView animateWithDuration:animationDuration animations:^{
        self.horizontalScrollView.contentOffset = CGPointMake(contentOffSetX-self.horizontalScrollView.contentInset.left, self.horizontalScrollView.contentOffset.y);
    } completion:^(BOOL finished) {
        self.tapGestureRecognizer.enabled = sideViewOpen;
        if (completionBlock) {
            completionBlock(finished);
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(threePaneViewDidChangePosition:)]) {
            [self.delegate threePaneViewDidChangePosition:self];
        }
    }];
}

- (void)setTopViewOpen:(BOOL)topViewOpen withAnimationDuration:(NSTimeInterval)animationDuration completion:(void (^)(BOOL))completionBlock {
    _topViewOpen = topViewOpen;
    self.rightButton.title = topViewOpen ? @"Done" : @"Top";
    if (self.delegate && [self.delegate respondsToSelector:@selector(threePaneViewWillChangePosition:)]) {
        [self.delegate threePaneViewWillChangePosition:self];
    }
    CGFloat contentOffsetY = topViewOpen ? 0.0f : CGRectGetMinY(self.navigationBar.frame);
    [UIView animateWithDuration:animationDuration animations:^{
        self.verticalScrollView.contentOffset = CGPointMake(self.verticalScrollView.contentOffset.x, contentOffsetY-self.verticalScrollView.contentInset.top);
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock(finished);
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(threePaneViewDidChangePosition:)]) {
            [self.delegate threePaneViewDidChangePosition:self];
        }
    }];
}

- (BOOL)directionForVelocity:(CGFloat)velocity withMinimum:(CGFloat)minimum andPosition:(CGFloat)position {
    if (position < 0) {
        return YES;
    }
    
    if (position > 1) {
        return NO;
    }
    
    if (fabs(velocity) < minimum) {
        return (position <= 0.5f);
    }
    
    return (velocity > 0);
}

@end
