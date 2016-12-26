//
//  HotBannerView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPageControl.h"

@interface HotBannerView : UIView<UIScrollViewDelegate>
{
    NSMutableArray *bannerDataPool;    // 图片缓存数组
    SNPageControl *pageCtrl;
    UIScrollView *scrollView;    
    NSTimer *timer;                     //定时器
    UILabel* titleView;
    BOOL _isVodel;
}

+ (NSInteger)hotBannerHeight;
- (void)reloadData:(NSArray *)picNews isVodel:(BOOL)isV;

@end


@interface MyScrollView : UIScrollView

@end
