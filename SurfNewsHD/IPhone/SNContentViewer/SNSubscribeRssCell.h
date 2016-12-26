//
//  SNSubscribeRssCell.h
//  SurfNewsHD
//
//  Created by XuXg on 15/9/6.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SurfTableViewCell.h"
#import "HotChannelsListResponse.h"

@interface SNSubscribeRssCell : SurfTableViewCell


-(void)loadDataWithHotChannelRec:(HotChannelRec*)rssData;
@end
