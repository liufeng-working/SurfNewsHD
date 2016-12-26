//
//  SurfFlagsManager.h
//  SurfNewsHD
//
//  Created by XuXg on 14-10-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassifyUpdateFlagResponse.h"

// 新内容标记点
@interface SurfFlagsManager : NSObject


// 分类模块标记
@property(nonatomic,readonly)ClassifyUpdateFlag *classifyFlag;

+ (SurfFlagsManager*)sharedInstance;
+ (UIImage*)flagImage;


// 刷新标记点
-(void)refreshFlags;


#pragma -mark 新闻频道模块标记
// 检查新闻频道是否增加新的频道或删除频道
-(void)checkNewsChannels:(NSArray*)newsChannels;

// 新增加的新闻频道标记已读
-(void)markNewsChnannelAsRead:(HotChannel*)hc;

// 检查新闻频道是否是新增频道
-(BOOL)checkNewsChannelIsAddChannel:(HotChannel*)hc;

// 是否存在新增加的新闻频道
-(BOOL)isExistNewsChannelFlag;

@end
