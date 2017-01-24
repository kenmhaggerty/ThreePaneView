//
//  ThreePaneViewController.m
//  ThreePaneView
//
//  Created by Ken M. Haggerty on 2/1/13.
//  Copyright (c) 2013 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Private) //

// TO DO:
// [_] Adjust size and layouts if nil-ing or un-nil-ing
// [_] Add in fade out function option when removing view controller
// [_] Add in animate away function when removing view controller

#pragma mark - // IMPORTS (Private) //

#import "ThreePaneViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CPAnimationStep.h"
#import "CPAnimationProgram.h"
#import "CPAnimationSequence.h"
//#import "SideTabBarController.h" // temporary

#pragma mark - // DEFINITIONS (Private) //

#define MAINVIEW_CONTROLLER_ID @"Main View Controller"
#define TOPVIEW_CONTROLLER_ID @"Top View Controller"
#define SIDEVIEW_CONTROLLER_ID @"Side View Controller"
#define OVERHANG_HORIZONTAL self.view.bounds.size.width*0.25
#define OVERHANG_VERTICAL 64
#define CONTAINER_VIEW_TOP_BOTTOM_BORDER 80
#define MIN_PULL_TO_OPEN 10
#define DEFAULT_ANIMATION_SPEED 0.15
#define ANIMATION_MULTIPLE 1.25
#define ANIMATION_SLOW 1.5
//#define STATUS_BAR_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

@interface ThreePaneViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) CustomButton *lockView;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UIView *sideView;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic) BOOL containerViewIsBeingMoved;
@property (nonatomic) CGPoint mainViewSnapLocationDefault;
@property (nonatomic) CGPoint mainViewSnapLocationVertical;
@property (nonatomic) CGPoint mainViewSnapLocationHorizontal;
@property (nonatomic) CGPoint mainViewSnapLocation;
@property (nonatomic, strong) NSNumber *viewHasAppeared;
@property (nonatomic) CGPoint touchLocation;
@property (nonatomic) BOOL canDragMainViewVertically;
@property (nonatomic) BOOL canDragMainViewHorizontally;
@property (nonatomic) BOOL mainViewIsMovingBackTowardsDefault;
//- (void)mainViewIsBeingDragged:(UIPanGestureRecognizer *)gestureRecognizer;
//- (void)topViewIsBeingDragged:(UIPanGestureRecognizer *)gestureRecognizer;
- (CPAnimationSequence *)viewMainViewAnimationSequence;
- (CPAnimationSequence *)viewTopViewAnimationSequence;
- (CPAnimationSequence *)viewSideViewAnimationSequence;
- (void)layoutPaneViews;
@end

@implementation ThreePaneViewController

#pragma mark - // SETTERS AND GETTERS //

@synthesize mainViewController = _mainViewController;
@synthesize topViewController = _topViewController;
@synthesize sideViewController = _sideViewController;
@synthesize buttonTopView = _buttonTopView;
@synthesize buttonSideView = _buttonSideView;
@synthesize canViewMainView = _canViewMainView;
@synthesize canViewTopView = _canViewTopView;
@synthesize canViewSideView = _canViewSideView;
@synthesize mainView = _mainView;
@synthesize lockView = _lockView;
@synthesize topView = _topView;
@synthesize sideView = _sideView;
@synthesize containerView = _containerView;
@synthesize containerViewIsBeingMoved = _containerViewIsBeingMoved;
@synthesize mainViewSnapLocationDefault = _mainViewSnapLocationDefault;
@synthesize mainViewSnapLocationVertical = _mainViewSnapLocationVertical;
@synthesize mainViewSnapLocationHorizontal = _mainViewSnapLocationHorizontal;
@synthesize mainViewSnapLocation = _mainViewSnapLocation;
@synthesize viewHasAppeared = _viewHasAppeared;
@synthesize touchLocation = _touchLocation;
@synthesize canDragMainViewVertically = _canDragMainViewVertically;
@synthesize canDragMainViewHorizontally = _canDragMainViewHorizontally;
@synthesize mainViewIsMovingBackTowardsDefault = _mainViewIsMovingBackTowardsDefault;

- (void)setViewHasAppeared:(NSNumber *)viewHasAppeared
{
    _viewHasAppeared = viewHasAppeared;
}

- (NSNumber *)viewHasAppeared
{
    if (!_viewHasAppeared) _viewHasAppeared = [NSNumber numberWithBool:NO];
    return _viewHasAppeared;
}

#pragma mark - // INITS AND LOADS //

- (id)initWithMainVC:(UIViewController <ThreePaneChildViewProtocol> *)mainVC topVC:(UIViewController <ThreePaneChildViewProtocol> *)topVC sideVC:(UIViewController <ThreePaneChildViewProtocol> *)sideVC
{
    self = [super init];
    if (self)
    {
        self.mainViewController = mainVC;
        self.topViewController = topVC;
        self.sideViewController = sideVC;
        
        if ([self.mainViewController respondsToSelector:@selector(topViewController)]) self.mainViewController.topViewController = self.topViewController;
        if ([self.mainViewController respondsToSelector:@selector(sideViewController)]) self.mainViewController.sideViewController = self.sideViewController;
        if ([self.topViewController respondsToSelector:@selector(mainViewController)]) self.topViewController.mainViewController = self.mainViewController;
        if ([self.topViewController respondsToSelector:@selector(sideViewController)]) self.topViewController.sideViewController = self.sideViewController;
        if ([self.sideViewController respondsToSelector:@selector(mainViewController)]) self.sideViewController.mainViewController = self.mainViewController;
        if ([self.sideViewController respondsToSelector:@selector(topViewController)]) self.sideViewController.topViewController = self.topViewController;
    }
    return self;
}

