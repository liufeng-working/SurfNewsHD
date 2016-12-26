//
//  EGORefreshTableFootView.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
    EGOOPullRefreshPulling = 0,
    EGOOPullRefreshNormal,
    EGOOPullRefreshLoading,
} EGOPullRefreshState;

@protocol EGORefreshTableFootViewDelegate;

@interface EGORefreshTableFootView : UIView
{
    EGOPullRefreshState _state;
    UILabel *_lastUpdatedLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImage;
    UIActivityIndicatorView *_activityView;
    UIImageView     *grayArrow;
}

@property (nonatomic, assign) id<EGORefreshTableFootViewDelegate>   tableFootDelegate;


- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;


@end


@protocol EGORefreshTableFootViewDelegate <NSObject>

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableFootView*)view;
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableFootView*)view;
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableFootView*)view;

@end