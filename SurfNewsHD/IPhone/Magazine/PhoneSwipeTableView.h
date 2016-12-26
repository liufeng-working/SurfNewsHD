//
//  YFJLeftSwipeDeleteTableView.h
//  YFJLeftSwipeDeleteTableView
//
//  Created by Yuichi Fujiki on 6/27/13.
//  Copyright (c) 2013 Yuichi Fujiki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetMagazineSubsResponse.h"
#import "MagazineManager.h"
#import "SubsChannelsManager.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"

@interface SetTopOrUnsubsView : UIView
{
    UIImageView *dividerImageView;
    UIButton *setTopButton;
    UIButton *cancleSubsButton;
}

- (void)applyTheme;

@property(nonatomic,weak) MagazineSubsInfo *magazine;

@end

// editingView操纵View
@interface MagazineOperateView : UIView
{
    UIView *_maskView;
}

//这里只是创建和操作这个View
@property(nonatomic,strong) SetTopOrUnsubsView *subsChannelEidtingView;

- (void)showOperateViewWithMagazine:(MagazineSubsInfo*)m;
- (void)hiddenOperateViewWithAnimate:(BOOL)animate;

@end

@interface PhoneSwipeTableView : UITableView <UIGestureRecognizerDelegate>

- (void)viewNightModeChanged:(BOOL)isNight;
- (void)setTableViewNoneEditing;

@end
