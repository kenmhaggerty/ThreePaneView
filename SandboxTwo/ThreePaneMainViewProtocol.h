//
//  ThreePaneMainViewProtocol.h
//  SandboxTwo
//
//  Created by Ken M. Haggerty on 2/4/13.
//  Copyright (c) 2013 Ken M. Haggerty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreePaneChildViewProtocol.h"

@protocol ThreePaneChildViewProtocol;

@protocol ThreePaneMainViewProtocol <ThreePaneChildViewProtocol>
@optional
- (void)mainViewIsSnappedClosed;
- (void)mainViewIsSnappedOpenVertical;
- (void)mainViewIsSnappedOpenHorizontal;
@end