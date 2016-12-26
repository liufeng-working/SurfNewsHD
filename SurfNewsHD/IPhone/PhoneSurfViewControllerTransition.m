//
//  PhoneSurfTransitionDelegateObj.m
//  SurfNewsHD
//
//  Created by XuXg on 14-11-7.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "PhoneSurfViewControllerTransition.h"
#import "SNThreadViewerController.h"

#define kTransitionDuration .4f


@implementation PresentAnimation


// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return kTransitionDuration;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // 1. Get controllers from transition context
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // 2. Set init frame for toVC
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.frame = CGRectOffset(finalFrame, kContentWidth, 0.f);
    
    // 3. Add toVC's view to containerView
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    
    // 添加一个蒙版
    UIView* blackMask = [[UIView alloc]initWithFrame:containerView.bounds];
    blackMask.backgroundColor = [UIColor blackColor];
    blackMask.alpha = 0.f;
    [fromVC.view addSubview:blackMask];

    // 4. Do animate now
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                     animations:^{
                         blackMask.alpha = 0.4f;
                         toVC.view.frame = finalFrame;
                         fromVC.view.layer.affineTransform = CGAffineTransformMakeTranslation(-200, 0);
                     }
                     completion:^(BOOL finished){
            
                         [blackMask removeFromSuperview];
                         fromVC.view.layer.affineTransform = CGAffineTransformIdentity;
                         
                         // 5. Tell context that we completed.
                         [transitionContext completeTransition:YES];
                     }];
}

@end





@implementation DismissAnimation


// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return kTransitionDuration;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    
    // 1. Get controllers from transition context
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // 2. Set init frame for fromVC
    CGRect initFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect finalFrame = CGRectOffset(initFrame, kContentWidth, 0.f);
    
    // 3. Add target view to the container, and move it to back.
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    [containerView sendSubviewToBack:toVC.view];
    
    
    // 添加一个灰色蒙版
    toVC.view.layer.affineTransform = CGAffineTransformMakeTranslation(-200,0);
    UIView* blackMask = [[UIView alloc]initWithFrame:containerView.bounds];
    blackMask.backgroundColor = [UIColor blackColor];
    blackMask.alpha = 0.4f;
    [toVC.view addSubview:blackMask];
    
    
    // 4. Do animate now
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        blackMask.alpha = 0.f;
        fromVC.view.frame = finalFrame;
        toVC.view.layer.affineTransform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [blackMask removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}
@end




@interface SurfInteractive ()<UIGestureRecognizerDelegate>
{
    CGFloat _startScale;
    UIViewController *presentedVC;
}
@end

@implementation SurfInteractive


-(void)addPopGesture:(UIViewController *)viewController
{
    
    presentedVC = viewController;
    
    // 最初是用这个代码的，发现和UIScrollView冲突。
    // 参考：http://www.cnblogs.com/lexingyu/p/3702742.html
//    UIScreenEdgePanGestureRecognizer *edgeGes = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(edgeGesPan:)];
//    edgeGes.edges = UIRectEdgeLeft;
//    edgeGes.delegate = self;
//    [viewController.view addGestureRecognizer:edgeGes];
    
  
    // 替代方案
    UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(longPressGestureReceive:)];
    gr.minimumPressDuration = 0.0f;
    gr.delegate = self;
    [presentedVC.view addGestureRecognizer:gr];
    
}


/**
 *  屏幕边缘滑动响应事件(注：此方法没有使用，是因为这个手机和UIScrollView滑动手势冲突)
 *
 *  @param edgeGes 手势事件
 */
