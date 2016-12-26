//
//  AddMagazineSubsController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "MagazineManager.h"
#import "MagazineInfoController.h"
#import "SNLoadingMoreCell.h"
#import "AddSubscribeView.h"
#import <AVFoundation/AVFoundation.h>

/**
 SYZ -- 2014/08/11
 AddMagazineSubsController添加期刊订阅
 tableView   使用的是AddSubscribeCell,具体请点击AddSubscribeCell;
 magazines   数据源
 page        分页页数
 loadingMore 是否要加载更多
 player      音源播放
 */
@interface AddMagazineSubsController : PhoneSurfController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, AddSubscribeCellDelegate>
{
    UITableView *tableView;
    NSMutableArray *magazines;
    NSUInteger page;
    BOOL isNightMode;
    BOOL loadingMore;
    AVAudioPlayer *player;
}

@end
