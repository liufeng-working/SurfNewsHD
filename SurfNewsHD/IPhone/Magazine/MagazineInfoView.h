//
//  MagazineInfoView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "GetMagazineListResponse.h"
#import "MagazineManager.h"
#import "SubsChannelsManager.h"
#import "GetMagazineSubsResponse.h"

/**
 SYZ -- 2014/08/11
 MagazineInfoView期刊信息视图
 */
//期刊信息视图
@interface MagazineInfoView : UIView
{
    UIImageView *logoBg;                           //封面背景 SYZ -- 2014/08/11
    UIImageView *logoImageView;                    //封面图片
    UIImageView *starImageView;                    //评分图片
    UILabel *orderNumberLabel;                     //订阅数量
    UILabel *orderPricesLabel;                     //订阅价格
    UIButton *orderButton;                         //订阅按钮
}

@property(nonatomic, strong) MagazineInfo *magazine;

//加载期刊信息
- (void)loadMagazineInfo:(MagazineInfo *)ma;
//改变订阅按钮的状态
- (void)changeOrderButtonStatus;
- (void)applyTheme:(BOOL)isNight;

@end
