//
//  ThreePaneViewController.m
//  SandboxTwo
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

@interface ThreePaneViewController ()
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

//- (void)setMainViewController:(UIViewController<ThreePaneChildViewProtocol> *)mainViewController
//{
//    if ([self.viewHasAppeared boolValue]) NSLog(@"[WARNING] Use setAsMainViewController after view has appeared");
//    else _mainViewController = mainViewController;
//}
//
//- (void)setTopViewController:(UIViewController<ThreePaneChildViewProtocol> *)topViewController
//{
//    if ([self.viewHasAppeared boolValue]) NSLog(@"[WARNING] Use setAsTopViewController after view has appeared");
//    else _topViewController = topViewController;
//}
//
//- (void)setSideViewController:(UIViewController<ThreePaneChildViewProtocol> *)sideViewController
//{
//    if ([self.viewHasAppeared boolValue]) NSLog(@"[WARNING] Use setAsSideViewController after view has appeared");
//    else _sideViewController = sideViewController;
//}

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
    NSLog(@"[awakeFromNib]");
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    NSLog(@"[viewDidLoad]");
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"[viewWillAppear:animated]");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"[viewDidAppear:animated]");
    [super viewDidAppear:animated];
    
    // CUSTOM BUTTONS SETUP //
    
    self.buttonSideView.delegate = self;
    self.buttonSideView.userInteractionEnabled = YES;
    self.buttonSideView.viewForCoordinates = self.view;
    self.buttonSideView.imageUntouched = [UIImage imageNamed:@"button_sidebar_unpressed_nomessages.png"];
    self.buttonSideView.imageActive = [UIImage imageNamed:@"button_sidebar_unpressed_messages.png"];
    self.buttonSideView.imageTouched = [UIImage imageNamed:@"button_sidebar_pressed.png"];
    self.buttonTopView.delegate = self;
    self.buttonTopView.userInteractionEnabled = YES;
    self.buttonTopView.viewForCoordinates = self.view;
    self.buttonTopView.imageUntouched = [UIImage imageNamed:@"button_help_unpressed_noupdates.png"];
    self.buttonTopView.imageActive = [UIImage imageNamed:@"button_help_unpressed_updates.png"];
    self.buttonTopView.imageTouched = [UIImage imageNamed:@"button_help_pressed.png"];
    
    // CONTAINER VIEW SETUP //
    
    self.containerView.frame = CGRectMake(0, OVERHANG_VERTICAL-self.view.frame.size.height-CONTAINER_VIEW_TOP_BOTTOM_BORDER, self.view.frame.size.width, 2*(self.view.frame.size.height+CONTAINER_VIEW_TOP_BOTTOM_BORDER)-OVERHANG_VERTICAL);
    self.containerViewIsBeingMoved = NO;
    [self.containerView setClipsToBounds:NO];
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(0.0f, 10.0f);
    self.containerView.layer.shadowOpacity = 0.75f;
    self.containerView.layer.shadowRadius = 10.0f;
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
    
    // SIDE, MAIN, AND TOP VIEW CONTROLLERS //
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
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
    
    NSMutableArray *childrenToCheck = [[NSMutableArray alloc] initWithArray:self.childViewControllers];
    while (childrenToCheck.count > 0)
    {
        UIViewController *viewControllerOfInterest = [childrenToCheck objectAtIndex:0];
        if ([viewControllerOfInterest conformsToProtocol:@protocol(ThreePaneChildViewProtocol)])
        {
            if ([viewControllerOfInterest respondsToSelector:@selector(threePaneViewController)]) ((UIViewController <ThreePaneChildViewProtocol> *)viewControllerOfInterest).threePaneViewController = self;
            if ([viewControllerOfInterest respondsToSelector:@selector(mainViewController)]) ((UIViewController <ThreePaneChildViewProtocol> *)viewControllerOfInterest).mainViewController = self.mainViewController;
            if ([viewControllerOfInterest respondsToSelector:@selector(topViewController)]) ((UIViewController <ThreePaneChildViewProtocol> *)viewControllerOfInterest).topViewController = self.topViewController;
            if ([viewControllerOfInterest respondsToSelector:@selector(sideViewController)]) ((UIViewController <ThreePaneChildViewProtocol> *)viewControllerOfInterest).sideViewController = self.sideViewController;
        }
        [childrenToCheck addObjectsFromArray:viewControllerOfInterest.childViewControllers];
        [childrenToCheck removeObject:viewControllerOfInterest];
    }
    
    // OTHER //
    
    [self layoutPaneViews];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"NSTexturedFullScreenBackgroundColor.png"]]];
    
    UIGraphicsBeginImageContext(self.containerView.frame.size);
    [[UIImage imageNamed:@"background.png"] drawInRect:self.containerView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setAsContainerViewBackground:image];
    
    // COMPLETION //
    
    self.mainViewSnapLocation = self.mainViewSnapLocationDefault;
    self.viewHasAppeared = [NSNumber numberWithBool:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"[viewWillDisappear:animated]");
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"[viewDidDisappear]");
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    NSLog(@"[viewDidUnload]");
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - // PUBLIC FUNCTIONS //

