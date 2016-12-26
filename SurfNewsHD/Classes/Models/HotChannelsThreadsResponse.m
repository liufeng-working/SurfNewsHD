//
//  HotChannelsThreadsResponse.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotChannelsThreadsResponse.h"

@implementation HotChannelsThreadsResponse

@synthesize news = __ELE_TYPE_0_ThreadSummary;
@synthesize picNews = __ELE_TYPE_1_ThreadSummary;

@end


@implementation ImageGalleryThreadsResponse

//@synthesize news = __ELE_TYPE_0_ThreadSummary;
@synthesize news = __ELE_TYPE_0_PhotoCollection;
@end