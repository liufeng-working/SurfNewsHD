//
//  PhoneBelleGirlViewController.h
//  SurfNewsHD
//
//  Created by yujiuyin on 15/1/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "SNToolBar.h"
#import "SNPictureSummaryView.h"
#import "PhoneWeiboController.h"
#import "BelleGirlDesView.h"
#import "BelleGirlScrollView.h"

#define BELLEGIRLCHANNEL_ID 1024229


@class  ThreadSummary;



@interface PhoneBelleGirlViewController : PhoneWeiboController< UIGestureRecognizerDelegate, BelleGirlScrollViewDelegate>{
    BelleGirlScrollView *belleGirlscrollView;
}

@property (nonatomic, strong)ThreadSummary *thread;


@end
