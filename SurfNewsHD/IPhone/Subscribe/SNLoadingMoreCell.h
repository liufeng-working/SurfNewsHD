//
//  SNLoadingMoreCell.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurfTableViewCell.h"

// 加载更多Cell
@interface SNLoadingMoreCell : SurfTableViewCell{
    UIActivityIndicatorView *_activityView; // 风火轮
}


@property(nonatomic,strong) NSString *title; // default @"正在加载...";
@property(nonatomic,strong) UIColor *titleColorForDay;
@property(nonatomic,strong) UIColor *titleColorForNight;
@property(nonatomic,strong) UIColor *bgColorForDay;
@property(nonatomic,strong) UIColor *bgColorForNight;
@property(nonatomic,strong) UIColor *selectBgColorForDay;
@property(nonatomic,strong) UIColor *selectBgColorForNight;

// 隐藏风火轮
-(void)hiddenActivityView:(BOOL)hidden;
@end
