//
//  PhoneMagazineController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "PhoneMagazineCell.h"
#import "MagazineManager.h"
#import "PastPeriodicalController.h"
#import "AddMagazineSubsController.h"
#import "LoadingView.h"

//期刊展示控制器
@interface PhoneMagazineController : PhoneSurfController <UITableViewDataSource, UITableViewDelegate,
PhoneMagazineCellDelegate, SubsMagazineChangedObserver>
{
    UITableView *magazineTableView;
    LoadingView *topLoading;
    UIView *verticalLineView;
    
    UIButton *guideAddBtn;
    UIButton *addMoreButton;
    BOOL refreshUpdatePeriodical;
    
    ReloadMode reloadMode;
    NSInteger operateIndex;
}

@end