- (void)awakeFromNib
{
    NSLog(@"[awakeFromNib] TPVC");
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    NSLog(@"[viewDidLoad] TPVC");
    [super viewDidLoad];
    
    // CUSTOM BUTTONS SETUP //
    
    self.buttonSideView.delegate = self;
    self.buttonSideView.userInteractionEnabled = YES;
    self.buttonSideView.viewForCoordinates = self.view;
    self.buttonSideView.imageUntouched = [UIImage imageNamed:@"button_sidebar_unpressed_nomessages"];
    self.buttonSideView.imageActive = [UIImage imageNamed:@"button_sidebar_unpressed_messages"];
    self.buttonSideView.imageTouched = [UIImage imageNamed:@"button_sidebar_pressed"];
    self.buttonTopView.delegate = self;
    self.buttonTopView.userInteractionEnabled = YES;
    self.buttonTopView.viewForCoordinates = self.view;
    self.buttonTopView.imageUntouched = [UIImage imageNamed:@"button_help_unpressed_noupdates"];
    self.buttonTopView.imageActive = [UIImage imageNamed:@"button_help_unpressed_updates"];
    self.buttonTopView.imageTouched = [UIImage imageNamed:@"button_help_pressed"];
    
    // CONTAINER VIEW SETUP //
    
    self.containerView.frame = CGRectMake(0, OVERHANG_VERTICAL-self.view.frame.size.height-CONTAINER_VIEW_TOP_BOTTOM_BORDER, self.view.frame.size.width, 2*(self.view.frame.size.height+CONTAINER_VIEW_TOP_BOTTOM_BORDER)-OVERHANG_VERTICAL);
    self.containerViewIsBeingMoved = NO;
    [self.containerView setClipsToBounds:NO];
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(0.0f, 10.0f);
    self.containerView.layer.shadowOpacity = 0.5f;
    self.containerView.layer.shadowRadius = 10.0f;
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
    
    // SIDE, MAIN, AND TOP VIEW CONTROLLERS //
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    self.mainViewSnapLocationDefault = CGPointMake(self.containerView.center.x, self.containerView.center.y);
    self.mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:MAINVIEW_CONTROLLER_ID];
    self.mainViewController.threePaneViewController = self;
    [self addChildViewController:self.mainViewController];
    [self.containerView addSubview:self.mainViewController.view];
    [self.mainViewController.view setFrame:self.mainView.frame];
    [self.mainView removeFromSuperview];
    [self setMainView:self.mainViewController.view];
    [self.containerView bringSubviewToFront:self.buttonTopView];
    [self.containerView bringSubviewToFront:self.buttonSideView];
    [self setCanViewMainView:YES];
