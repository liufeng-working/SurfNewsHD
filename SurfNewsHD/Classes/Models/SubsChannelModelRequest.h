//
//  SubsChannelModelRequest.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//  注：因为订阅这快请求类相对比较小，反复建立也挺烦，想把相关的类都集合到这里。

#import <Foundation/Foundation.h>
#import "SurfJsonRequestBase.h"


#pragma mark 更新订阅频道的最新新闻
// 更新订阅频道的最新新闻
// 详情：冲浪快讯接口协议设计_20130603->18.1接口
@interface UpdateSubsChannelsLastNewsRequest : SurfJsonRequestBase
@property(nonatomic)NSArray *scids; // SubsChannelLastNewInfo 数组
@end


// 最新新闻信息
@interface SubsChannelLastNewInfo : NSObject
@property(nonatomic) long cid;          // 订阅栏目的id
@property(nonatomic) double maxTime;    // 订阅栏目中的最大新闻时间
@end


#pragma mark 其它请求