-(void)edgeGesPan:(UIScreenEdgePanGestureRecognizer *)edgeGes
{
    //1
    CGFloat translation =[edgeGes translationInView:presentedVC.view].x;
    CGFloat percent = translation / (presentedVC.view.bounds.size.width);
    percent = MIN(1.0, MAX(0.0, percent));
    NSLog(@"%f  state = %ld ",percent, (long)edgeGes.state);
    
    switch (edgeGes.state) {
        case UIGestureRecognizerStateBegan:{
            
            //2interactive
            self.interacting =  YES;
            [presentedVC dismissViewControllerAnimated:YES completion:nil];
            //如果是navigationController控制，这里应该是[presentedVC.navigationController popViewControllerAnimated:YES];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            //3
            [self updateInteractiveTransition:percent];
            break;
        }
            
        case UIGestureRecognizerStateEnded:{
            //4
            self.interacting = NO;
            if (percent > 0.2) {
                [self finishInteractiveTransition];
            }else{
                [self cancelInteractiveTransition];
            }
            break;
        }
            
        default:
            break;
    }
}

/**
 *  长按手势事件，直接从上面的edgeGesPan拷贝过来，并修改。
 *
 *  @param edgeGes 手势事件
 */
-(void)longPressGestureReceive:(UILongPressGestureRecognizer *)edgeGes
{
     CGFloat translation = [edgeGes locationInView:[[UIApplication sharedApplication] keyWindow]].x;
    CGFloat percent = translation / (presentedVC.view.bounds.size.width);
    percent = MIN(1.0, MAX(0.0, percent));
    DJLog(@"percent = %f , state = %ld",percent, (long)edgeGes.state);

    
    switch (edgeGes.state) {
        case UIGestureRecognizerStateBegan:{
            
            //2interactive
            self.interacting =  YES;
            
            [presentedVC dismissViewControllerAnimated:YES completion:nil];
            //如果是navigationController控制，这里应该是[presentedVC.navigationController popViewControllerAnimated:YES];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            //3
            // percent 是百分比在0~1之间，超出说明任务已经完成
            [self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            //4
            self.interacting = NO;
            if (percent > 0.3) {
                [self finishInteractiveTransition];
                
                //清除缓存，避免T+新闻出现混乱
                if ([presentedVC isKindOfClass:[SNThreadViewerController class]]) {
                    [(SNThreadViewerController *)presentedVC cleanViewersResource];
                }
            }else{
                [self cancelInteractiveTransition];
            }
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if (!presentedVC) {
        return NO;
    }
    

    // 下面都是正对PhoneSurfController类中的属性操作
    CGPoint p = [recognizer locationInView: presentedVC.view];
    if(p.x > 20.f )
        return NO;
    
    
    UIView *toolBar = nil;
    SEL toolsBarSelector = @selector(getBottomToolsBar);
    if ([presentedVC respondsToSelector:toolsBarSelector]) {
        StartSuppressPerformSelectorLeakWarning
        toolBar = [presentedVC performSelector:toolsBarSelector];
        EndSuppressPerformSelectorLeakWarning
    }
    
    // 底部工具栏区域，手势不响应
    if ((toolBar && p.y > toolBar.frame.origin.y)) {
        return NO;
    }
    
    // 顶部工具栏,手势不响应
    UIView *topToolBar = nil;
    SEL topBarSelector = @selector(topBarView);
    if ([presentedVC respondsToSelector:topBarSelector]) {
        StartSuppressPerformSelectorLeakWarning
        topToolBar = [presentedVC performSelector:topBarSelector];
        EndSuppressPerformSelectorLeakWarning
    }
    if (topToolBar) {
        CGFloat topY = topToolBar.frame.origin.y;
        CGFloat topH = CGRectGetHeight(topToolBar.bounds);
        
        if (p.y < topY + topH) {
            return NO;
        }
    }
    
    
    
    // 一些特殊的区域不响应手势
    if([presentedVC respondsToSelector:@selector(noGestureRecognizerRect)])
    {
        CGRect noGestureRect = [[presentedVC valueForKey:@"noGestureRecognizerRect"] CGRectValue];
        return !CGRectContainsPoint(noGestureRect, p);
    }
    return NO;
}
@end