//    [self.mainView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewIsBeingDragged:)]];
    
    self.mainViewSnapLocationVertical = CGPointMake(self.containerView.center.x, self.containerView.frame.size.height/2.0-self.topView.frame.origin.y);
    self.topViewController = [mainStoryboard instantiateViewControllerWithIdentifier:TOPVIEW_CONTROLLER_ID];
    self.topViewController.threePaneViewController = self;
    [self addChildViewController:self.topViewController];
    [self.containerView addSubview:self.topViewController.view];
    [self.topViewController.view setFrame:self.topView.frame];
    [self.topView removeFromSuperview];
    [self setTopView:self.topViewController.view];
    [self.containerView bringSubviewToFront:self.mainView];
    [self.containerView bringSubviewToFront:self.buttonTopView];
    [self.containerView bringSubviewToFront:self.buttonSideView];
    [self setCanViewTopView:YES];
    [self.topView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topViewIsBeingDragged:)]];
    
    self.mainViewSnapLocationHorizontal = CGPointMake(self.containerView.center.x+self.view.bounds.size.width-OVERHANG_HORIZONTAL, self.containerView.center.y);
    self.sideViewController = [mainStoryboard instantiateViewControllerWithIdentifier:SIDEVIEW_CONTROLLER_ID];
    self.sideViewController.threePaneViewController = self;
    [self addChildViewController:self.sideViewController];
    [self.view addSubview:self.sideViewController.view];
    [self.sideViewController.view setFrame:self.sideView.frame];
    [self.sideView removeFromSuperview];
    [self setSideView:self.sideViewController.view];
    [self.view bringSubviewToFront:self.containerView];
    [self setCanViewSideView:YES];
    [self.sideView setClipsToBounds:NO];
    self.sideView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.sideView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.sideView.layer.shadowOpacity = 0.5f;
    self.sideView.layer.shadowRadius = 7.5f;
    self.sideView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.sideView.bounds].CGPath;
    
    NSMutableArray *childrenToCheck = [[NSMutableArray alloc] initWithArray:self.childViewControllers];
    while (childrenToCheck.count > 0)
    {
        UIViewController *viewControllerOfInterest = [childrenToCheck objectAtIndex:0];
        if ([viewControllerOfInterest conformsToProtocol:@protocol(ThreePaneChildViewProtocol)])
        {
            if ([viewControllerOfInterest respondsToSelector:@selector(threePaneViewController)])
            {
                ((UIViewController <ThreePaneChildViewProtocol> *)viewControllerOfInterest).threePaneViewController = self;
            }
            if ([viewControllerOfInterest respondsToSelector:@selector(mainViewController)])
            {
                ((UIViewController <ThreePaneChildViewProtocol> *)viewControllerOfInterest).mainViewController = self.mainViewController;
            }
            if ([viewControllerOfInterest respondsToSelector:@selector(topViewController)])
            {
                ((UIViewController <ThreePaneChildViewProtocol> *)viewControllerOfInterest).topViewController = self.topViewController;
            }
            if ([viewControllerOfInterest respondsToSelector:@selector(sideViewController)])
            {
                ((UIViewController <ThreePaneChildViewProtocol> *)viewControllerOfInterest).sideViewController = self.sideViewController;
            }
        }
        [childrenToCheck addObjectsFromArray:viewControllerOfInterest.childViewControllers];
        [childrenToCheck removeObject:viewControllerOfInterest];
    }
    
    // OTHER //
    
    [self layoutPaneViews];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"NSTexturedFullScreenBackgroundColor"]]];
    
    UIGraphicsBeginImageContext(self.containerView.frame.size);
    [[UIImage imageNamed:@"background"] drawInRect:self.containerView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setAsContainerViewBackground:image];
    
    self.touchLocation = CGPointZero;
    
    // KEY VALUE OBSERVING //
    
    [self addObserver:self forKeyPath:@"mainViewController" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"topViewController" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"sideViewController" options:NSKeyValueObservingOptionNew context:NULL];
    [self.mainViewController.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [self.mainViewController.view addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    [self.topViewController.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [self.topViewController.view addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    [self.sideViewController.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [self.sideViewController.view addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    
    // COMPLETION //
    
    self.mainViewSnapLocation = self.mainViewSnapLocationDefault;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"[viewWillAppear:] TPVC");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"[viewDidAppear:] TPVC");
    [super viewDidAppear:animated];
    
    self.viewHasAppeared = [NSNumber numberWithBool:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"[viewWillDisappear:] TPVC");
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"[viewDidDisappear:] TPVC");
    [super viewDidDisappear:animated];
}

- (void)viewWillUnload
{
    NSLog(@"[viewWillUnload] TPVC");
    [super viewWillUnload];
}

- (void)viewDidUnload
{
    NSLog(@"[viewDidUnload] TPVC");
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - // PUBLIC FUNCTIONS //

- (BOOL)isViewingMainView
{
    if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault)) return YES;
    return NO;
}

- (BOOL)isViewingTopView
{
    if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical)) return YES;
    return NO;
}

- (BOOL)isViewingSideView
{
    if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal)) return YES;
    return NO;
}

- (void)viewMainView:(BOOL)animated
{
    NSLog(@"[viewMainView]");
    if ((self.mainView) && (self.canViewMainView))
    {
        if (!self.containerViewIsBeingMoved)
        {
            if (self.lockView)
            {
                [self.lockView removeFromSuperview];
                self.lockView = nil;
            }
//            [[self viewMainViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
            [[self viewMainViewAnimationSequence] runAnimated:animated];
        }
    }
}

- (void)viewTopView:(BOOL)animated
{
    NSLog(@"[viewTopView]");
    if ((self.topView) && (self.canViewTopView))
    {
        if (!self.containerViewIsBeingMoved)
        {
            if (!self.lockView)
            {
                self.lockView = [[CustomButton alloc] initWithFrame:self.mainView.frame];
                self.lockView.delegate = self;
                self.lockView.userInteractionEnabled = YES;
                self.lockView.viewForCoordinates = self.view;
                [self.containerView addSubview:self.lockView];
            }
            [self.containerView bringSubviewToFront:self.lockView];
            [self.containerView bringSubviewToFront:self.buttonTopView];
//            [[self viewTopViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
            [[self viewTopViewAnimationSequence] runAnimated:animated];
        }
    }
}

- (void)viewSideView:(BOOL)animated
{
    NSLog(@"[viewSideView]");
    if ((self.sideView) && (self.canViewSideView))
    {
        if (!self.containerViewIsBeingMoved)
        {
            if (!self.lockView)
            {
                self.lockView = [[CustomButton alloc] initWithFrame:self.mainView.frame];
                self.lockView.delegate = self;
                self.lockView.userInteractionEnabled = YES;
                self.lockView.viewForCoordinates = self.view;
                [self.containerView addSubview:self.lockView];
            }
            [self.containerView bringSubviewToFront:self.lockView];
            [self.containerView bringSubviewToFront:self.buttonSideView];
//            [[self viewSideViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
            [[self viewSideViewAnimationSequence] runAnimated:animated];
        }
    }
}

