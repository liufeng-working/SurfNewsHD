//
//  ClassifyUpdateFlagRequest.h
//  SurfNewsHD
//
//  Created by XuXg on 14-10-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

@interface ClassifyUpdateFlagRequest : SurfJsonRequestBase

// 客户端请求携带则根据客户端请求查询多个，隔开
@property(nonatomic,strong)NSString* mids;      // 期刊ID


// 客户端请求携带则根据客户端请求查询多个，隔开
@property(nonatomic,strong)NSString *coids;     // rssID 订阅


@end

