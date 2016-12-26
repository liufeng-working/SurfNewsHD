//
//  TouchView.h
//  TouchDemo
//
//  Created by Zer0 on 13-10-11.
//  Copyright (c) 2013年 Zer0. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderViewController.h"
#import "HotChannelsListResponse.h"
#import "HotChannelsManager.h"
@class TouchViewModel;
@class HotChannelsListResponse;

@interface TouchView : UIImageView
{
    CGPoint _point;
    CGPoint _point2;
    NSInteger _sign;
    
    UIImageView *_isnewView;    // 新增频道标记
    UIImageView *_selectedView; // 选择背景
    UIImageView *_editeImage;   // 编辑图片
    @public
    
    NSMutableArray * _array;
    NSMutableArray * _viewArr11;
    NSMutableArray * _viewArr22;
    
    

}
@property (nonatomic,retain) UILabel * label;
@property (nonatomic) BOOL editeState;  // 编辑状态
@property (nonatomic,retain) UILabel * moreChannelsLabel;
@property (nonatomic,retain) HotChannel * touchViewModel;

@property (nonatomic,assign) int myY;

-(void)changeEdit:(BOOL)flage;
@property(nonatomic,assign)BOOL isEditButton;//是否编辑

//新增频道，添加红点
- (void)setItemIsNew:(HotChannel *)hotCh;

//选中频道，特殊标识
- (void)selectChannelWithIndex:(int)index;

@end