- (void)setAsContainerViewBackground:(UIImage *)backgroundImage
{
    [self.containerView setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
}

#pragma mark - // DELEGATED FUNCTIONS (ThreePaneViewController) //

- (void)popMainView:(BOOL)animated
{
    NSLog(@"[popMainView]");
    if (self.mainViewController)
    {
        CPAnimationStep *fadeMainView = [CPAnimationStep after:0.0 for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            [self.mainView setAlpha:0.0];
        }];
        CPAnimationStep *removeMainView = [CPAnimationStep after:0.0 for:0.0 animate:^{
            [self.mainViewController removeFromParentViewController];
            self.mainViewController = nil;
            UIView *blankMainView = [[UIView alloc] initWithFrame:self.mainView.frame];
            [self.containerView addSubview:blankMainView];
            [self.mainView removeFromSuperview];
            [self setMainView:blankMainView];
            [self.mainView setAlpha:1.0];
            [self.containerView bringSubviewToFront:self.buttonTopView];
            [self.containerView bringSubviewToFront:self.buttonSideView];
            self.canViewMainView = NO;
        }];
        CPAnimationSequence *popMainViewSequence;
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault))
        {
            CPAnimationStep *animateAway = [CPAnimationStep after:0.0 for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
                if (self.canViewSideView) [self viewSideView:YES];
                else if (self.canViewTopView) [self viewTopView:YES];
            }];
            popMainViewSequence = [CPAnimationSequence sequenceWithSteps:fadeMainView, removeMainView, animateAway, nil];
        }
        else popMainViewSequence = [CPAnimationSequence sequenceWithSteps:fadeMainView, removeMainView, nil];
        [popMainViewSequence runAnimated:animated];
    }
    else NSLog(@"[TEST] No mainViewController to pop");
}

- (void)popTopView:(BOOL)animated
{
    NSLog(@"[popTopView]");
    if (self.topViewController)
    {
        CPAnimationStep *fadeTopView = [CPAnimationStep after:0.0 for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            [self.topView setAlpha:0.0];
        }];
        CPAnimationStep *removeTopView = [CPAnimationStep after:0.0 for:0.0 animate:^{
            [self.topViewController removeFromParentViewController];
            self.topViewController = nil;
            UIView *blankTopView = [[UIView alloc] initWithFrame:self.topView.frame];
            [self.containerView addSubview:blankTopView];
            [self.topView removeFromSuperview];
            [self setTopView:blankTopView];
            [self.topView setAlpha:1.0];
            [self.containerView bringSubviewToFront:self.mainView];
            [self.containerView bringSubviewToFront:self.buttonTopView];
            [self.containerView bringSubviewToFront:self.buttonSideView];
            self.canViewTopView = NO;
        }];
        CPAnimationSequence *popTopViewSequence;
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical))
        {
            CPAnimationStep *animateAway = [CPAnimationStep after:0.0 for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
                if (self.canViewMainView) [self viewMainView:YES];
                else if (self.canViewSideView) [self viewSideView:YES];
            }];
            popTopViewSequence = [CPAnimationSequence sequenceWithSteps:fadeTopView, removeTopView, animateAway, nil];
        }
        else popTopViewSequence = [CPAnimationSequence sequenceWithSteps:fadeTopView, removeTopView, nil];
        [popTopViewSequence runAnimated:animated];
    }
    else NSLog(@"[TEST] No topViewController to pop");
}

- (void)popSideView:(BOOL)animated
{
    NSLog(@"[popSideView]");
    if (self.sideViewController)
    {
        CPAnimationStep *fadeSideView = [CPAnimationStep after:0.0 for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            [self.sideView setAlpha:0.0];
        }];
        CPAnimationStep *removeSideView = [CPAnimationStep after:0.0 for:0.0 animate:^{
            [self.topViewController removeFromParentViewController];
            self.sideViewController = nil;
            UIView *blankSideView = [[UIView alloc] initWithFrame:self.sideView.frame];
            [self.view addSubview:blankSideView];
            [self.sideView removeFromSuperview];
            [self setSideView:blankSideView];
            [self.sideView setAlpha:1.0];
            [self.view bringSubviewToFront:self.containerView];
            self.canViewSideView = NO;
        }];
        CPAnimationSequence *popSideViewSequence;
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal))
        {
            CPAnimationStep *animateAway = [CPAnimationStep after:0.0 for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
                if (self.canViewMainView) [self viewMainView:YES];
                else if (self.canViewTopView) [self viewTopView:YES];
            }];
            popSideViewSequence = [CPAnimationSequence sequenceWithSteps:fadeSideView, removeSideView, animateAway, nil];
        }
        else popSideViewSequence = [CPAnimationSequence sequenceWithSteps:fadeSideView, removeSideView, nil];
        [popSideViewSequence runAnimated:animated];
        
    }
    else NSLog(@"[TEST] No mainViewController to pop");
}

