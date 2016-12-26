//
//  PastPeriodicalController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "PastPeriodicalCell.h"
#import "MagazineManager.h"
#import "GetMagazineSubsResponse.h"
#import "WebPeriodicalController.h"
#import "SubsChannelsManager.h"

/**
 SYZ -- 2014/08/11
 PastPeriodicalController往期期刊展示
 titleView显示“往期期刊”文本文字,具体参考PastPeriodicalTitle类
 periodicalTableView使用的cell是PastPeriodicalCell,具体参考PastPeriodicalCell类
 */
@interface PastPeriodicalController : PhoneSurfController <UITableViewDataSource, UITableViewDelegate,
PastPeriodicalCellDelegate>
{
    UITableView *periodicalTableView;
    PastPeriodicalTitle *titleView;
    NSMutableArray *groupArray;
    BOOL isNightMode;
}

@property(nonatomic, strong) MagazineSubsInfo *magazine;

@end
