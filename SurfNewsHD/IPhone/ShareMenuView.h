//
//  ShareMenuView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-10-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ShareMenuCount  4 //修改这个数字一定要同时修改枚举类型MenuItemIndex

typedef NS_ENUM(NSInteger, ShareWeiboType)
{
    ItemWeixin = 1000,      //微信好友  注意:此处从1000开始
    ItemWeiXinFriendZone,     //微信朋友圈
    ItemSinaWeibo,          //新浪微博
    ItemSMS,                //短信
};

@interface ShareMenuItem : UIControl
{
    UIImageView *iconView;
    UILabel *nameLabel;
}

- (void)setImage:(UIImage*)image text:(NSString*)name;

@end

@protocol ShareMenuViewDelegate <NSObject>
@required
- (void)menuSelected:(ShareWeiboType)type;

@end

@interface ShareMenuView : UIView

@property(nonatomic, weak) id<ShareMenuViewDelegate> delegate;

@end