- (void)setAsMainViewController:(UIViewController <ThreePaneChildViewProtocol> *)viewController
{
    NSLog(@"[setAsMainViewController]");
    if ((![viewController isEqual:self.mainViewController]) && (viewController))
    {
        NSLog(@"[TEST] viewController does not equal mainViewController");
        [self.mainViewController removeFromParentViewController];
        self.mainViewController = viewController;
        self.mainViewController.threePaneViewController = self;
        [self addChildViewController:self.mainViewController];
        [self.containerView addSubview:self.mainViewController.view];
        [self.mainViewController.view setFrame:self.mainView.frame];
        [self.mainView removeFromSuperview];
        [self setMainView:self.mainViewController.view];
        [self.containerView bringSubviewToFront:self.buttonTopView];
        [self.containerView bringSubviewToFront:self.buttonSideView];
        self.canViewMainView = YES;
        if (((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical)) && (!self.canViewTopView)) || ((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal)) && (!self.canViewSideView))) [self viewMainView:NO];
    }
    else if (viewController) NSLog(@"[TEST] viewController equals mainViewController");
    else NSLog(@"[TEST] viewController is nil");
}

- (void)setAsTopViewController:(UIViewController <ThreePaneChildViewProtocol> *)viewController
{
    NSLog(@"[setAsTopViewController]");
    if ((![viewController isEqual:self.topViewController]) && (viewController))
    {
        NSLog(@"[TEST] viewController does not equal topViewController");
        [self.topViewController removeFromParentViewController];
        self.topViewController = viewController;
        self.topViewController.threePaneViewController = self;
        [self addChildViewController:self.topViewController];
        [self.containerView addSubview:self.topViewController.view];
        [self.topViewController.view setFrame:self.topView.frame];
        [self.topView removeFromSuperview];
        [self setTopView:self.topViewController.view];
        [self.containerView bringSubviewToFront:self.mainView];
        [self.containerView bringSubviewToFront:self.buttonTopView];
        [self.containerView bringSubviewToFront:self.buttonSideView];
        self.canViewTopView = YES;
        if (((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal)) && (!self.canViewSideView)) || ((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault)) && (!self.canViewMainView))) [self viewTopView:NO];
    }
    else if (viewController) NSLog(@"[TEST] viewController equals topViewController");
    else NSLog(@"[TEST] viewController is nil");
}

- (void)setAsSideViewController:(UIViewController <ThreePaneChildViewProtocol> *)viewController
{
    NSLog(@"[setAsSideViewController]");
    if ((![viewController isEqual:self.sideViewController]) && (viewController))
    {
        NSLog(@"[TEST] viewController does not equal sideViewController");
        [self.sideViewController removeFromParentViewController];
        self.sideViewController = viewController;
        self.sideViewController.threePaneViewController = self;
        [self addChildViewController:self.sideViewController];
        [self.view addSubview:self.sideViewController.view];
        [self.sideViewController.view setFrame:self.sideView.frame];
        [self.sideView removeFromSuperview];
        [self setSideView:self.sideViewController.view];
        [self.view bringSubviewToFront:self.containerView];
        self.canViewSideView = YES;
        if (((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical)) && (!self.canViewTopView)) || ((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault)) && (!self.canViewMainView))) [self viewSideView:NO];
    }
    else if (viewController) NSLog(@"[TEST] viewController equals sideViewController");
    else NSLog(@"[TEST] viewController is nil");
}

#pragma mark - // DELEGATED FUNCTIONS (CustomButton) //

- (void)buttonIsBeingMoved:(CustomButton *)sender
{
    if ((([sender isEqual:self.buttonSideView]) || ([sender isEqual:self.lockView])) && (self.containerView.center.y == self.mainViewSnapLocationDefault.y))
    {
        if ((self.containerView.center.x < self.mainViewSnapLocationDefault.x) || (!self.canViewSideView))
        {
            [self.containerView setCenter:CGPointMake(self.mainViewSnapLocationDefault.x+(sender.touchCurrent.x-sender.touchStart.x+self.mainViewSnapLocation.x-self.mainViewSnapLocationDefault.x)/2, self.containerView.center.y)];
        }
        else if (self.mainViewSnapLocationHorizontal.x < self.containerView.center.x)
        {
            [self.containerView setCenter:CGPointMake(self.mainViewSnapLocationHorizontal.x+(sender.touchCurrent.x-sender.touchStart.x+self.mainViewSnapLocation.x-self.mainViewSnapLocationHorizontal.x)/2, self.containerView.center.y)];
        }
        else
        {
            [self.containerView setCenter:CGPointMake(self.mainViewSnapLocation.x+sender.touchCurrent.x-sender.touchStart.x, self.containerView.center.y)];
        }
    }
    else if ((([sender isEqual:self.buttonTopView]) || ([sender isEqual:self.lockView])) && (self.containerView.center.x == self.mainViewSnapLocationDefault.x))
    {
        if ((self.containerView.center.y < self.mainViewSnapLocationDefault.y) || (!self.canViewTopView))
        {
            [self.containerView setCenter:CGPointMake(self.containerView.center.x, self.mainViewSnapLocationDefault.y+(sender.touchCurrent.y-sender.touchStart.y+self.mainViewSnapLocation.y-self.mainViewSnapLocationDefault.y)/2)];
        }
        else if (self.mainViewSnapLocationVertical.y < self.containerView.center.y)
        {
            [self.containerView setCenter:CGPointMake(self.containerView.center.x, self.mainViewSnapLocationVertical.y+(sender.touchCurrent.y-sender.touchStart.y+self.mainViewSnapLocation.y-self.mainViewSnapLocationVertical.y)/2)];
        }
        else
        {
            [self.containerView setCenter:CGPointMake(self.containerView.center.x, self.mainViewSnapLocation.y+sender.touchCurrent.y-sender.touchStart.y)];
        }
    }
}

