//
//  WebDesPeriodicalController.h
//  SurfNewsHD
//
//  Created by apple on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeriodicalScrollView.h"
#import "PhoneSurfController.h"
#import "PhoneSettingBar.h"
#import "PhoneWeiboController.h"

//PhoneSurfController
// 期刊详情界面
@interface WebDesPeriodicalController : PhoneWeiboController <PeriodicalScrollViewDelegate,
    PhoneSettingBarDelegate>
{
    PeriodicalScrollView *scrollView;
    NSInteger currentIndex;
    PhoneSettingBar *settingBar;
    UIView *statusBarBgView;
    
    UILabel *indexLabel;
}

/**
 初始化
 适合期刊链接总数固定的场合使用
 NAArray 数据类型是PeriodicalLinkInfo
 */
-(id)initWithPeriodicalLinks:(NSArray*)links andActiveIndex:(NSInteger)idx;



@end
