//
//  MyWindow.m
//  tppispig
//
//  Created by gao wei on 10-7-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyWindow.h"
#import "NewsGalleryView.h"
@implementation SurfWindow
- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    /*
     取消手势侦听
    */
    return;
    //未附加关注
    if (attachedView_ == nil || attachedViewController_ == nil)
        return;
    
    NewsGalleryView *gallery = [NewsGalleryView sharedInstance];
    if ([gallery isShowGallery]) {
        return;
    }
    
    NSInteger relatedTouchCount = 0;//手指数
    NSSet *touches = [event allTouches];
    NSArray* allTouches = touches.allObjects;
    CGPoint center;//中心点
    center.x = center.y = 0;
    for (UITouch* touch in allTouches)      
    {
        CGPoint point = [touch locationInView:touch.view];
        CGPoint p = [touch.view convertPoint:point fromView:attachedView_];
        BOOL a = CGRectContainsPoint([attachedView_ bounds], p);
        
        if(a && touch.phase != UITouchPhaseEnded
           && touch.phase != UITouchPhaseCancelled)
        {
            relatedTouchCount ++;
            CGPoint loc = [touch locationInView:attachedView_];
            center.x += loc.x;
            center.y += loc.y;
        }
    }
    center.x /= relatedTouchCount;
    center.y /= relatedTouchCount;
    if (relatedTouchCount != 1) {
        //非单指取消响应，响应多指的，如果响应多指改为不等于0
        if (multiDragBegan) {
            multiDragBegan = NO;
            multiDragDirectionDetected = NO;
            if(isMultiDragHorizontal)
                [attachedViewController_ multiHorizontalDragEnded];
            else
                [attachedViewController_ multiVerticalDragEnded];            
        }
        return;
    }

    if (!multiDragBegan) {
        //首次拖动
        lastCenterPoint = center;
        multiDragBegan = YES;
        [attachedViewController_ multiDragBegan:lastCenterPoint];
    }else
    {
        if (multiDragDirectionDetected)
        {
            //已经检测出拖动方向
            if(isMultiDragHorizontal)
                [attachedViewController_ multiHorizontalDragDelta:center.x - lastCenterPoint.x];
            else
                [attachedViewController_ multiVerticalDragDelta:center.y - lastCenterPoint.y];
        }
        else
        {
            //未检测出拖动方向

            if(center.x != lastCenterPoint.x || center.y != lastCenterPoint.y)
            {
//                DJLog(@"%@ %@",NSStringFromCGPoint(center),NSStringFromCGPoint(lastCenterPoint));
//                DJLog(@"%d %d", fabs(center.x - lastCenterPoint.x),fabs(center.y - lastCenterPoint.y));
                
                isMultiDragHorizontal = fabs(center.x - lastCenterPoint.x) >=(fabs(center.y - lastCenterPoint.y)*2.f);
                multiDragDirectionDetected = YES;
                
                if(isMultiDragHorizontal)
                    [attachedViewController_ multiHorizontalDragDelta:center.x - lastCenterPoint.x];
                else
                    [attachedViewController_ multiVerticalDragDelta:center.y - lastCenterPoint.y];
            }
        }
    }
}
/*
- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    //未附加关注
    if (attachedView_ == nil || attachedViewController_ == nil)
        return;
    
    NSSet *touches = [event allTouches];
    
    //只关注两根或三根手指的操作
    
    if(multiDragBegan)
    {
        //当前处于多指操作过程中
 
        NSInteger relatedTouchCount = 0;
        NSArray* allTouches = touches.allObjects;
        for (UITouch* touch in allTouches)
        {
            CGPoint point = [touch locationInView:touch.view];
            CGPoint p = [touch.view convertPoint:point fromView:attachedView_];
            BOOL a = CGRectContainsPoint([attachedView_ bounds], p);
            
            if(a && touch.phase != UITouchPhaseEnded
               && touch.phase != UITouchPhaseCancelled)
            {
                relatedTouchCount ++;
            }
        }
        if (relatedTouchCount != 1) {
            if(isMultiDragHorizontal)
                [attachedViewController_ multiHorizontalDragEnded];
            else
                [attachedViewController_ multiVerticalDragEnded];
        }
        if(relatedTouchCount < 1 || relatedTouchCount > 3)
        {
            //结束多指操作
            multiDragBegan = NO;
            multiDragDirectionDetected = NO;
            
            if(isMultiDragHorizontal)
                [attachedViewController_ multiHorizontalDragEnded];
            else
                [attachedViewController_ multiVerticalDragEnded];
        }
        else
        {
            
            //继续多指操作
            
            //计算中心点
            
            CGPoint center;
            center.x = center.y = 0;
            for (UITouch* touch in allTouches)
            {
                CGPoint point = [touch locationInView:touch.view];
                CGPoint p = [touch.view convertPoint:point fromView:attachedView_];
                BOOL a = CGRectContainsPoint([attachedView_ bounds], p);
                if(a && touch.phase != UITouchPhaseEnded
                   && touch.phase != UITouchPhaseCancelled)
                {
                    CGPoint loc = [touch locationInView:attachedView_];
                    center.x += loc.x;
                    center.y += loc.y;
                }
            }
            
            center.x /= relatedTouchCount;
            center.y /= relatedTouchCount;
            
            if(multiDragDirectionDetected)
            {
                //已经检测出拖动方向
                if(isMultiDragHorizontal)
                    [attachedViewController_ multiHorizontalDragDelta:center.x - lastCenterPoint.x];
                else
                    [attachedViewController_ multiVerticalDragDelta:center.y - lastCenterPoint.y];
            }
            else
            {
                //尚未检测出拖动方向
                
                
                if(center.x != lastCenterPoint.x || center.y != lastCenterPoint.y)
                {
                    isMultiDragHorizontal = abs(center.x - lastCenterPoint.x) >= abs(center.y - lastCenterPoint.y);
                    multiDragDirectionDetected = YES;
                    
                    if(isMultiDragHorizontal)
                        [attachedViewController_ multiHorizontalDragBegan:center];
                    else
                        [attachedViewController_ multiVerticalDragBegan:center];
                }
            }
            lastCenterPoint = center;
        }
    }
    else
    {
        //当前不处于多指操作过程中
        NSInteger relatedTouchCount = 0;
        NSArray* allTouches = touches.allObjects;
        for (UITouch* touch in allTouches)
        {
            CGPoint point = [touch locationInView:touch.view];
            CGPoint p = [touch.view convertPoint:point fromView:attachedView_];
            BOOL a = CGRectContainsPoint([attachedView_ bounds], p);
            
            if(a && touch.phase != UITouchPhaseEnded
               && touch.phase != UITouchPhaseCancelled)
            {
                relatedTouchCount ++;
            }
        }
        
        if(relatedTouchCount == 2 || relatedTouchCount == 3)
        {
            //进入多指操作
            multiDragBegan = YES;
            multiDragDirectionDetected = NO;    //just in case
            
            CGPoint center;
            center.x = center.y = 0;
            for (UITouch* touch in allTouches)
            {
                CGPoint point = [touch locationInView:touch.view];
                CGPoint p = [touch.view convertPoint:point fromView:attachedView_];
                BOOL a = CGRectContainsPoint([attachedView_ bounds], p);
                
                if(a && touch.phase != UITouchPhaseEnded
                   && touch.phase != UITouchPhaseCancelled)
                {
                    CGPoint loc = [touch locationInView:attachedView_];
                    center.x += loc.x;
                    center.y += loc.y;
                }
            }
            
            center.x /= relatedTouchCount;
            center.y /= relatedTouchCount;
            lastCenterPoint = center;
        }
    }
}
*/
-(void)attachView:(UIView*)view andDelegate:(id<MultiDragDelegate>)delegate
{
    attachedView_ = view;
    attachedViewController_ = delegate;
    multiDragBegan = NO;
    multiDragDirectionDetected = NO;
}

-(void)detach
{
    multiDragBegan = NO;
    multiDragDirectionDetected = NO;
    attachedView_ = nil;
    attachedViewController_ = nil;
}


@end