- (void)buttonIsDoneMoving:(CustomButton *)sender
{
    NSLog(@"[buttonIsDoneMoving]");
    if ((([sender isEqual:self.buttonSideView]) || ([sender isEqual:self.lockView])) && (self.containerView.center.y == self.mainViewSnapLocationDefault.y))
    {
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault))
        {
            if (((self.mainViewSnapLocationDefault.x < self.containerView.center.x - MIN_PULL_TO_OPEN) && (([sender.touchDirection isEqualToString:@"NE"]) || ([sender.touchDirection isEqualToString:@"E"]) || ([sender.touchDirection isEqualToString:@"SE"]))) || ((self.mainViewSnapLocationHorizontal.x < self.containerView.center.x)))
            {
                [self viewSideView:YES];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenHorizontal)]) [self.mainViewController mainViewIsSnappedOpenHorizontal];
            }
            else
            {
                [self viewMainView:YES];
            }
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal))
        {
            if (((self.containerView.center.x + MIN_PULL_TO_OPEN < self.mainViewSnapLocationHorizontal.x) && (([sender.touchDirection isEqualToString:@"NW"]) || ([sender.touchDirection isEqualToString:@"W"]) || ([sender.touchDirection isEqualToString:@"SW"]))) || (self.containerView.center.x < self.mainViewSnapLocationDefault.x))
            {
                [self viewMainView:YES];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
            }
            else
            {
                [self viewSideView:YES];
            }
        }
    }
    else if ((([sender isEqual:self.buttonTopView]) || ([sender isEqual:self.lockView])) && (self.containerView.center.x == self.mainViewSnapLocationDefault.x)) // add in snap detection if past most recent message
    {
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault))
        {
            if (((self.mainViewSnapLocationDefault.y < self.containerView.center.y - MIN_PULL_TO_OPEN) && (([sender.touchDirection isEqualToString:@"SW"]) || ([sender.touchDirection isEqualToString:@"S"]) || ([sender.touchDirection isEqualToString:@"SE"]))) || (self.mainViewSnapLocationVertical.y < self.containerView.center.y))
            {
                [self viewTopView:YES];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenVertical)]) [self.mainViewController mainViewIsSnappedOpenVertical];
            }
            else
            {
                [self viewMainView:YES];
            }
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical))
        {
            if (((self.containerView.center.y + MIN_PULL_TO_OPEN < self.mainViewSnapLocationVertical.y) && (([sender.touchDirection isEqualToString:@"NW"]) || ([sender.touchDirection isEqualToString:@"N"]) || ([sender.touchDirection isEqualToString:@"NE"]))) || (self.containerView.center.y < self.mainViewSnapLocationDefault.y))
            {
                [self viewMainView:YES];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
            }
            else
            {
                [self viewTopView:YES];
            }
        }
    }
}

- (void)buttonWasTapped:(CustomButton *)sender
{
    NSLog(@"[buttonWasTapped]");
    if (([sender isEqual:self.buttonSideView]) && (self.containerView.center.y == self.mainViewSnapLocationDefault.y) && (!self.buttonTopView.isBeingTouched))
    {
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault))
        {
            [self viewSideView:YES];
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenHorizontal)]) [self.mainViewController mainViewIsSnappedOpenHorizontal];
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal))
        {
            [self viewMainView:YES];
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
        }
    }
    else if (([sender isEqual:self.buttonTopView]) && (self.containerView.center.x == self.mainViewSnapLocationDefault.x) && (!self.buttonTopView.isBeingTouched))
    {
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault))
        {
            [self viewTopView:YES];
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenVertical)]) [self.mainViewController mainViewIsSnappedOpenVertical];
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical))
        {
            [self viewMainView:YES];
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
        }
    }
}

#pragma mark - // PRIVATE FUNCTIONS //

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self])
    {
        if ([keyPath isEqualToString:@"mainViewController"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"mainViewControllerDidChange" object:nil];
        }
        else if ([keyPath isEqualToString:@"topViewController"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"topViewControllerDidChange" object:nil];
        }
        else if ([keyPath isEqualToString:@"sideViewController"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sideViewControllerDidChange" object:nil];
        }
    }
    else if ([object isEqual:self.mainViewController.view])
    {
        if (([keyPath isEqualToString:@"frame"]) || ([keyPath isEqualToString:@"bounds"]))
        {
            [self layoutPaneViews];
        }
    }
    else if ([object isEqual:self.topViewController.view])
    {
        if (([keyPath isEqualToString:@"frame"]) || ([keyPath isEqualToString:@"bounds"]))
        {
            [self layoutPaneViews];
        }
    }
    else if ([object isEqual:self.sideViewController.view])
    {
        if (([keyPath isEqualToString:@"frame"]) || ([keyPath isEqualToString:@"bounds"]))
        {
            [self layoutPaneViews];
        }
    }
}