- (void)viewMainView
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
            [[self viewMainViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
        }
    }
}

- (void)viewTopView
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
            [[self viewTopViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
        }
    }
}

- (void)viewSideView
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
            [[self viewSideViewAnimationSequence] runAnimated:[self.viewHasAppeared boolValue]];
        }
    }
}

- (void)setAsContainerViewBackground:(UIImage *)backgroundImage
{
    [self.containerView setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
}

#pragma mark - // DELEGATED FUNCTIONS (ThreePaneViewController) //

- (void)popMainView
{
    NSLog(@"[popMainView]");
    if (self.mainViewController)
    {
        [self.mainViewController removeFromParentViewController];
        self.mainViewController = nil;
        UIView *blankMainView = [[UIView alloc] initWithFrame:self.mainView.frame];
        [self.containerView addSubview:blankMainView];
        [self.mainView removeFromSuperview];
        [self setMainView:blankMainView];
        [self.containerView bringSubviewToFront:self.buttonTopView];
        [self.containerView bringSubviewToFront:self.buttonSideView];
    }
    else NSLog(@"[TEST] No mainViewController to pop");
}

- (void)popTopView
{
    NSLog(@"[popTopView]");
    if (self.topViewController)
    {
        [self.topViewController removeFromParentViewController];
        self.topViewController = nil;
        UIView *blankTopView = [[UIView alloc] initWithFrame:self.topView.frame];
        [self.containerView addSubview:blankTopView];
        [self.topView removeFromSuperview];
        [self setTopView:blankTopView];
        [self.containerView bringSubviewToFront:self.mainView];
        [self.containerView bringSubviewToFront:self.buttonTopView];
        [self.containerView bringSubviewToFront:self.buttonSideView];
    }
    else NSLog(@"[TEST] No topViewController to pop");
}

- (void)popSideView
{
    NSLog(@"[popSideView]");
    if (self.sideViewController)
    {
        [self.topViewController removeFromParentViewController];
        self.sideViewController = nil;
        UIView *blankSideView = [[UIView alloc] initWithFrame:self.sideView.frame];
        [self.view addSubview:blankSideView];
        [self.sideView removeFromSuperview];
        [self setSideView:blankSideView];
        [self.view bringSubviewToFront:self.containerView];
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
    }
    else if (viewController) NSLog(@"[TEST] viewController equals sideViewController");
    else NSLog(@"[TEST] viewController is nil");
}

#pragma mark - // DELEGATED FUNCTIONS (CustomButton) //

- (void)buttonIsBeingMoved:(CustomButton *)sender
{
    if ((([sender isEqual:self.buttonSideView]) || ([sender isEqual:self.lockView])) && (self.containerView.center.y == self.mainViewSnapLocationDefault.y))
    {
        if ((self.containerView.center.x < self.mainViewSnapLocationDefault.x) || (!self.sideView))
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
        if ((self.containerView.center.y < self.mainViewSnapLocationDefault.y) || (!self.topView))
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
            if ((((self.mainViewSnapLocationDefault.x < self.containerView.center.x - MIN_PULL_TO_OPEN) && (([sender.touchDirection isEqualToString:@"NE"]) || ([sender.touchDirection isEqualToString:@"E"]) || ([sender.touchDirection isEqualToString:@"SE"]))) || ((self.mainViewSnapLocationHorizontal.x < self.containerView.center.x))) && (self.canViewSideView))
            {
                [self viewSideView];
            }
            else
            {
                [self viewMainView];
            }
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal))
        {
            if ((((self.containerView.center.x + MIN_PULL_TO_OPEN < self.mainViewSnapLocationHorizontal.x) && (([sender.touchDirection isEqualToString:@"NW"]) || ([sender.touchDirection isEqualToString:@"W"]) || ([sender.touchDirection isEqualToString:@"SW"]))) || (self.containerView.center.x < self.mainViewSnapLocationDefault.x)) && (self.canViewMainView))
            {
                [self viewMainView];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
            }
            else
            {
                [self viewSideView];
            }
        }
    }
    else if ((([sender isEqual:self.buttonTopView]) || ([sender isEqual:self.lockView])) && (self.containerView.center.x == self.mainViewSnapLocationDefault.x)) // add in snap detection if past most recent message
    {
        if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault))
        {
            if ((((self.mainViewSnapLocationDefault.y < self.containerView.center.y - MIN_PULL_TO_OPEN) && (([sender.touchDirection isEqualToString:@"SW"]) || ([sender.touchDirection isEqualToString:@"S"]) || ([sender.touchDirection isEqualToString:@"SE"]))) || (self.mainViewSnapLocationVertical.y < self.containerView.center.y)) && (self.canViewTopView))
            {
                [self viewTopView];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenVertical)]) [self.mainViewController mainViewIsSnappedOpenVertical];
            }
            else
            {
                [self viewMainView];
            }
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical))
        {
            if ((((self.containerView.center.y + MIN_PULL_TO_OPEN < self.mainViewSnapLocationVertical.y) && (([sender.touchDirection isEqualToString:@"NW"]) || ([sender.touchDirection isEqualToString:@"N"]) || ([sender.touchDirection isEqualToString:@"NE"]))) || (self.containerView.center.y < self.mainViewSnapLocationDefault.y)) && (self.canViewMainView))
            {
                [self viewMainView];
                if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
            }
            else
            {
                [self viewTopView];
            }
        }
    }
}

