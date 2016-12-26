//
//  PhoneSinaWeiboUserFriendsController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "WeiboManager.h"
#import "PathUtil.h"
#import "ImageDownloader.h"

/**
 SYZ -- 2014/08/11
 新浪微博分享时可选择要@的好友
 新浪微博考虑到隐私等问题,所以现在不能完全获取关注的好友列表,只能获得一部分
 */
@interface SinaWeiboUserFriendCell : UITableViewCell
{
    UIImageView *selectedView;
    UIImageView *avatarView;
    UILabel *nameLabel;
}

@property(nonatomic, strong) SinaWeiboUserInfo *userInfo;

- (void)applyTheme;

@end

//选择要@时的cell
@interface SinaWeiboUserFriendSelectedCell : UITableViewCell
{
    UIImageView *avatarView;
}

@property(nonatomic, strong) SinaWeiboUserInfo *userInfo;

@end

@protocol PhoneSinaWeiboUserFriendsControllerDelegate;

@interface PhoneSinaWeiboUserFriendsController : PhoneSurfController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    UIView *toolBarView;
    UITableView *selectedTableView;
    UIButton *okButton;
    UIView *verticalLineView;
    
    NSMutableArray *friends;
    NSMutableArray *selectedFriends;
    NSInteger nextCursor;
    NSInteger total;
    BOOL isloading;
}

@property (nonatomic, weak) id<PhoneSinaWeiboUserFriendsControllerDelegate> delegate;

@end

@protocol PhoneSinaWeiboUserFriendsControllerDelegate <NSObject>

- (void)selectFriendsToShare:(NSArray*)array controller:(PhoneSinaWeiboUserFriendsController*)controller;

@end