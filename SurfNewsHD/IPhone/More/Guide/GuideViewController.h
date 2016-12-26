//
//  GuideViewController.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"

//PhoneSurfController

@protocol GuideViewControllerDelegate;

@interface GuideView : UIView<UIScrollViewDelegate>


@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) UIScrollView *pageScroll;
@property (nonatomic, strong) UIScrollView  *bgScrollView;
@property (nonatomic, strong) id<GuideViewControllerDelegate> guideDelegate;

@end


@protocol GuideViewControllerDelegate <NSObject>

- (void)finishLoadGuideView;

@end
