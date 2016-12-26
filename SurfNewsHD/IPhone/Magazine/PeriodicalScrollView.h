//
//  PeriodicalScrollView.h
//  SurfNewsHD
//
//  Created by apple on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeriodicalWebView.h"
#import "PictureBox.h"
@class PeriodicalScrollView;
@protocol PeriodicalScrollViewDelegate
-(NSArray *)getThreadArr;
-(NSInteger)currentScrollPage;
-(void)reloadNewsScrollView;
-(void)pageMoveToLeft;
-(void)pageMoveToRight;
-(void)dismissModalViewController;
@end

@interface PeriodicalScrollView : UIView<UIScrollViewDelegate,UIWebViewDelegate,
PeriodicalWebViewDelegate,PictureBoxDelegate>
{
    UIScrollView *scrollView;
    NSInteger oldPage;
    PictureBox *pictureBox;
    
    // 隐藏tabBar参数
    CGPoint beginScrollPoint;
    BOOL isHiddenToolsBar;
}

@property(nonatomic) UIView *toolsBar;
@property(nonatomic,weak) id<PeriodicalScrollViewDelegate> scrollViewDelegate;
@property(nonatomic) UIScrollView *scrollView;
-(void)pageMoveToLeft:(BOOL)animated;
-(void)pageMoveToRight:(BOOL)animated;
-(PeriodicalWebView *)currentScrollWeb;
-(PeriodicalWebView *)leftScrollWeb;
-(PeriodicalWebView *)rightScrollWeb;
-(void)reloadScrollView;
@end
