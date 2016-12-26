//
//  GetThreadContentRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"
#import "ThreadSummary.h"

@interface GetThreadContentRequest : SurfJsonRequestBase

@property(nonatomic) NSInteger newsId;      // 新闻ID
@property(nonatomic) NSInteger channelId;   // 频道id

// 区别热推及助手新闻，0为热推，1为助手
@property(nonatomic) NSInteger type;
@property(nonatomic) NSInteger specialId;   // 专题ID
@property(nonatomic,strong)NSString *referer;


- (id)initWithThread:(ThreadSummary*)thread;

@end
