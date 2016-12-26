//
//  MyWindow.h
//  tppispig
//
//  Created by gao wei on 10-7-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//多指扫动代理
//注意：横向拖动和竖向拖动互斥，两者不会出现交织在一起的情况
@protocol MultiDragDelegate
@required
-(void)multiDragBegan:(CGPoint)startPoint;
//横向拖动三大回调
-(void)multiVerticalDragDelta:(CGFloat)verticalChanged;
-(void)multiVerticalDragEnded;

//竖向拖动三大回调
-(void)multiHorizontalDragDelta:(CGFloat)horizontalChanged;
-(void)multiHorizontalDragEnded;
@end

@interface SurfWindow : UIWindow
{
    BOOL multiDragBegan;
    BOOL multiDragDirectionDetected;
    BOOL isMultiDragHorizontal; //valid if multiDragDirectionDetected == YES
    CGPoint lastCenterPoint;
    __weak UIView* attachedView_;
    __weak id<MultiDragDelegate> attachedViewController_;
}

-(void)attachView:(UIView*)view andDelegate:(id<MultiDragDelegate>)delegate;
-(void)detach;

@end