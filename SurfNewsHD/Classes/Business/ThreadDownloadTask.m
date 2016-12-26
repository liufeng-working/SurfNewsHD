//
//  ThreadDownloadTask.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-2.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ThreadDownloadTask.h"
#import "SurfRequestGenerator.h"
#import "HotChannelsListResponse.h"
#import "SubsChannelsListResponse.h"
#import "SubsChannelModelRequest.h"
#import "EzJsonParser.h"
#import "NSString+Extensions.h"
#import "PhotoCollectionData.h"

@implementation SNThreadTaskBase

- (NSURLRequest*)requestUrl{
    return nil;
}
@end






@implementation HotChannelDownloadTask

-(id)initWithHotChannel:(HotChannel*)hotChannel{
    if (self = [super init]) {
        _hotChannel = hotChannel;
    }
    return self;
}


- (NSURLRequest*)requestUrl{
    if (_hotChannel) {
        long cid = _hotChannel.channelId;
        
        return [SurfRequestGenerator getHotChannelsThreadsRequestWithChannelId:cid
                                                                     newsCount:20
                                                                          page:self.pageNumber];
        
    }
    return nil;
}


@end



@implementation SubsChannelDownloadTask

-(id)initWithSubsChannel:(SubsChannel*)subsChannel{
    if (self = [super init]) {
        _subsChannel = subsChannel;
    }
    return self;
}

- (NSURLRequest*)requestUrl{
    if (_subsChannel) {
        long cid = _subsChannel.channelId;
        return [SurfRequestGenerator getSubsChannelThreadsRequest:cid
                                                        newsCount:20
                                                             page:self.pageNumber];
    }
    return nil;
}

@end


@implementation ImageGalleryDownLoadTask
-(id)initWithSubsChannel:(PhotoCollectionChannel*)pcC{
    if (self = [super init]) {
        _pcc = pcC;
    }
    return self;
}

#define IMAGEGALLERYCOUNT     20   //张雨乐改
- (NSURLRequest*)requestUrl{
    if (_pcc) {
        long cid = _pcc.cid;
        return [SurfRequestGenerator getPhotoCollectionListThreadsRequestWithChannelId:cid newsCount:IMAGEGALLERYCOUNT page:1];
                }
    return nil;
}




@end

@implementation LastNewsForSubsChannelsTask

-(id)initWithSubsChannels:(NSArray*)subs{
    if (self = [super init]) {
        _subsChannels = subs;
    }
    return self;
}
- (NSURLRequest*)requestUrl{
    if (_subsChannels.count > 0) {
        
        // 创建请求数据结构
        NSMutableArray *lastNewsInfo = [NSMutableArray array];
        for (SubsChannel *sc in _subsChannels) {
            if ([sc isKindOfClass:[SubsChannel class]]) {
                SubsChannelLastNewInfo *info = [SubsChannelLastNewInfo new];
                info.cid = sc.channelId;        // 设置栏目ID
                info.maxTime = sc.threadsSummaryMaxTime; // 找到订阅频道中最大的新闻id
                [lastNewsInfo addObject:info];
            }
        }
        
        if (lastNewsInfo.count > 0) {
            UpdateSubsChannelsLastNewsRequest *requestData = [UpdateSubsChannelsLastNewsRequest new];
            requestData.scids = lastNewsInfo;
            NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:requestData];
            NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
            
            NSURL *url = [NSURL URLWithString:kUpdateSubsChannelsLastNews];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setTimeoutInterval:20];
            [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]]; // 设置数据
            return request;
        }
    }
    return nil;
}
@end