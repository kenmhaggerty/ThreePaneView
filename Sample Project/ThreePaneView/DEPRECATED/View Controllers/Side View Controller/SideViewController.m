//
//  SideViewController.m
//  ThreePaneView
//
//  Created by Ken M. Haggerty on 2/1/13.
//  Copyright (c) 2013 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "SideViewController.h"

#pragma mark - // DEFINITIONS (Private) //

@interface SideViewController ()

@end

@implementation SideViewController

#pragma mark - // SETTERS AND GETTERS //

#pragma mark - // INITS AND LOADS //

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - // PUBLIC FUNCTIONS //

- (IBAction)viewMainView:(UIButton *)sender
{
    [self.threePaneViewController viewMainView:YES];
}

- (IBAction)popMainView:(UIButton *)sender
{
    [self.threePaneViewController popMainView:YES];
}

- (IBAction)addMainView:(UIButton *)sender
{
    [self.threePaneViewController setAsMainViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Alternate Main View Controller"]];
}

- (IBAction)lockMainView:(UIButton *)sender
{
    [self.threePaneViewController setCanViewMainView:NO];
}

- (IBAction)unlockMainView:(UIButton *)sender
{
    [self.threePaneViewController setCanViewMainView:YES];
}

- (IBAction)viewTopView:(UIButton *)sender
{
    [self.threePaneViewController viewTopView:YES];
}

- (IBAction)popTopView:(UIButton *)sender
{
    [self.threePaneViewController popTopView:YES];
}

- (IBAction)addTopView:(UIButton *)sender
{
    [self.threePaneViewController setAsTopViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Alternate Top View Controller"]];
}

- (IBAction)lockTopView:(UIButton *)sender
{
    [self.threePaneViewController setCanViewTopView:NO];
}

- (IBAction)unlockTopView:(UIButton *)sender
{
    [self.threePaneViewController setCanViewTopView:YES];
}

- (IBAction)viewSideView:(UIButton *)sender
{
    [self.threePaneViewController viewSideView:YES];
}

- (IBAction)popSideView:(UIButton *)sender
{
    [self.threePaneViewController popSideView:YES];
}

- (IBAction)addSideView:(UIButton *)sender
{
    [self.threePaneViewController setAsSideViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Alternate Side View Controller"]];
}

- (IBAction)lockSideView:(UIButton *)sender
{
    [self.threePaneViewController setCanViewSideView:NO];
}

- (IBAction)unlockSideView:(UIButton *)sender
{
    [self.threePaneViewController setCanViewSideView:YES];
}

#pragma mark - // DELEGATED FUNCTIONS //

#pragma mark - // PRIVATE FUNCTIONS //

@end
