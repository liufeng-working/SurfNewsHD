//
//  RankingShareCtl.h
//  SurfNewsHD
//
//  Created by admin on 14-12-2.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "ShareMenuView.h"
#import "UIColor+extend.h"

@protocol RankingShareCtlDelegate <NSObject>
@required
- (void)shareMenuSelected:(ShareWeiboType)type;
@end


@interface ShareView_Ranking : UIView

@property(nonatomic,strong)NSString *title;
@property(nonatomic, weak) id<RankingShareCtlDelegate> delegate;


@end


@interface RankingShareCtl : UIViewController<UITableViewDelegate>
{
    UILabel *m_title;
    UIView *m_popview;
}

@end
