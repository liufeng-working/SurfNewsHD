//
//  SubsChannelModelResponse.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UpdateSubsChannelsLastNewsResponse : NSObject
@property(nonatomic)NSArray *item;  // UpdateSubsChannelInfo array
@end


@interface UpdateSubsChannelInfo : NSObject
@property(nonatomic) long cid;      // 订阅栏目的ID
@property(nonatomic) int hasN;      // 该栏目是否有更新（0是没有，1是有）
@property(nonatomic) NSArray *news; // (非必要参数，有nil存在) ,UpdateNewsInfo array

@end

/*
@interface UpdateNewsInfo : NSObject
@property(nonatomic) long news_id;  // 新闻id
@property(nonatomic) NSString* news_title;// 新闻标题
@end
*/