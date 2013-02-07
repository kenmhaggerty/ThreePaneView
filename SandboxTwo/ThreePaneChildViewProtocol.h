//
//  ThreePaneChildViewProtocol.h
//  SandboxTwo
//
//  Created by Ken M. Haggerty on 2/2/13.
//  Copyright (c) 2013 Ken M. Haggerty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreePaneViewControllerProtocol.h"

@protocol ThreePaneViewControllerProtocol;

@protocol ThreePaneChildViewProtocol <NSObject>
@property (nonatomic, strong) UIViewController <ThreePaneViewControllerProtocol> *threePaneViewController;
@end