- (void)mainViewIsBeingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.canDragMainViewHorizontally)
        {
            if ((self.containerView.center.x > self.mainViewSnapLocationDefault.x+MIN_PULL_TO_OPEN) && (!self.mainViewIsMovingBackTowardsDefault) && (self.canViewSideView))
            {
                [self viewSideView:YES];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenHorizontal)]) [self.mainViewController mainViewIsSnappedOpenHorizontal];
            }
            else
            {
                [self viewMainView:YES];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
            }
        }
        else if (self.canDragMainViewVertically)
        {
            if ((self.containerView.center.y > self.mainViewSnapLocationDefault.y+MIN_PULL_TO_OPEN) && (!self.mainViewIsMovingBackTowardsDefault) && (self.canViewTopView))
            {
                [self viewTopView:YES];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenVertical)]) [self.mainViewController mainViewIsSnappedOpenVertical];
            }
            else
            {
                [self viewMainView:YES];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
            }
        }
        self.touchLocation = CGPointZero;
    }
    else
    {
        CGPoint currentTouch = [gestureRecognizer locationInView:self.view];
        if ((!CGPointEqualToPoint(currentTouch, self.touchLocation)) && (!CGPointEqualToPoint(self.touchLocation, CGPointZero)))
        {
            if ((self.canDragMainViewVertically) && (!self.canDragMainViewHorizontally))
            {
                if ([gestureRecognizer velocityInView:self.view].y < 0) self.mainViewIsMovingBackTowardsDefault = YES;
                else self.mainViewIsMovingBackTowardsDefault = NO;
                if (((self.containerView.center.y+(currentTouch.y-self.touchLocation.y)) < self.mainViewSnapLocationDefault.y-CONTAINER_VIEW_TOP_BOTTOM_BORDER) || ((self.containerView.center.y+(currentTouch.y-self.touchLocation.y)) > self.mainViewSnapLocationVertical.y+CONTAINER_VIEW_TOP_BOTTOM_BORDER)) ;
                else if ((self.containerView.center.y+(currentTouch.y-self.touchLocation.y) < self.mainViewSnapLocationDefault.y) || (self.containerView.center.y+(currentTouch.y-self.touchLocation.y) > self.mainViewSnapLocationVertical.y) || (!self.canViewTopView))
                {
                    self.containerView.center = CGPointMake(self.containerView.center.x, self.containerView.center.y+(currentTouch.y-self.touchLocation.y)/2.0);
                }
                else self.containerView.center = CGPointMake(self.containerView.center.x, self.containerView.center.y+(currentTouch.y-self.touchLocation.y));
            }
            else if ((!self.canDragMainViewVertically) && (self.canDragMainViewHorizontally))
            {
                if ([gestureRecognizer velocityInView:self.view].x < 0) self.mainViewIsMovingBackTowardsDefault = YES;
                else self.mainViewIsMovingBackTowardsDefault = NO;
                if (((self.containerView.center.x+(currentTouch.x-self.touchLocation.x)) < self.mainViewSnapLocationDefault.x-CONTAINER_VIEW_TOP_BOTTOM_BORDER) || ((self.containerView.center.x+(currentTouch.x-self.touchLocation.x)) > self.mainViewSnapLocationHorizontal.x+CONTAINER_VIEW_TOP_BOTTOM_BORDER)) ;
                else if ((self.containerView.center.x+(currentTouch.x-self.touchLocation.x) < self.mainViewSnapLocationDefault.x) || (self.containerView.center.x+(currentTouch.x-self.touchLocation.x) > self.mainViewSnapLocationHorizontal.x) || (!self.canViewSideView))
                {
                    self.containerView.center = CGPointMake(self.containerView.center.x+(currentTouch.x-self.touchLocation.x)/2.0, self.containerView.center.y);
                }
                else self.containerView.center = CGPointMake(self.containerView.center.x+(currentTouch.x-self.touchLocation.x), self.containerView.center.y);
            }
            self.touchLocation = currentTouch;
        }
        if ((CGPointEqualToPoint(self.containerView.center, self.mainViewSnapLocation)) || (CGPointEqualToPoint(self.touchLocation, CGPointZero)))
        {
            self.touchLocation = currentTouch;
            self.canDragMainViewVertically = YES;
            self.canDragMainViewHorizontally = YES;
            if (fabs([gestureRecognizer velocityInView:self.view].x) > fabs([gestureRecognizer velocityInView:self.view].y)) self.canDragMainViewVertically = NO;
            else self.canDragMainViewHorizontally = NO;
        }
    }
}

