//
//  UIFloatingViewController.h
//  SurfNewsHD
//
//  Created by jsg on 14-10-15.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "ThreadsManager.h"

@interface UIFloatingView : UIView
{
    UILabel *m_alertLable;
}

- (void)setAlertText:(NSString*)str;
@end

@interface UIFloatingViewController : UIViewController
{
    UIImageView *imgBgView;
    UIFloatingView * m_floatingView;
    NSTimer *timer;
}

- (void)setAddedThreadsCount:(NSString*)str;
@end
