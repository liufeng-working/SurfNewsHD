//
//  MagazineInfoController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "MagazineInfoView.h"
#import "MagazineManager.h"
#import "PastPeriodicalCell.h"
#import "WebPeriodicalController.h"
#import "SubsChannelsManager.h"

/**
 SYZ -- 2014/08/11
 MagazineInfoController是展示期刊信息页的控制器,期刊Tab-添加期刊-期刊列表-MagazineInfoController
 主要包括的view有:
 MagazineInfoView,具体请参考MagazineInfoView类
 PastPeriodicalTitle,具体请参考PastPeriodicalTitle类
 UITableView,使用的cell是PastPeriodicalCell,具体请参考PastPeriodicalCell类
 */

//期刊信息控制器
@interface MagazineInfoController : PhoneSurfController <UITableViewDataSource, UITableViewDelegate, PastPeriodicalCellDelegate>
{
    UITableView *tableView;
    PastPeriodicalTitle *titleView;
    MagazineInfoView *infoView;                              //期刊信息视图
    
    NSMutableArray *groupArray;
    NSString *magazineIntroduction;                          //期刊介绍
    float introductionViewHeight;                            //期刊介绍视图的高度
    
    BOOL isNightMode;
}

@property(nonatomic, strong) MagazineInfo *magazine;

@end