- (void)topViewIsBeingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if ((self.containerView.center.y < self.mainViewSnapLocationVertical.y-MIN_PULL_TO_OPEN) && (self.mainViewIsMovingBackTowardsDefault))
        {
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
            [self viewMainView:YES];
        }
        else
        {
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenVertical)]) [self.mainViewController mainViewIsSnappedOpenVertical];
            [self viewTopView:YES];
        }
        self.touchLocation = CGPointZero;
    }
    else
    {
        CGPoint currentTouch = [gestureRecognizer locationInView:self.view];
        if ((!CGPointEqualToPoint(currentTouch, self.touchLocation)) && (!CGPointEqualToPoint(self.touchLocation, CGPointZero)))
        {
            if ([gestureRecognizer velocityInView:self.view].y < 0) self.mainViewIsMovingBackTowardsDefault = YES;
            else self.mainViewIsMovingBackTowardsDefault = NO;
            if (((self.containerView.center.y+(currentTouch.y-self.touchLocation.y)) < self.mainViewSnapLocationDefault.y-CONTAINER_VIEW_TOP_BOTTOM_BORDER) || ((self.containerView.center.y+(currentTouch.y-self.touchLocation.y)) > self.mainViewSnapLocationVertical.y+CONTAINER_VIEW_TOP_BOTTOM_BORDER)) ;
            else if ((self.containerView.center.y+(currentTouch.y-self.touchLocation.y) < self.mainViewSnapLocationDefault.y) || (self.containerView.center.y+(currentTouch.y-self.touchLocation.y) > self.mainViewSnapLocationVertical.y) || (!self.canViewTopView))
            {
                self.containerView.center = CGPointMake(self.containerView.center.x, self.containerView.center.y+(currentTouch.y-self.touchLocation.y)/2.0);
            }
            else self.containerView.center = CGPointMake(self.containerView.center.x, self.containerView.center.y+(currentTouch.y-self.touchLocation.y));
            self.touchLocation = currentTouch;
        }
        if ((CGPointEqualToPoint(self.containerView.center, self.mainViewSnapLocation)) || (CGPointEqualToPoint(self.touchLocation, CGPointZero)))
        {
            self.touchLocation = currentTouch;
        }
    }
}

- (CPAnimationSequence *)viewMainViewAnimationSequence
{
    CPAnimationStep *animateToLocation = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
        self.mainViewSnapLocation = self.mainViewSnapLocationDefault;
        [self.containerView setCenter:self.mainViewSnapLocation];
    }];
    return [CPAnimationSequence sequenceWithSteps:animateToLocation, nil];
}

- (CPAnimationSequence *)viewTopViewAnimationSequence
{
    if ((self.containerView.center.y == self.mainViewSnapLocationDefault.y) && (self.containerView.center.x != self.mainViewSnapLocationDefault.x) && (self.mainView))
    {
        CPAnimationStep *animateToMainView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationDefault;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        CPAnimationStep *animateToTopView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationVertical;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        return [CPAnimationSequence sequenceWithSteps:animateToMainView, animateToTopView, nil];
    }
    else
    {
        CPAnimationStep *animateToLocation = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationVertical;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        return [CPAnimationSequence sequenceWithSteps:animateToLocation, nil];
    }
}

- (CPAnimationSequence *)viewSideViewAnimationSequence
{
    if ((self.containerView.center.x == self.mainViewSnapLocationDefault.x) && (self.containerView.center.y != self.mainViewSnapLocationDefault.y) && (self.mainView))
    {
        CPAnimationStep *animateToMainView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationDefault;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        CPAnimationStep *animateToSideView = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationHorizontal;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        return [CPAnimationSequence sequenceWithSteps:animateToMainView, animateToSideView, nil];
    }
    else
    {
        CPAnimationStep *animateToLocation = [CPAnimationStep for:ANIMATION_SLOW*DEFAULT_ANIMATION_SPEED*ANIMATION_MULTIPLE animate:^{
            self.mainViewSnapLocation = self.mainViewSnapLocationHorizontal;
            self.containerView.center = self.mainViewSnapLocation;
        }];
        return [CPAnimationSequence sequenceWithSteps:animateToLocation, nil];
    }
}

- (void)layoutPaneViews
{
    self.sideView.frame = CGRectMake(0, 0, self.view.frame.size.width-OVERHANG_HORIZONTAL, self.view.frame.size.height);
    self.sideView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.sideView.bounds].CGPath;
    self.mainView.frame = CGRectMake(0, CONTAINER_VIEW_TOP_BOTTOM_BORDER+self.view.frame.size.height-OVERHANG_VERTICAL, self.view.frame.size.width, self.view.frame.size.height);
    self.topView.frame = CGRectMake(0, CONTAINER_VIEW_TOP_BOTTOM_BORDER, self.view.frame.size.width, self.view.frame.size.height);
    self.buttonSideView.frame = CGRectMake(0, CONTAINER_VIEW_TOP_BOTTOM_BORDER+self.view.frame.size.height-0.5*(OVERHANG_VERTICAL+self.buttonSideView.frame.size.height), self.buttonSideView.frame.size.width, self.buttonSideView.frame.size.height);
    self.buttonTopView.frame = CGRectMake(self.view.frame.size.width-self.buttonTopView.frame.size.width, CONTAINER_VIEW_TOP_BOTTOM_BORDER+self.view.frame.size.height-0.5*(OVERHANG_VERTICAL+self.buttonTopView.frame.size.height), self.buttonTopView.frame.size.width, self.buttonTopView.frame.size.height);
}

@end