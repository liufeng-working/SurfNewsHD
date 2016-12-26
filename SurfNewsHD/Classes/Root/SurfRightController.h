//
//  SurfRightController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"

#import "HotRootController.h"
#import "LoginController.h"
#import "NewestRootController.h"
#import "SubscribeCenterController.h"
#import "SubscribeViewController.h"
#import "SubsChannelsListResponse.h"
#import "MGSplitDividerView.h"
@class SurfRightController;
@protocol SurfRightControllerDelegate <NSObject>
-(void)splitePosition:(CGFloat)position Animated:(BOOL)animate;
-(CGFloat)splitePositionInLeft:(UIViewController *)controller;
@end
@interface SurfRightController : UITabBarController<UIGestureRecognizerDelegate>
{
    HotRootController *hotController;
    LoginController *loginController;
    NewestRootController *newestController;
    SubscribeCenterController *subscribeRootController;
    
    NSMutableArray *subscribeArr;
    
    BOOL canMove;
    MGSplitDividerBeganStyle style;
    float startX;
}
@property(nonatomic,assign) id <SurfRightControllerDelegate>rightDelegate;
@property(nonatomic,strong) LoginController *loginController;
- (void)sortControllers;
- (void)didSelectRowAtSection:(SubsChannel *)channel :(NSIndexPath *)indexPath;
-(SubscribeViewController *)containSubscrib:(SubsChannel *)channel;
-(void)newContainSubscrib:(SubsChannel *)channel;
- (void) hideTabBar:(BOOL) hidden;
@end
