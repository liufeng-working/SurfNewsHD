//
//  OfflineDownloader.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-6-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HotChannel;
@class SubsChannel;
@class ImageDownloadingTask;
@class OfflineIssueInfo;
@class GTMHTTPFetcher;
@class OfflinesMagazines;
@class PhotoData;
@class PhotoCollectionChannel;

typedef enum
{
    IssueStatusUnknown = 0,
    IssueStatusDataReady,   //离线数据已经就绪
    IssueStatusDownloading, //正在下载中
    IssueStatusUnzipping,   //正在解压中
    IssueStatusPending,     //正在下载队列中
    IssueStatusStopped,     //已停止,且不处于下载队列中
    IssueStatusWillDiscard, //即将被删除，连同其对应的所有数据。zip包解压失败等情况，会导致该状态。
} OfflineIssueStatus;


@interface OfflineDownloadTask : NSObject
@end

@interface HotChannelOfflineDownloadTask : OfflineDownloadTask
@property(nonatomic,strong) HotChannel* hotChannel;
@end

@interface SubsChannelOfflineDownloadTask : OfflineDownloadTask
@property(nonatomic,strong) SubsChannel* subsChannel;
@end

@interface MagIssueOfflineDownloadTask : OfflineDownloadTask
@property(nonatomic) long magId;        //杂志id
@property(nonatomic) long issueId;  //该杂志的具体某一期期刊id
@property(nonatomic, strong) NSString* url;  //离线包下载url
@property(nonatomic, strong) NSString* issueName; //杂志名
@property(nonatomic) long expectedZipBytes; //预计zip包大小
@end

@interface ImageGalleryTask : OfflineDownloadTask
@property (nonatomic, strong) PhotoCollectionChannel *photoCChannel;
@end

@protocol OfflineDownloaderDelegate <NSObject>

@optional
//////////////////////for HotChannel//////////////////////
//某个热推频道即将开始下载
-(void) downloadingHotChannelWillBegin:(HotChannel*)hotChannel;
//某个热推频道的下载进度回调
//@completionCount: 该频道下已经完成下载的帖子数
//@ofTotal：该频道总共需要下载的帖子数
-(void) downloadingHotChannel:(HotChannel*)hotChannel
        withThreadsCompletion:(NSInteger)completionCount
                      ofTotal:(NSInteger)total;
//某个热推频道即将完成下载
-(void) downloadingHotChannelWillEnd:(HotChannel *)hotChannel;

//////////////////////for SubsChannel//////////////////////
//某个订阅频道即将开始下载
-(void) downloadingSubsChannelWillBegin:(SubsChannel*)subsChannel;
//某个订阅频道的下载进度回调
//@completionCount: 该频道下已经完成下载的帖子数
//@ofTotal：该频道总共需要下载的帖子数
-(void) downloadingSubsChannel:(SubsChannel*)subsChannel
         withThreadsCompletion:(NSInteger)completionCount
                       ofTotal:(NSInteger)total;
//某个订阅频道即将完成下载
-(void) downloadingSubsChannelWillEnd:(SubsChannel*)subsChannel;

//////////////////////for Magazine Issues//////////////////////
-(void) downloadingIssueStatusChanged:(OfflineIssueInfo*)issue;

//////////////////////for ImageGallery////////////////////////
-(void) downloadingPhotoCollectionChannelWillBegin:(PhotoCollectionChannel*)photoCollectionC;
//某个订阅频道的下载进度回调
//@completionCount: 该频道下已经完成下载的帖子数
//@ofTotal：该频道总共需要下载的帖子数
-(void) downloadingPhotoCollectionChannel:(PhotoCollectionChannel*)photoCollectionC
                    withThreadsCompletion:(NSInteger)completionCount
                                  ofTotal:(NSInteger)total;
//某个订阅频道即将完成下载
-(void) downloadingPhotoCollectionChannelWillEnd:(PhotoCollectionChannel*)photoCollectionC;

@end


@interface OfflineDownloader : NSObject
{
    __strong NSMutableArray* delegateArray_;
    
    //////////////for HotChannel and SubsChannel/////////////
    __strong NSArray* threadsArray_; //当前频道需要处理的所有帖子
    NSInteger currentThreadIdx_;          //指示threadsArray_中的当前索引
    NSInteger currentChannelSubTaskStage_;   //指示当前频道的子任务索引,see ChannelSubTaskStage in .m
    __strong ImageDownloadingTask* previewImageDownloadingTask_;//预览图片下载任务
    __strong NSArray* threadContentImagesInfoArray_;
    __strong NSMutableArray* contentImagesDownloadingTaskArray_;    //正文图片下载任务队列
    
    //////////////for mag issue tasks////////////
    __strong GTMHTTPFetcher* issueZipFetcher_;
    NSInteger issueZipStage;  //see MagIssueZipStage in .m
    
    __strong OfflineDownloadTask* currentDownloadingTask_;   //当前活动的下载任务
    __strong NSMutableArray* pendingTasksArray_; //队列中的任务列表
    __strong OfflinesMagazines* MagIssusInfo_;
    
    BOOL        isShowHotAnimotion;
}

+(OfflineDownloader*) sharedInstance;

//增加下载任务并立刻开始
-(BOOL) addDownloadTask:(OfflineDownloadTask*)task;

//移除某个期刊下载任务
-(void) removeIssueTaskWithMagId:(long)magId issueId:(long)issId;

//停止所有任务
-(void) stop;

//停止所有期刊任务
-(void) stopAllIssueTasks;

//用来检测是否有频道下载任务
-(BOOL) hasChannelTasksDownloadingOrPending;

//判断某个热推频道是否正在下载中/或队列中
-(BOOL) isHotChannelDownloadingOrPending:(HotChannel*)hc;

//判断某个订阅频道是否正在下载中/或队列中
-(BOOL) isSubsChannelDownloadingOrPending:(SubsChannel*)sc;

//判断某本期刊是否已经离线下载完成
-(BOOL) isIssueOfflineDataReady:(long)magId issId:(long)issueId;

//判断某本期刊是否有临时文件存在
//有临时文件存在并不意味着一定处于下载中/或队列中
-(BOOL) isIssueZipTmpFileExist:(long)magId issId:(long)issueId;

//判断某本期刊是否正在下载中/或队列中
-(BOOL) isIssueDownloadingOrPending:(long)magId issId:(long)issueId;

//根据MagId和IssueId获取对应的IssueInfo
//可能返回nil
-(OfflineIssueInfo*) getOfflineIssueInfoByMagId:(long)magId issId:(long)issueId;

//获取所有IssueInfo，此函数用于期刊离线下载管理界面
-(NSArray*) getAllOfflineIssuesInfo;

//清除某个期刊的所有相关离线数据
-(void) deleteDataForMagIssue:(OfflineIssueInfo*)issue;

//获取当前活动的下载任务
//返回nil表示当前无任务
-(OfflineDownloadTask*) currentDownloadingTask;

//队列中的任务数量
-(NSUInteger) pendingTasksCount;

//注册下载通知
//注意：@del会被retain
-(void) addEventDelegate:(id<OfflineDownloaderDelegate>)del;
//取消下载通知
-(void) removeEventDelegate:(id<OfflineDownloaderDelegate>)del;

@end
