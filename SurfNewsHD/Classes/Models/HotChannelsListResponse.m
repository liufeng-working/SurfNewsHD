//
//  HotChannelsListResponse.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotChannelsListResponse.h"
#import "SubsChannelsListResponse.h"


@implementation HotChannelBrowsed
@synthesize isBrowsed = _isBrowsed;


+(HotChannelBrowsed*)sharedInstance{
    static HotChannelBrowsed *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [HotChannelBrowsed new];
    });
    return instance;
}
@end

@implementation HotChannelRec
@synthesize recid = _KEY_NAME_recid;
@synthesize recimg = _KEY_NAME_recimg;
@synthesize recname = _KEY_NAME_recname;

-(SubsChannel*)buildSubsChannel
{
    SubsChannel *sc = [SubsChannel new];
    sc.channelId = _channelId;
    sc.name = _KEY_NAME_recname;
    sc.ImageUrl = _KEY_NAME_recimg;
    return sc;
}
@end


@implementation HotChannel

@synthesize listScrollOffsetY= __DO_NOT_SERIALIZE_OffSetY;


// 是否是热推频道
-(BOOL)isHotChannel
{
    if (_channelId == 4061 ||
        [_channelName isEqualToString:@"热推"]) {
        return YES;
    }
    return NO;
}

// 是否是订阅频道
-(BOOL)isSubschannel
{
    if([_channelName isEqualToString:@"订阅"])
        return YES;
    return NO;
}

// 是否是本地频道
-(BOOL)isLocalChannel
{
    if (_channelId == 0) {
        return YES;
    }
    return NO;
}

// 是否是财经频道
-(BOOL)isStockChannel
{
    if (_channelId == 4080 ||
        [_channelName isEqualToString:@"财经"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isBeautifulChannel
{
    if (_isBeauty == 1) {
        return YES;
    }
    return NO;
}

//是否是视频频道
-(BOOL)isVideoChannel
{
    if (_type == 4){
        return YES;
    }
    return NO;
}

// 是否是段子频道
- (BOOL)isJokeChannel {
    if (_isBeauty == 5) {
        return YES;
    }
    return NO;
}

@end

@implementation HotChannelsListResponse

@synthesize channelList = __ELE_TYPE_HotChannel;
@synthesize rec = __ELE_TYPE_HotChannelRec;
@end
