//
//  CustomAnimation.m
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import "CustomAnimation.h"


@interface CustomAnimation (private)
- (void)showBubbleMessage2:(NSString*)message;
@end

@implementation CustomAnimation

+ (void)showFromButtom:(UIView*)aView {
    CGRect newFrame = aView.frame;
    newFrame.origin.y = aView.frame.size.height;
    aView.frame = newFrame;
    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         CGRect newFrame = aView.frame;
                         newFrame.origin.y = 0.0;
                         aView.frame = newFrame;
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

+ (void)hideToButtomAndRemove:(UIView*)aView {
    [UIView animateWithDuration:0.3 animations:^(void) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        CGRect newFrame = aView.frame;
        newFrame.origin.y = aView.frame.size.height;
        aView.frame = newFrame;
    } completion:^(BOOL finished) {
        [aView removeFromSuperview];
    }];
}

+ (void)showFromTop:(UIView*)aView bounce:(BOOL)bounce {
    if (bounce) {
        [CustomAnimation showFromTop:aView];
    }
    CGRect newFrame = aView.frame;
    newFrame.origin.y = 0.0 - aView.frame.size.height;
    aView.frame = newFrame;
    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         CGRect newFrame = aView.frame;
                         newFrame.origin.y = 0.0;
                         aView.frame = newFrame;
                     } completion:^(BOOL finished) {
                         
                     }];
}