- (void)buttonWasTapped:(CustomButton *)sender
{
    NSLog(@"[buttonWasTapped]");
    if (([sender isEqual:self.buttonSideView]) && (self.containerView.center.y == self.mainViewSnapLocationDefault.y) && (!self.buttonTopView.isBeingTouched))
    {
        if ((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault)) && (self.sideView))
        {
            [self viewSideView];
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenHorizontal)]) [self.mainViewController mainViewIsSnappedOpenHorizontal];
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationHorizontal))
        {
            [self viewMainView];
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
        }
    }
    else if (([sender isEqual:self.buttonTopView]) && (self.containerView.center.x == self.mainViewSnapLocationDefault.x) && (!self.buttonTopView.isBeingTouched))
    {
        if ((CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationDefault)) && (self.topView))
        {
            [self viewTopView];
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedOpenVertical)]) [self.mainViewController mainViewIsSnappedOpenVertical];
        }
        else if (CGPointEqualToPoint(self.mainViewSnapLocation, self.mainViewSnapLocationVertical))
        {
            [self viewMainView];
            if ([self.mainViewController respondsToSelector:@selector(mainViewIsSnappedClosed)]) [self.mainViewController mainViewIsSnappedClosed];
        }
    }
}

#pragma mark - // PRIVATE FUNCTIONS //

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