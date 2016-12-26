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

@protocol RankingShareCtlDelegate <NSObject>
@required

- (void)shareMenuSelected:(ShareWeiboType)type;
- (void)dissmissViewCtl;
@end


@interface RankingShareCtl : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
        UILabel *m_title;
        UITableView * m_tableview;
        UIView *m_popview;
}

@property(nonatomic, weak) id<RankingShareCtlDelegate> delegate;
@end