+ (void)showFromTop:(UIView*)aView {
    CGRect newFrame = aView.frame;
    newFrame.origin.y = 0.0 - aView.frame.size.height;
    aView.frame = newFrame;
    [UIView animateWithDuration:0.3 animations:^(void) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        CGRect newFrame = aView.frame;
        newFrame.origin.y = 30.0;
        aView.frame = newFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^(void) {
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            CGRect newFrame = aView.frame;
            newFrame.origin.y = -20.0;
            aView.frame = newFrame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^(void) {
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                CGRect newFrame = aView.frame;
                newFrame.origin.y = 0.0;
                aView.frame = newFrame;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}

+ (void)showFromTop:(UIView*)aView backgroundFadein:(UIView*)backView {
    CGRect newFrame = aView.frame;
    newFrame.origin.y = 0.0 - aView.frame.size.height;
    aView.frame = newFrame;
    backView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^(void) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        CGRect newFrame = aView.frame;
        newFrame.origin.y = 30.0;
        aView.frame = newFrame;
        backView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^(void) {
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            CGRect newFrame = aView.frame;
            newFrame.origin.y = -20.0;
            aView.frame = newFrame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^(void) {
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                CGRect newFrame = aView.frame;
                newFrame.origin.y = 0.0;
                aView.frame = newFrame;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}

+ (void)hideToTopAndRemove:(UIView*)aView {
    [UIView animateWithDuration:0.3 animations:^(void) {
        CGRect newFrame = aView.frame;
        newFrame.origin.y = 0 - [[UIApplication sharedApplication] keyWindow].frame.size.height;
        aView.frame = newFrame;
    } completion:^(BOOL finished) {
        [aView removeFromSuperview];
    }];
}

+ (void)showWaitingView {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if ([keyWindow viewWithTag:kWaitingViewTag]) {
        return;
    }
    IndicatorView *waitingView = [[IndicatorView alloc] initWithFrame:keyWindow.frame];
    waitingView.tag = kWaitingViewTag;
    [keyWindow addSubview:waitingView];
    [waitingView.activityIndicator startAnimating];
//    [waitingView release];
}

+ (void)showWaitingViewWithoutNavgation {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if ([keyWindow viewWithTag:kWaitingViewTag]) {
        return;
    }
    IndicatorView *waitingView = [[IndicatorView alloc] initWithFrame:CGRectMake(0, 50, keyWindow.frame.size.width, keyWindow.frame.size.height)];
    waitingView.tag = kWaitingViewTag;
    [keyWindow addSubview:waitingView];
    [waitingView.activityIndicator startAnimating];
//    [waitingView release];
}

+ (void)hideWaitingView {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    IndicatorView *waitingView = (IndicatorView*)[keyWindow viewWithTag:kWaitingViewTag];
    if (waitingView) {
        [waitingView removeFromSuperview];
    }
}

+ (void)showWaitingViewInView:(UIView*)view delegate:(id<IndicatorViewDelegate>)delegate {
    if ([view viewWithTag:kWaitingViewTag]) {
        return;
    }
    IndicatorView *waitingView = [[IndicatorView alloc] initWithFrame:view.bounds];
    waitingView.delegate = delegate;
    waitingView.tag = kWaitingViewTag;
    [view addSubview:waitingView];
    [waitingView.activityIndicator startAnimating];
//    [waitingView release];
}

+ (void)showWaitingViewInView:(UIView*)view waitingViewPosition:(CGPoint)position belowSubView:(UIView*)subView {
    IndicatorView *waitingView = (IndicatorView*)[view viewWithTag:kWaitingViewTag];
    if (waitingView) {
        if (subView) {
            [view insertSubview:waitingView belowSubview:subView];
        } else {
            [view addSubview:waitingView];
        }
        return;
    }
    waitingView = [[IndicatorView alloc] initWithFrame:view.bounds];
    waitingView.tag = kWaitingViewTag;
    if (!CGPointEqualToPoint(position, CGPointZero)) {
        waitingView.containerView.center = position;
    }
    if (subView) {
        [view insertSubview:waitingView belowSubview:subView];
    } else {
        [view addSubview:waitingView];
    }
    [waitingView.activityIndicator startAnimating];
//    [waitingView release];
}

+ (void)showWaitingViewInView:(UIView *)view waitingViewFram:(CGRect)rectFram
{
    if ([view viewWithTag:kWaitingViewTag]) {
        return;
    }
//    IndicatorView *waitingView = (IndicatorView*)[view viewWithTag:kWaitingViewTag];
    IndicatorView * waitingView = [[IndicatorView alloc] initWithFrame:rectFram];
    waitingView.tag = kWaitingViewTag;
    if (!CGPointEqualToPoint(CGPointZero, CGPointZero)) {
        waitingView.containerView.center = CGPointZero;
    }
 
    [view addSubview:waitingView];
    [waitingView.activityIndicator startAnimating];
//    [waitingView release];
}

+ (void)showWaitingViewInView:(UIView*)view belowSubView:(UIView*)subView {
    [self showWaitingViewInView:view waitingViewPosition:CGPointZero belowSubView:subView];
}

+ (void)showWaitingViewInView:(UIView*)view {
    [self showWaitingViewInView:view belowSubView:nil];
}

+ (void)showWaitingViewInViewWithoutNavgation:(UIView *)view
{
    [self showWaitingViewInView:view waitingViewFram:CGRectMake(0.0, 45.0, view.frame.size.width, view.frame.size.height)];
}

+ (void)hideWaitingViewFromView:(UIView*)view {
    IndicatorView *waitingView = (IndicatorView*)[view viewWithTag:kWaitingViewTag];
    if (waitingView) {
        [waitingView removeFromSuperview];
    }
}

+ (void)modifyNewsView:(UIView*)aView
{
    /*  //平面翻转
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotationAnimation.delegate = self;
    rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0];
    rotationAnimation.duration = 2;
    rotationAnimation.repeatCount = 1.0; 
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [rotationAnimation setValue:@"rotationAnimation" forKey:@"MyAnimationType"];
    [aView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    */
     
    
    CATransition *animation = [CATransition animation];
	animation.delegate = self;
	animation.duration = 1.0f;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.fillMode = kCAFillModeForwards;
//	animation.endProgress = 1.0f;
	animation.removedOnCompletion = NO;	
    animation.type = @"cube";
	
	[aView.layer addAnimation:animation forKey:@"animation"];
    [aView exchangeSubviewAtIndex:1 withSubviewAtIndex:0];//Just remove, not release or dealloc
}

+ (void)showNewsDetail:(UIView*)aView
{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.0f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.fillMode = kCAFillModeForwards;
    
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromRight;
	
	[aView.layer addAnimation:animation forKey:@"animation"];
}

+ (void)showShadow:(UIView*)aView {
    aView.layer.masksToBounds = NO;
    aView.layer.shadowPath = [UIBezierPath bezierPathWithRect:aView.layer.bounds].CGPath;
    aView.layer.shadowColor = [UIColor blackColor].CGColor;
    aView.layer.shadowOpacity = 0.9;
    aView.layer.shadowRadius = 3.0;
    aView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
}

+ (void)showBubbleMessage:(NSString*)message {
    CustomAnimation *customAnimation = [[CustomAnimation alloc] init];
    [customAnimation showBubbleMessage2:message];
    /*
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UILabel *msgLabel = [[[UILabel alloc] initWithFrame:CGRectMake((keyWindow.bounds.size.width-200.0)/2.0, (keyWindow.bounds.size.height-60.0)*3.0/4.0, 200.0, 100.0)] autorelease];
    msgLabel.layer.cornerRadius = 5.0;
    msgLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    msgLabel.textColor = [UIColor whiteColor];
    msgLabel.shadowColor = [UIColor blackColor];
    msgLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    msgLabel.text = message;
    msgLabel.textAlignment = UITextAlignmentCenter;
    msgLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    msgLabel.numberOfLines = 2;
    msgLabel.minimumFontSize = 14.0;
    msgLabel.adjustsFontSizeToFitWidth = YES;
    msgLabel.alpha = 0.0;
    msgLabel.userInteractionEnabled = NO;
    [keyWindow addSubview:msgLabel];
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         msgLabel.alpha = 0.9;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:4.0
                                          animations:^(void) {
                                              msgLabel.alpha = 1.0;
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.2
                                                               animations:^(void) {
                                                                   msgLabel.alpha = 0.0;
                                                               } completion:^(BOOL finished) {
                                                                   [msgLabel removeFromSuperview];
                                                               }];
                                          }];
                     }];
     */
}

//- (void)dealloc {
//    [bubbleMsgLabel_ removeFromSuperview];
//    [bubbleMsgLabel_ release];
//    [super dealloc];
//}

- (void)showBubbleMessage2:(NSString*)message {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//    [bubbleMsgLabel_ release];
//    if (IS_PAD) {
//        bubbleMsgLabel_ = [[UILabel alloc] initWithFrame:CGRectMake((keyWindow.bounds.size.width-250.0)/2.0, keyWindow.bounds.size.height-150.0, 250.0, 100.0)];
//    } else {
        bubbleMsgLabel_ = [[UILabel alloc] initWithFrame:CGRectMake((keyWindow.bounds.size.width-200.0)/2.0, keyWindow.bounds.size.height-150.0, 200.0, 100.0)];
//    }
    bubbleMsgLabel_.layer.cornerRadius = 5.0;
    bubbleMsgLabel_.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    bubbleMsgLabel_.textColor = [UIColor whiteColor];
    bubbleMsgLabel_.shadowColor = [UIColor blackColor];
    bubbleMsgLabel_.shadowOffset = CGSizeMake(0.0, -1.0);
    bubbleMsgLabel_.text = message;
    [bubbleMsgLabel_ setTextAlignment:NSTextAlignmentCenter];
    bubbleMsgLabel_.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    bubbleMsgLabel_.numberOfLines = 3;
    //bubbleMsgLabel_.minimumFontSize = 14.0;
    bubbleMsgLabel_.minimumScaleFactor = 14.f;
    bubbleMsgLabel_.adjustsFontSizeToFitWidth = YES;
    bubbleMsgLabel_.alpha = 0.0;
    bubbleMsgLabel_.userInteractionEnabled = NO;
    [keyWindow addSubview:bubbleMsgLabel_];
    [UIView animateWithDuration:0.4
                     animations:^(void) {
                        bubbleMsgLabel_.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [self performSelector:@selector(dismissBubbleMsg) withObject:nil afterDelay:4.0];
                     }];
}

- (void)dismissBubbleMsg {
    [UIView animateWithDuration:0.6
                     animations:^(void) {
                         bubbleMsgLabel_.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [bubbleMsgLabel_ removeFromSuperview];
//                         [bubbleMsgLabel_ release];
                         bubbleMsgLabel_ = nil;
                     }];
}


+ (void)showAlertView:(NSString *)messageStr
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:messageStr message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alertView show];
}

+ (UIImage *)imageRetun:(NSString *)imageName :(CGRect)rect alpha:(float)alpha
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    float width =  image.size.width/2 ;
    CGImageRef leftImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0.0f, 0.0f, width, image.size.height));
    UIImage *leftImage = [UIImage imageWithCGImage:leftImageRef];
    
    CGImageRef centerImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(width, 0.0f, 5.0f, image.size.height));
    UIImage *centerImage = [UIImage imageWithCGImage:centerImageRef];
    
    CGImageRef rightImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(width, 0.0f, width, image.size.height));
    UIImage *righttImage = [UIImage imageWithCGImage:rightImageRef];
    
    
    float num = image.size.height / rect.size.height;
    
    CGSize size = CGSizeMake(rect.size.width *num, image.size.height);
    UIGraphicsBeginImageContext(size);
    
    //- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
    [leftImage drawInRect:CGRectMake(0, 0,  width, size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    [centerImage drawInRect:CGRectMake(width, 0, size.width  - width * 2, size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    [righttImage drawInRect:CGRectMake(rect.size.width *num - width , 0, width , image.size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(leftImageRef);
    CGImageRelease(centerImageRef);
    CGImageRelease(rightImageRef);
    
    return resultingImage;
}


@end
