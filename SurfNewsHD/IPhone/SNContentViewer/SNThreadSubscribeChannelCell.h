//
//  SNThreadSubscribeChannelCell.h
//  SurfNewsHD
//
//  Created by XuXg on 15/9/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotChannelsListResponse.h"


@interface SNThreadSubscribeChannelCell : UITableViewCell



+(CGFloat)cellSizeWithFits;

-(void)loadDataWithHotChannelRec:(HotChannelRec*)rec;

// 设置订阅状态
-(void)setSubscribeState:(BOOL)isSub;

@end
