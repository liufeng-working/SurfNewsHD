//
//  GetThreadContentRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GetThreadContentRequest.h"
#import "NSString+Extensions.h"

@implementation GetThreadContentRequest
@synthesize newsId = __KEY_NAME_id;
@synthesize channelId = __KEY_NAME_coid;


- (id)initWithThread:(ThreadSummary*)thread
{
    if (self = [super init]) {
        self.newsId = thread.threadId;
        self.channelId = thread.channelId;
        
        
//      正文的type是新闻本身的属性类型，0是自有，1是rss，3是微精选
        _type = thread.ctype;
        if(2 == _type)
            _type = 0;
        
        // rss新闻没有ctype 字段。
        if (thread.threadM == SubChannelThread) {
            _type = 1;
        }
        
        
        // 2014.8.14 by xuxg T+推荐新闻
        if (thread.referer && ![thread.referer isEmptyOrBlank]) {
             _referer = thread.referer;
        }
    }
    
    return self;
}

@end
