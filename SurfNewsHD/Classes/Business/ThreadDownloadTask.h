//
//  ThreadDownloadTask.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-2.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HotChannel;
@class SubsChannel;
@class ThreadsFetchingResult;
@class PhotoCollectionChannel;

@interface SNThreadTaskBase : NSObject
@property(nonatomic,weak) id target;
@property(nonatomic) NSInteger pageNumber;          // 下载第几页面
@property(nonatomic,weak) id userData;              // 用户自定义数据
@property(nonatomic) BOOL finished;                 // 是否完成
@property(nonatomic) BOOL noChanges;                // 是否无新数据
@property(nonatomic,strong) NSArray* threadList;    // 帖子列表
@property(nonatomic,strong) void(^completionHandler)(ThreadsFetchingResult*);//下载完成后的回调，必须设置


- (NSURLRequest*)requestUrl;
@end



@interface HotChannelDownloadTask : SNThreadTaskBase
@property(nonatomic,strong) HotChannel *hotChannel;
-(id)initWithHotChannel:(HotChannel*)hotChannel;
@end


@interface SubsChannelDownloadTask : SNThreadTaskBase
@property(nonatomic,strong) SubsChannel *subsChannel;

-(id)initWithSubsChannel:(SubsChannel*)subsChannel;
@end


@interface ImageGalleryDownLoadTask : SNThreadTaskBase
@property(nonatomic,strong)PhotoCollectionChannel *pcc;
@end

// 获取订阅频道中的最新新闻
@interface LastNewsForSubsChannelsTask : SNThreadTaskBase{
    NSArray* _subsChannels;
}

-(id)initWithSubsChannels:(NSArray*)subs;
@end
