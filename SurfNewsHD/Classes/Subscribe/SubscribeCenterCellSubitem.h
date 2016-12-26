//
//  SubscribeCenterCellSubitem.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubsChannelsListResponse.h"
#import "SubsChannelsManager.h"


@protocol SubsCellSubitemClickObserver <NSObject>
@required
-(void)cellSubitemClick:(SubsChannel *)subsChannel;// 打开SubsChannelView
@end


@interface SubscribeCenterCellSubitem : UIControl{
    SubsChannel *_subsChannel;
    UIImageView *_iconView;
    UILabel *_subsName;                     // 订阅名称
    CGRect _iconRect;
    UIButton *_subsButton;                  // 订阅或者退订按钮
    UIActivityIndicatorView *_loadingAIV;   //loading 指示
    BOOL _isClick;
    BOOL _subsState;        // 记录订阅状态，在其它界面修改订阅状态会得到一个通用的通知，用来避免重复加载subsButton的背景图片，
}
@property(nonatomic)BOOL isLoadedIcon;  //是否加载过图片
@property(nonatomic,strong)SubsChannel *subsChannel;
@property(nonatomic,weak) id<SubsCellSubitemClickObserver> subsCellSubitemClickDelegate;

+ (CGSize)suitableSize;

- (void)reloadData:(SubsChannel *)data;
- (void)setIcon:(UIImage *)img;
- (BOOL)checkSubsButtonState;   // 检查订阅按钮的状态，如何状态发生改变，Button状态也会改变
@end