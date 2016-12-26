//
//  HotChannelsThreadsResponse.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"
#import "ThreadSummary.h"

@interface HotChannelsThreadsResponse : SurfJsonResponseBase

@property NSInteger countPage;
@property NSArray *news;
@property NSArray *picNews;             // 只有在刷第一页列表的时候会返回picNews

@end


@interface ImageGalleryThreadsResponse : SurfJsonResponseBase
@property NSInteger countPage;
@property NSArray *news;
@end