//
//  SNCollectMode.m
//  SurfNewsHD
//
//  Created by XuXg on 15/10/28.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "SNCollectMode.h"
#import "MJExtension.h"


@implementation SNCollectSummary


// 转换成新闻详情
-(ThreadSummary*)converThreadSummary
{
    ThreadSummary *ts = [ThreadSummary new];
    ts.webView = [_openType integerValue];
    ts.threadId = [_newsId integerValue];
    ts.channelId = [_coid integerValue];
    ts.title = _title;
    ts.source = _source;
    ts.newsUrl = _newsUrl;
    ts.time = [_showTime doubleValue];
    return ts;
}
@end


@implementation SNCollectListResponse

/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)objectClassInArray
{
    return @{@"news" : @"SNCollectSummary"};
}
@end
