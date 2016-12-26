 //
//  OfflineDownloader.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-6-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "OfflineDownloader.h"
#import "GTMHTTPFetcher.h"
#import "ImageDownloader.h"
#import "ThreadContentDownloader.h"
#import "ThreadContentResolver.h"
#import "ThreadsManager.h"
#import "HotChannelsListResponse.h"
#import "SubsChannelsListResponse.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "NSString+Extensions.h"
#import "XmlUtils.h"
#import "OfflineIssueInfo.h"
#import "EzJsonParser.h"
#import "ZipArchive.h"
#import "AppDelegate.h"
#import "DownLoadViewController.h"
#import "HotChannelsManager.h"
#import "PhotoCollectionManager.h"
#import "PhotoCollectionResponse.h"
#import "PhotoCollectionData.h"

//帖子下载任务的各阶段子任务
enum ChannelSubTaskStage
{
    ChannelSubTaskNone = 0,
    ChannelSubTaskGetThreads,              //获取帖子列表
    ChannelSubTaskGetThreadPreviewImage,   //获取预览图
    ChannelSubTaskGetThreadContent,        //获取正文
    ChannelSubTaskGetThreadContentImages   //获取正文中的图片
};

enum MagIssueZipStage
{
    MagIssueZipStageIdle = 0,
    MagIssueZipStageDownloading,
    MagIssueZipStageUnzipping
};

@implementation OfflineDownloadTask
@end

@implementation HotChannelOfflineDownloadTask
@end

@implementation SubsChannelOfflineDownloadTask
@end

@implementation MagIssueOfflineDownloadTask
@end

@implementation ImageGalleryTask
@end

@implementation OfflineDownloader

+(OfflineDownloader*) sharedInstance
{
    static OfflineDownloader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[OfflineDownloader alloc] init];
                      
                      //初始化成员变量
                      [sharedInstance cleanupCurrentTask];
                      
                      [sharedInstance loadMagIssuesInfoFromFile];
                  });
    
    return sharedInstance;
}

//从info.txt中载入离线包信息
-(void) loadMagIssuesInfoFromFile
{
    MagIssusInfo_ = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfOfflineMagazineInfo] encoding:NSUTF8StringEncoding error:nil] AsType:[OfflinesMagazines class]];
    if(!MagIssusInfo_)
    {
        MagIssusInfo_ = [OfflinesMagazines new];
        MagIssusInfo_.issues = [NSMutableArray new];
    }
    else
    {
        for (OfflineIssueInfo* issueInfo in MagIssusInfo_.issues)
        {
            issueInfo.issueStatus = IssueStatusStopped;
            
            if([self isIssueOfflineDataReady:issueInfo])
            {
                issueInfo.issueStatus = IssueStatusDataReady;
            }
            else
            {
                NSString* zipPath = [[PathUtil pathOfOfflineMagazine]stringByAppendingPathComponent:issueInfo.localFileName];
                if([FileUtil fileExists:zipPath])
                {
                    //zip 文件存在，认为其对应的数据文件是脏数据
                    //需要重新解压
                    
                    MagIssueOfflineDownloadTask* task = [MagIssueOfflineDownloadTask new];
                    task.magId = issueInfo.magId;
                    task.issueId = issueInfo.issId;
                    task.issueName = issueInfo.name;
                    
                    //静默方式启动
                    [self addDownloadTask:task bringUpUI:NO];
                }
                else
                {
                    NSString* tmpFilePath = [zipPath stringByAppendingString:@".tmp"];
                    issueInfo.downloadedBytes = (long)[FileUtil fileSizeAtPath:tmpFilePath];
                }
            }
        }
    }
}

//MagIssusInfo_发生更改后需要调用此函数
-(void) saveIssuesInfoToFile
{
    [[EzJsonParser serializeObjectWithUtf8Encoding:MagIssusInfo_] writeToFile:[PathUtil pathOfOfflineMagazineInfo] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void) addEventDelegate:(id<OfflineDownloaderDelegate>)del
{
    if(!delegateArray_)
        delegateArray_ = [NSMutableArray new];
    if(![delegateArray_ containsObject:del])
        [delegateArray_ addObject:del];
}

-(void) removeEventDelegate:(id<OfflineDownloaderDelegate>)del
{
    [delegateArray_ removeObject:del];
}

-(void) processNextTask
{
    [[DownLoadViewController sharedInstance] changeCloseBtState:YES];
    
    if([pendingTasksArray_ count])
    {
        currentDownloadingTask_ = pendingTasksArray_[0];
        
        [pendingTasksArray_ removeObjectAtIndex:0];
        
        if([currentDownloadingTask_ isKindOfClass:[HotChannelOfflineDownloadTask class]])
        {
            HotChannelOfflineDownloadTask* t = (HotChannelOfflineDownloadTask*)currentDownloadingTask_;
            [self processHotChannelTask:t];
        }
        else if([currentDownloadingTask_ isKindOfClass:[SubsChannelOfflineDownloadTask class]])
        {
            SubsChannelOfflineDownloadTask* t = (SubsChannelOfflineDownloadTask*)currentDownloadingTask_;
            [self processSubsChannelTask:t];
        }
        else if([currentDownloadingTask_ isKindOfClass:[MagIssueOfflineDownloadTask class]])
        {
            MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)currentDownloadingTask_;
            [self processMagIssueTask:t];
        }
        else if ([currentDownloadingTask_ isKindOfClass:[ImageGalleryTask class]])
        {
            ImageGalleryTask* t = (ImageGalleryTask*)currentDownloadingTask_;
            [self processImageGalleryTask:t];
        }
    }
    else
    {
        [[DownLoadViewController sharedInstance] didFinishDownLoad];
    }
}

-(void) processHotChannelTask:(HotChannelOfflineDownloadTask*)task
{
    //通知观察者
    [self notifyDownloadingHotChannelWillBegin:task.hotChannel];
    
    //获取帖子列表
    currentChannelSubTaskStage_ = ChannelSubTaskGetThreads;
    [[ThreadsManager sharedInstance] refreshHotChannel:self
                                            hotChannel:task.hotChannel
                                 withCompletionHandler:^(ThreadsFetchingResult *result)
     {
         if (result.succeeded)
         {
             threadsArray_ = result.threads;
             currentThreadIdx_ = 0;
             currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContent;
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                [self processNextThread];
                            });
             
         }
         else
         {
             //通知观察者
             [self notifyDownloadingHotChannelWillEnd:task.hotChannel];
             [self cleanupCurrentTask];
             
             //处理下一个任务
             [self processNextTask];
         }
     }];
}

- (void)processImageGalleryTask:(ImageGalleryTask *)task
{
    [self notifyDownloadingPhotoCollectionChannelWillBegin:task.photoCChannel];
    currentChannelSubTaskStage_ = ChannelSubTaskGetThreads;
    [[PhotoCollectionManager sharedInstance] refreshPhotoCollectionList:task.photoCChannel withCompletionHandler:^(ThreadsFetchingResult *result){
        if(result.succeeded)
        {
            //获取帖子列表成功
            //开始逐项处理各帖子
            threadsArray_ = result.threads;
            currentThreadIdx_ = 0;
            currentChannelSubTaskStage_ = ChannelSubTaskGetThreadPreviewImage;
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               [self processNextThread];
                           });
        }
        else
        {
            //获取帖子列表失败
            
            //通知观察者
            [self notifyDownloadingPhotoCollectionChannelWillEnd:task.photoCChannel];
            //清理资源
            [self cleanupCurrentTask];
            
            //处理下一个任务
            [self processNextTask];
        }

    }];
   
}

-(void) processSubsChannelTask:(SubsChannelOfflineDownloadTask*)task
{
    //通知观察者
    [self notifyDownloadingSubsChannelWillBegin:task.subsChannel];
    
    //获取帖子列表
    currentChannelSubTaskStage_ = ChannelSubTaskGetThreads;
    ThreadsManager* tm = [ThreadsManager sharedInstance];
    [tm refreshSubsChannel:self subsChannel:task.subsChannel withCompletionHandler:^(ThreadsFetchingResult* result)
     {
         if(result.succeeded)
         {
             //获取帖子列表成功
             //开始逐项处理各帖子
             threadsArray_ = result.threads;
             currentThreadIdx_ = 0;
             currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContent;
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                [self processNextThread];
                            });
         }
         else
         {
             //获取帖子列表失败
             
             //通知观察者
             [self notifyDownloadingSubsChannelWillEnd:task.subsChannel];
             //清理资源
             [self cleanupCurrentTask];
             
             //处理下一个任务
             [self processNextTask];
         }
     }];
}

-(void) processMagIssueTask:(MagIssueOfflineDownloadTask *)task
{
    if(issueZipStage != MagIssueZipStageIdle)
        return;
    
    //防止离线数据已经就绪的期刊重复下载
    if([self isIssueOfflineDataReady:task.magId issId:task.issueId])
        return;
    
    //判断zip包是否已经就绪
    OfflineIssueInfo* info = [self getMagIssueInfo:task];
    if(info)
    {
        NSString* zipPath = [[PathUtil pathOfOfflineMagazine] stringByAppendingPathComponent:info.localFileName];
        long zipSize = (long)[FileUtil fileSizeAtPath:zipPath];
        if(zipSize == info.zipBytes && zipSize != 0)
        {
            //zip包已经存在，且大小无误，则直接跳到解压阶段
            issueZipStage = MagIssueZipStageUnzipping;
        }
        else
        {
            //zip包不存在或者大小有误，认为该zip包无效
            [FileUtil deleteFileAtPath:zipPath];
            issueZipStage = MagIssueZipStageDownloading;
        }
    }
    else
    {
        //新增issueinfo
        info = [OfflineIssueInfo new];
        info.magId = task.magId;
        info.issId = task.issueId;
        info.name = task.issueName;
        info.zipBytes = task.expectedZipBytes;
        info.zipUrl = task.url;
        info.localFileName = [task.url lastPathComponent];
        
        //防止url换成非.zip结尾的形式
        if(![info.localFileName hasSuffixCaseInsensitive:@".zip"])
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddhhmmss"];
            info.localFileName = [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".zip"];
        }
        
        [MagIssusInfo_.issues addObject:info];
        [self saveIssuesInfoToFile];
        issueZipStage = MagIssueZipStageDownloading;
    }
    
    if(issueZipStage == MagIssueZipStageDownloading)
    {
        [self downloadMagIssueZip:task];
    }
    else if(issueZipStage == MagIssueZipStageUnzipping)
    {
        //通知解压缩进度
        info.issueStatus = IssueStatusUnzipping;
        [self notifyDownloadingMagIssueStatusChanged:info];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           BOOL succeeded = [self handleMagIssueZipReady:task];
                           
                           //通知解压缩进度
                           dispatch_sync(dispatch_get_main_queue(),^
                                         {
                                             if(succeeded)
                                             {
                                                 info.issueStatus = IssueStatusDataReady;
                                                 [self notifyDownloadingMagIssueStatusChanged:info];
                                                 [self notifyDownloadingMagIssueStatusEnd:info];
                                                 
                                                 [self cleanupCurrentTask];
                                                 [self processNextTask];
                                             }
                                             else
                                             {
                                                 info.issueStatus = IssueStatusWillDiscard;
                                                 [self notifyDownloadingMagIssueStatusChanged:info];
                                                 [self notifyDownloadingMagIssueStatusEnd:info];
                                                 
                                                 [self cleanupCurrentTask];
                                                 [self processNextTask];
                                                 
                                                 //删除info以及对应的数据
                                                 [self deleteDataForMagIssue:info];
                                             }
                                         });
                       });
    }
}


-(void) downloadMagIssueZip:(MagIssueOfflineDownloadTask*)task
{
    if(issueZipStage != MagIssueZipStageDownloading)
        return;
    
    OfflineIssueInfo* info = [self getMagIssueInfo:task];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[info.zipUrl completeUrl]]];
    
    NSString* tmpFilePath = [[PathUtil pathOfOfflineMagazine] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp",info.localFileName]];
    
    if([FileUtil fileExists:tmpFilePath])
    {
        //临时文件已经存在
        
        //设置http Range字段
        NSString *range = [NSString stringWithFormat:@"bytes=%ld-",(long)[FileUtil fileSizeAtPath:tmpFilePath]];
        [request addValue:range forHTTPHeaderField:@"Range"];
    }
    else
    {
        //创建临时文件
        [FileUtil ensureSuperPathExists:tmpFilePath];
        [[NSFileManager defaultManager] createFileAtPath:tmpFilePath contents:nil attributes:nil];
    }
    
    //以文件直接下载方式设置gtm
    issueZipFetcher_ = [GTMHTTPFetcher fetcherWithRequest:request];
    NSFileHandle* handle = [NSFileHandle fileHandleForUpdatingAtPath:tmpFilePath];
    [handle seekToEndOfFile];
    issueZipFetcher_.downloadFileHandle = handle;
    
    info.issueStatus = IssueStatusDownloading;
    [self notifyDownloadingMagIssueStatusChanged:info];
    
    __block OfflineDownloader* me = self;
    issueZipFetcher_.receivedDataBlock = ^(NSData* dataRecvedSofar)
    {
        NSHTTPURLResponse* resp = (NSHTTPURLResponse*)(me->issueZipFetcher_.response);
        
        //第一次下载时更新总大小
        //区分http 200是为了防止http 206的情况
        if(resp.statusCode == 200 && me->issueZipFetcher_.response.expectedContentLength != info.zipBytes)
        {
            info.zipBytes = (long)me->issueZipFetcher_.response.expectedContentLength;
            [me saveIssuesInfoToFile];
        }
        
        if(info.zipBytes)
        {
            info.issueStatus = IssueStatusDownloading;
            info.downloadedBytes = (long)me->issueZipFetcher_.downloadFileHandle.offsetInFile;
            [me notifyDownloadingMagIssueStatusChanged:info];
        }
        
    };
    
    [issueZipFetcher_ beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         [[NSURLCache sharedURLCache] removeAllCachedResponses];
         [[NSURLCache sharedURLCache] setDiskCapacity:0];
         [[NSURLCache sharedURLCache] setMemoryCapacity:0];
         
         if(error)
         {
             //zip.tmp下载失败
             info.issueStatus = IssueStatusStopped;
             [self notifyDownloadingMagIssueStatusChanged:info];
             
             [self cleanupCurrentTask];
             [self processNextTask];
         }
         else
         {
             //zip.tmp下载完成
             
             //将zip.tmp重命名成.zip
             NSString* zipPath = [[PathUtil pathOfOfflineMagazine] stringByAppendingPathComponent:info.localFileName];
             [FileUtil moveFileAtPath:tmpFilePath toPath:zipPath];
             
             //通知解压缩进度
             info.issueStatus = IssueStatusUnzipping;
             [self notifyDownloadingMagIssueStatusChanged:info];
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                            {
                                issueZipStage = MagIssueZipStageUnzipping;
                                BOOL succeeded = [self handleMagIssueZipReady:task];
                                
                                //通知解压缩进度
                                dispatch_sync(dispatch_get_main_queue(),^
                                              {
                                                  if(succeeded)
                                                  {
                                                      info.issueStatus = IssueStatusDataReady;
                                                      [self notifyDownloadingMagIssueStatusChanged:info];
                                                      [self notifyDownloadingMagIssueStatusEnd:info];
                                                      
                                                      [self cleanupCurrentTask];
                                                      [self processNextTask];
                                                  }
                                                  else
                                                  {
                                                      info.issueStatus = IssueStatusWillDiscard;
                                                      [self notifyDownloadingMagIssueStatusChanged:info];
                                                      [self notifyDownloadingMagIssueStatusEnd:info];
                                                      
                                                      [self cleanupCurrentTask];
                                                      [self processNextTask];
                                                      
                                                      //删除info以及对应的数据
                                                      [self deleteDataForMagIssue:info];
                                                  }
                                              });
                            });
             
         }
     }];
}

-(BOOL) handleMagIssueZipReady:(MagIssueOfflineDownloadTask*)task
{
    do
    {
        if(issueZipStage != MagIssueZipStageUnzipping)
            break;
        
        //解压缩
        OfflineIssueInfo* info = [self getMagIssueInfo:task];
        if(!info)
            break;
        
        ZipArchive* zip = [ZipArchive new];
        NSString* zipPath = [[PathUtil pathOfOfflineMagazine]stringByAppendingPathComponent:info.localFileName];
        if(![zip UnzipOpenFile:zipPath])
            break;
        
        NSString* unzipDir = [PathUtil pathOfOfflineDataForIssue:info];
        [FileUtil ensureDirExists:unzipDir];
        
        BOOL succeeded = [zip UnzipFileTo:unzipDir overWrite:YES];
        [zip UnzipCloseFile];
        
        //删除zip文件
        [FileUtil deleteFileAtPath:zipPath];
        
        if(!succeeded)
            break;
        
        //TODO
        //删除该期刊原先的缓存文件
        NSString *magazinePath = [[PathUtil rootPathOfMagazines] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", info.magId]];
        NSString *issuePath = [magazinePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", info.issId]];
        NSArray *array = [NSArray arrayWithObjects:@"info.txt", @"logo.img", nil];
        [FileUtil deleteContentsOfDir:issuePath withoutFiles:array];
        
        return YES;
        
    } while (0);
    
    return NO;
}

//仅适用于热推和订阅任务
-(void) processNextThread
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    
    if(currentThreadIdx_ >= [threadsArray_ count])
    {
        //当前任务(热推任务或者订阅任务)的所有帖子都已经处理完毕
        //通知观察者
        if([currentDownloadingTask_ isKindOfClass:[HotChannelOfflineDownloadTask class]])
        {
            HotChannelOfflineDownloadTask* t = (HotChannelOfflineDownloadTask*)currentDownloadingTask_;
            [self notifyDownloadingHotChannelWillEnd:t.hotChannel];
        }
        else if([currentDownloadingTask_ isKindOfClass:[SubsChannelOfflineDownloadTask class]])
        {
            SubsChannelOfflineDownloadTask* t = (SubsChannelOfflineDownloadTask*)currentDownloadingTask_;
            [self notifyDownloadingSubsChannelWillEnd:t.subsChannel];
        }
        else if([currentDownloadingTask_ isKindOfClass:[MagIssueOfflineDownloadTask class]])
        {
            //MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)currentDownloadingTask_;
            
        }
        else if ([currentDownloadingTask_ isKindOfClass:[ImageGalleryTask class]])
        {
            //            ImageGalleryTask* t = (ImageGalleryTask*)currentDownloadingTask_;
            
        }
        
        [self processNextTask];
    }
    else
    {
        [self processNextStageInThread];
    }
}

//仅适用于热推和订阅任务
-(void) processNextStageInThread
{
    ThreadSummary* thread=nil;
    PhotoCollection*pcT=nil;
    id ttt=[threadsArray_ objectAtIndex:currentThreadIdx_];
    if ([ttt isKindOfClass:[ThreadSummary class]]) {
        thread=ttt;
    }
    else{
        pcT=ttt;
        NSLog(@"pct.id: %ld", pcT.pcId);
    }
    switch (currentChannelSubTaskStage_)
    {
        case ChannelSubTaskGetThreadPreviewImage:
        {
            //获取帖子预览图
            if (thread) {
                if(thread.imgUrl && ![thread.imgUrl isEmptyOrBlank]
                   && ![FileUtil fileExists:[PathUtil pathOfThreadLogo:thread]])
                {
                    //有预览图，且尚未下载
                    __block OfflineDownloader* me = self;
                    ImageDownloader* imgDownloader = [ImageDownloader sharedInstance];
                    previewImageDownloadingTask_ = [ImageDownloadingTask new];
                    previewImageDownloadingTask_.targetFilePath = [PathUtil pathOfThreadLogo:thread];
                    previewImageDownloadingTask_.imageUrl = [thread.imgUrl completeUrl];
                    previewImageDownloadingTask_.completionHandler = ^(BOOL succeeded,ImageDownloadingTask* task)
                    {
                        //不管有没有下载成功，接着都下载正文
                        me->currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContent;
                        dispatch_async(dispatch_get_main_queue(), ^(void)
                                       {
                                           [me processNextStageInThread];
                                       });
                    };
                    [imgDownloader download:previewImageDownloadingTask_];
                }
                else
                {
                    //无须下载预览图,直接下载正文
                    previewImageDownloadingTask_ = nil;
                    currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContent;
                    dispatch_async(dispatch_get_main_queue(), ^(void)
                                   {
                                       [self processNextStageInThread];
                                   });
                }

            }
            else{//图集预览图        pathOfPhotoCollectionIcon
                NSString *iconPath = [PathUtil pathOfPhotoCollectionIcon:pcT];
                BOOL b=[FileUtil fileExists:iconPath];
                if (!b && pcT.imgUrl) {
                    __block OfflineDownloader* me = self;
                    ImageDownloadingTask *task = [ImageDownloadingTask new];
                    task.imageUrl = pcT.imgUrl;
                    task.targetFilePath = iconPath;
                    task.userData = pcT;
                    task.completionHandler = ^(BOOL succeeded,ImageDownloadingTask* t){
                        me->currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContent;
                        dispatch_async(dispatch_get_main_queue(), ^(void)
                                       {
                                           [me processNextStageInThread];
                                       });
                    };
                    [[ImageDownloader sharedInstance] download:task];
                }
                else
                {
                    previewImageDownloadingTask_ = nil;
                    currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContent;
                    dispatch_async(dispatch_get_main_queue(), ^(void)
                                   {
                                       [self processNextStageInThread];
                                   });
                }

            }
            
            break;
        }
            
        case ChannelSubTaskGetThreadContent:
        {
            //获取帖子正文
            if (thread){
                if(![FileUtil fileExists:[PathUtil pathOfThreadContent:thread]])
                {
                    //帖子正文不存在，需要下载
                    ThreadContentDownloader* contentDownloader = [ThreadContentDownloader sharedInstance];
                    [contentDownloader download:thread isCollect:NO withCompletionHandler:^(BOOL succeeded,NSString* content,ThreadSummary* trd)
                     {
                         if(succeeded)
                         {
                             //获取帖子正文成功
                             //接着获取帖子正文各图片
                             threadContentImagesInfoArray_ = [ThreadContentResolver extractImgNodesFromContent:[XmlUtils contentOfFirstNodeNamed:@"content" inXml:content] OfThread:trd];
                             currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContentImages;
                             dispatch_async(dispatch_get_main_queue(), ^(void)
                                            {
                                                [self processNextStageInThread];
                                            });
                         }
                         else
                         {
                             //获取帖子正文失败
                             //立刻处理下一个帖子
                             [self notifyCurrentChannelProcessingProgress];
                             threadContentImagesInfoArray_ = nil;
                             currentThreadIdx_++;
                             currentChannelSubTaskStage_ = ChannelSubTaskGetThreadPreviewImage;
                             dispatch_async(dispatch_get_main_queue(), ^(void)
                                            {
                                                [self processNextThread];
                                            });
                         }
                     }];
                }
                else
                {
                    //正文已经存在
                    //获取正文各图片
                    NSString *content = [NSString stringWithContentsOfFile:[PathUtil pathOfThreadContent:thread]
                                                                  encoding:NSUTF8StringEncoding
                                                                     error:nil];
                    threadContentImagesInfoArray_ = [ThreadContentResolver extractImgNodesFromContent:[XmlUtils contentOfFirstNodeNamed:@"content" inXml:content] OfThread:thread];
                    currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContentImages;
                    dispatch_async(dispatch_get_main_queue(), ^(void)
                                   {
                                       [self processNextStageInThread];
                                   });
                }

            }
            else{//图集正文
                if(![FileUtil fileExists:[PathUtil pathOfPhotoCollectionContentInfo:pcT]]){
                    [[PhotoCollectionManager sharedInstance] requestPhotoCollectionContent:pcT withCompletionHandler:^(ThreadsFetchingResult *result)
                     {
                         threadContentImagesInfoArray_=result.threads;
                         currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContentImages;
                         dispatch_async(dispatch_get_main_queue(), ^(void)
                                        {
                                            [self processNextStageInThread];
                                        });
                         
                         
                     }];
                }
                else{
                    PhotoCollectionContentResponse *resp;
                    NSString *contentPath = [PathUtil pathOfPhotoCollectionContentInfo:pcT];
                    NSString *fileContent = [NSString stringWithContentsOfFile:contentPath encoding:NSUTF8StringEncoding error:nil];
                    resp = [EzJsonParser deserializeFromJson:fileContent AsType:[PhotoCollectionContentResponse class]];
                    if (resp.item.count == 0) {
                        
                    }
                    else{
                        threadContentImagesInfoArray_=resp.item;
                    }
                    
                    currentChannelSubTaskStage_ = ChannelSubTaskGetThreadContentImages;
                    dispatch_async(dispatch_get_main_queue(), ^(void)
                                   {
                                       [self processNextStageInThread];
                                   });
                }
            }
            
            break;
        }
            
        case ChannelSubTaskGetThreadContentImages:
        {
            //获取帖子正文图片
            
            /* --------------并发下载图片实现------------*/
            if (thread) {
                NSInteger imgsDownloadingCount = 0;
                for (ThreadContentImageInfoV2* info in threadContentImagesInfoArray_)
                {
                    if(!info.isLocalImageReady)
                    {
                        imgsDownloadingCount ++;
                        
                        //下载图片
                        __block OfflineDownloader* me = self;
                        ImageDownloadingTask* task = [ImageDownloadingTask new];
                        task.targetFilePath = info.expectedLocalPath;
                        task.imageUrl = info.imageUrl;
                        task.completionHandler = ^(BOOL succeeded,ImageDownloadingTask* task)
                        {
                            [me->contentImagesDownloadingTaskArray_ removeObject:task];
                            if([me->contentImagesDownloadingTaskArray_ count] == 0)
                            {
                                //图片全部下载完毕
                                //处理下一个帖子
                                [me notifyCurrentChannelProcessingProgress];
                                me->threadContentImagesInfoArray_ = nil;
                                me->currentThreadIdx_++;
                                me->currentChannelSubTaskStage_ = ChannelSubTaskGetThreadPreviewImage;
                                dispatch_async(dispatch_get_main_queue(), ^(void)
                                               {
                                                   [me processNextThread];
                                               });
                            }
                        };
                        if(!contentImagesDownloadingTaskArray_)
                            contentImagesDownloadingTaskArray_ = [NSMutableArray new];
                        [contentImagesDownloadingTaskArray_ addObject:task];
                        [[ImageDownloader sharedInstance] download:task];
                    }
                }
                if(imgsDownloadingCount == 0)
                {
                    //所有帖子正文图片都已经处理完毕
                    //处理下一个帖子
                    [self notifyCurrentChannelProcessingProgress];
                    threadContentImagesInfoArray_ = nil;
                    currentThreadIdx_++;
                    currentChannelSubTaskStage_ = ChannelSubTaskGetThreadPreviewImage;
                    dispatch_async(dispatch_get_main_queue(), ^(void)
                                   {
                                       [self processNextThread];
                                   });
                }
            }
            else{//图集大图
                NSInteger imgsDownloadingCount = 0;
                for (PhotoData* info in threadContentImagesInfoArray_)
                {
                    if(!info.isCacheData)
                    {
                        imgsDownloadingCount ++;
                        
                        //下载图片
                        NSString *imgPath = [PathUtil pathOfPhotoDataImage:info];
                        __block OfflineDownloader* me = self;
                        ImageDownloadingTask* task = [ImageDownloadingTask new];
                        task.targetFilePath = imgPath;
                        [task setUserData:info];
                        task.imageUrl = info.img_path;
                        task.completionHandler = ^(BOOL succeeded,ImageDownloadingTask* task)
                        {
                            [me->contentImagesDownloadingTaskArray_ removeObject:task];
                            if([me->contentImagesDownloadingTaskArray_ count] == 0)
                            {
                                //图片全部下载完毕
                                //处理下一个帖子
                                [me notifyCurrentChannelProcessingProgress];
                                me->threadContentImagesInfoArray_ = nil;
                                me->currentThreadIdx_++;
                                me->currentChannelSubTaskStage_ = ChannelSubTaskGetThreadPreviewImage;
                                dispatch_async(dispatch_get_main_queue(), ^(void)
                                               {
                                                   [me processNextThread];
                                               });
                            }
                        };
                        if(!contentImagesDownloadingTaskArray_)
                            contentImagesDownloadingTaskArray_ = [NSMutableArray new];
                        [contentImagesDownloadingTaskArray_ addObject:task];
                        [[ImageDownloader sharedInstance] download:task];
                    }
                }
                if(imgsDownloadingCount == 0)
                {
                    [self notifyCurrentChannelProcessingProgress];
                    threadContentImagesInfoArray_ = nil;
                    currentThreadIdx_++;
                    currentChannelSubTaskStage_ = ChannelSubTaskGetThreadPreviewImage;
                    dispatch_async(dispatch_get_main_queue(), ^(void)
                                   {
                                       [self processNextThread];
                                   });
                }
                
            }
            break;
        }
        default:
            break;
    }
}

-(void) cleanupCurrentTask
{
    threadsArray_ = nil;
    currentThreadIdx_ = -1;
    previewImageDownloadingTask_ = nil;
    threadContentImagesInfoArray_ = nil;
    contentImagesDownloadingTaskArray_ = nil;
    currentChannelSubTaskStage_ = ChannelSubTaskNone;
    
    issueZipFetcher_ = nil;
    issueZipStage = MagIssueZipStageIdle;
    currentDownloadingTask_ = nil;
    
    isShowHotAnimotion = NO;
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
}

-(void) notifyDownloadingHotChannelWillBegin:(HotChannel*)hc
{
    DJLog(@"downloadingHotChannelWillBegin:%@",@(hc.channelId));
    
    SEL sel = @selector(downloadingHotChannelWillBegin:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingHotChannelWillBegin:hc];
    }
    
    [[DownLoadViewController sharedInstance] singleThreadTaskBeginDownLoad:hc.channelName];
}

-(void) notifyDownloadingHotChannelWillEnd:(HotChannel*)hc
{
    DJLog(@"downloadingHotChannelWillEnd:%@",@(hc.channelId));
    SEL sel = @selector(downloadingHotChannelWillEnd:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingHotChannelWillEnd:hc];
    }
    
    [[DownLoadViewController sharedInstance] singleThreadTaskEndDownLoad:hc.channelName];
}

-(void) notifyDownloadingSubsChannelWillBegin:(SubsChannel*)sc
{
    NSLog(@"downloadingSubsChannelWillBegin:%ld",sc.channelId);
    SEL sel = @selector(downloadingSubsChannelWillBegin:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingSubsChannelWillBegin:sc];
    }
    
    [[DownLoadViewController sharedInstance] singleThreadTaskBeginDownLoad:sc.name];
}

-(void) notifyDownloadingSubsChannelWillEnd:(SubsChannel*)sc
{
    NSLog(@"downloadingSubsChannelWillEnd:%ld",sc.channelId);
    SEL sel = @selector(downloadingSubsChannelWillEnd:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingSubsChannelWillEnd:sc];
    }
    
    [[DownLoadViewController sharedInstance] singleThreadTaskEndDownLoad:sc.name];
}

-(void) notifyDownloadingPhotoCollectionChannelWillBegin:(PhotoCollectionChannel*)pc
{
    NSLog(@"notifyDownloadingPhotoCollectionChannelWillBegin:   %ld",pc.cid);
    SEL sel = @selector(downloadingPhotoCollectionChannelWillBegin:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingPhotoCollectionChannelWillBegin:pc];
    }
    
    [[DownLoadViewController sharedInstance] singleThreadTaskBeginDownLoad:pc.name];
}

-(void) notifyDownloadingPhotoCollectionChannelWillEnd:(PhotoCollectionChannel*)pc
{
    NSLog(@"notifyDownloadingPhotoCollectionChannelWillEnd:   %ld",pc.cid);
    SEL sel = @selector(downloadingPhotoCollectionChannelWillEnd:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingPhotoCollectionChannelWillEnd:pc];
    }
    
    [[DownLoadViewController sharedInstance] singleThreadTaskEndDownLoad:pc.name];
}

-(void) notifyDownloadingMagIssueStatusChanged:(OfflineIssueInfo*)issue
{
    NSLog(@"downloadingMagIssueStatusChanged:%@",issue.name);
    SEL sel = @selector(downloadingIssueStatusChanged:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingIssueStatusChanged:issue];
    }
    
    //TODO
    NSLog(@"zipBytes: %ld", issue.zipBytes);
    NSLog(@"downloadedBytes: %ld", issue.downloadedBytes);
    float num = 0;
    if (issue.zipBytes > 0) {
        num = (issue.downloadedBytes * 1.0) / (issue.zipBytes * 1.0);
    }
    NSLog(@"num: %f", num);
    if(currentDownloadingTask_ && [currentDownloadingTask_ isKindOfClass:[MagIssueOfflineDownloadTask class]])
    {
        MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)currentDownloadingTask_;
        if([self getMagIssueInfo:t] == issue)
        {
            [[DownLoadViewController sharedInstance] singleMagazineTaskDownLoad:issue.name andPercent:num];
        }
    }
}

-(void) notifyDownloadingMagIssueStatusEnd:(OfflineIssueInfo*)issue
{
    [[DownLoadViewController sharedInstance] singleMagazineTaskEndDownLoad:issue.name];
}

-(void) notifyDownloadingHotChannel:(HotChannel*)hc
              withThreadsCompletion:(NSUInteger)completionCount
                            ofTotal:(NSInteger)total
{
    SEL sel = @selector(downloadingHotChannel:withThreadsCompletion:ofTotal:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingHotChannel:hc withThreadsCompletion:completionCount ofTotal:total];
    }
    
    [[DownLoadViewController sharedInstance] singleThreadTaskDownLoad:hc.channelName andCount:completionCount ofTotal:total];
}

-(void) notifyDownloadingSubsChannel:(SubsChannel*)sc
               withThreadsCompletion:(NSInteger)completionCount
                             ofTotal:(NSInteger)total
{
    SEL sel = @selector(downloadingSubsChannel:withThreadsCompletion:ofTotal:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingSubsChannel:sc
                  withThreadsCompletion:completionCount
                                ofTotal:total];
    }
    
    [[DownLoadViewController sharedInstance] singleThreadTaskDownLoad:sc.name andCount:completionCount ofTotal:total];
}

-(void) notifyDownloadingPhotoCollectionChannel:(PhotoCollectionChannel*)sc
                          withThreadsCompletion:(NSInteger)completionCount
                                        ofTotal:(NSInteger)total
{
    SEL sel = @selector(downloadingSubsChannel:withThreadsCompletion:ofTotal:);
    for (id<OfflineDownloaderDelegate> del in delegateArray_)
    {
        if([del respondsToSelector:sel])
            [del downloadingPhotoCollectionChannel:sc withThreadsCompletion:completionCount ofTotal:total];
    }
    
    [[DownLoadViewController sharedInstance] singleThreadTaskDownLoad:sc.name andCount:completionCount ofTotal:total];
}

-(void) notifyCurrentChannelProcessingProgress
{
    if([currentDownloadingTask_ isKindOfClass:[HotChannelOfflineDownloadTask class]])
    {
        HotChannelOfflineDownloadTask* t = (HotChannelOfflineDownloadTask*)currentDownloadingTask_;
        [self notifyDownloadingHotChannel:t.hotChannel withThreadsCompletion:currentThreadIdx_ + 1 ofTotal:[threadsArray_ count]];
    }
    else if([currentDownloadingTask_ isKindOfClass:[SubsChannelOfflineDownloadTask class]])
    {
        SubsChannelOfflineDownloadTask* t = (SubsChannelOfflineDownloadTask*)currentDownloadingTask_;
        [self notifyDownloadingSubsChannel:t.subsChannel withThreadsCompletion:currentThreadIdx_ + 1 ofTotal:[threadsArray_ count]];
    }
    else
    {
        ImageGalleryTask *t=(ImageGalleryTask*)currentDownloadingTask_;
        [self notifyDownloadingPhotoCollectionChannel:t.photoCChannel withThreadsCompletion:currentThreadIdx_ + 1 ofTotal:[threadsArray_ count]];
    }
    
}

-(BOOL) isTaskExist:(OfflineDownloadTask*)task
{
    if([task isKindOfClass:[HotChannelOfflineDownloadTask class]])
    {
        HotChannelOfflineDownloadTask* t = (HotChannelOfflineDownloadTask*)task;
        return [self isHotChannelDownloadingOrPending:t.hotChannel];
    }
    else if([task isKindOfClass:[SubsChannelOfflineDownloadTask class]])
    {
        SubsChannelOfflineDownloadTask* t = (SubsChannelOfflineDownloadTask*)task;
        return [self isSubsChannelDownloadingOrPending:t.subsChannel];
    }
    else if([task isKindOfClass:[MagIssueOfflineDownloadTask class]])
    {
        MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)task;
        return [self isIssueDownloadingOrPending:t.magId issId:t.issueId];
    }
    
    return NO;
}

-(OfflineIssueInfo*) getMagIssueInfo:(MagIssueOfflineDownloadTask*)task
{
    return [self getMagIssueInfoByMagId:task.magId andIssueId:task.issueId];
}

-(OfflineIssueInfo*) getMagIssueInfoByMagId:(long)magId andIssueId:(long)issId
{
    for (OfflineIssueInfo* info in MagIssusInfo_.issues)
    {
        if(info.magId == magId && info.issId == issId)
        {
            return info;
        }
    }
    return nil;
}

//@bringUpUI:是否立刻显示UI
-(BOOL) addDownloadTask:(OfflineDownloadTask *)task bringUpUI:(BOOL)showUI
{
    if([self isTaskExist:task])
        return NO;
    
    if (showUI)
        [self showView:task];
    
    if(!pendingTasksArray_)
        pendingTasksArray_ = [NSMutableArray new];
    [pendingTasksArray_ addObject:task];
    
    if(currentDownloadingTask_)
    {
        //当前有活动任务
        if([task isKindOfClass:[MagIssueOfflineDownloadTask class]])
        {
            MagIssueOfflineDownloadTask* task1 = (MagIssueOfflineDownloadTask*)task;
            OfflineIssueInfo* info = [self getMagIssueInfo:task1];
            if(!info)
            {
                //立刻创建下载项info，否则在离线包管理器中无法看到该项
                info = [OfflineIssueInfo new];
                info.magId = task1.magId;
                info.issId = task1.issueId;
                info.name = task1.issueName;
                info.zipBytes = task1.expectedZipBytes;
                info.zipUrl = task1.url;
                info.localFileName = [task1.url lastPathComponent];
                [MagIssusInfo_.issues addObject:info];
                [self saveIssuesInfoToFile];
            }
            info.issueStatus = IssueStatusPending;
            [self notifyDownloadingMagIssueStatusChanged:info];
            
            //            [[DownLoadViewController sharedInstance] deleteImage];
        }
    }
    else
    {
        //立刻开始任务
        [self processNextTask];
    }
    return YES;
}

-(BOOL) addDownloadTask:(OfflineDownloadTask*)task
{
    return [self addDownloadTask:task bringUpUI:YES];
}

-(void) removeIssueTaskWithMagId:(long)magId issueId:(long)issId
{
    if(currentDownloadingTask_ && [currentDownloadingTask_ isKindOfClass:[MagIssueOfflineDownloadTask class]])
    {
        MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)currentDownloadingTask_;
        if(t.magId == magId && t.issueId == issId)
        {
            [self stopCurrentTask];
            [self cleanupCurrentTask];
            [self processNextTask];
            return;
        }
    }
    
    for (OfflineDownloadTask* task in pendingTasksArray_)
    {
        if([task isKindOfClass:[MagIssueOfflineDownloadTask class]])
        {
            MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)task;
            if(t.magId == magId && t.issueId == issId)
            {
                OfflineIssueInfo* info = [self getMagIssueInfoByMagId:magId andIssueId:issId];
                if(info)
                {
                    info.issueStatus = IssueStatusStopped;
                    [self notifyDownloadingMagIssueStatusChanged:info];
                }
                [pendingTasksArray_ removeObject:task];
                return;
            }
        }
    }
}

-(void) stopCurrentTask
{
    if(!currentDownloadingTask_) return;
    
    //防止停止过程中观察者在回调中再次调用stop引发死循环
    static BOOL isStopping = NO;
    
    if(isStopping)
        return;
    else
        isStopping = YES;
    
    if([currentDownloadingTask_ isKindOfClass:[HotChannelOfflineDownloadTask class]])
    {
        
        HotChannelOfflineDownloadTask* t = (HotChannelOfflineDownloadTask*)currentDownloadingTask_;
        [self notifyDownloadingHotChannelWillEnd:t.hotChannel];
        switch (currentChannelSubTaskStage_)
        {
            case ChannelSubTaskGetThreads:
            {
                [[ThreadsManager sharedInstance]cancelRefreshHotChannel:self hotChannel:t.hotChannel];
                break;
            }
            case ChannelSubTaskGetThreadPreviewImage:
            {
                [[ImageDownloader sharedInstance] cancelDownload:previewImageDownloadingTask_];
                break;
            }
            case ChannelSubTaskGetThreadContent:
            {
                [[ThreadContentDownloader sharedInstance]cancelDownload:[threadsArray_ objectAtIndex:currentThreadIdx_]];
                break;
            }
            case ChannelSubTaskGetThreadContentImages:
            {
                ImageDownloader* imgDowloader = [ImageDownloader sharedInstance];
                for (ImageDownloadingTask* task in contentImagesDownloadingTaskArray_)
                    [imgDowloader cancelDownload:task];
                break;
            }
            default:
                break;
        }
    }
    else if ([currentDownloadingTask_ isKindOfClass:[ImageGalleryTask class]])
    {
        ImageGalleryTask* pc = (ImageGalleryTask*)currentDownloadingTask_;
        switch (currentChannelSubTaskStage_)
        {
            case ChannelSubTaskGetThreads:
            {
                [[ThreadsManager sharedInstance]cancelPhotoCollectionChannel:self pcChannel:pc.photoCChannel];
                break;
            }
            case ChannelSubTaskGetThreadPreviewImage:
            {
                [[ImageDownloader sharedInstance] cancelDownload:previewImageDownloadingTask_];
                break;
            }
            case ChannelSubTaskGetThreadContent:
            {
                [[ThreadContentDownloader sharedInstance]cancelDownload:[threadsArray_ objectAtIndex:currentThreadIdx_]];
                break;
            }
            case ChannelSubTaskGetThreadContentImages:
            {
                ImageDownloader* imgDowloader = [ImageDownloader sharedInstance];
                for (ImageDownloadingTask* task in contentImagesDownloadingTaskArray_)
                    [imgDowloader cancelDownload:task];
                break;
            }
            default:
                break;
        }

    }
    else if([currentDownloadingTask_ isKindOfClass:[SubsChannelOfflineDownloadTask class]])
    {
        SubsChannelOfflineDownloadTask* t = (SubsChannelOfflineDownloadTask*)currentDownloadingTask_;
        [self notifyDownloadingSubsChannelWillEnd:t.subsChannel];
        switch (currentChannelSubTaskStage_)
        {
            case ChannelSubTaskGetThreads:
            {
                [[ThreadsManager sharedInstance]cancelRefreshSubsChannel:self subsChannel:t.subsChannel];
                break;
            }
            case ChannelSubTaskGetThreadPreviewImage:
            {
                [[ImageDownloader sharedInstance] cancelDownload:previewImageDownloadingTask_];
                break;
            }
            case ChannelSubTaskGetThreadContent:
            {
                [[ThreadContentDownloader sharedInstance]cancelDownload:[threadsArray_ objectAtIndex:currentThreadIdx_]];
                break;
            }
            case ChannelSubTaskGetThreadContentImages:
            {
                ImageDownloader* imgDowloader = [ImageDownloader sharedInstance];
                for (ImageDownloadingTask* task in contentImagesDownloadingTaskArray_)
                    [imgDowloader cancelDownload:task];
                break;
            }
            default:
                break;
        }
    }
    else if([currentDownloadingTask_ isKindOfClass:[MagIssueOfflineDownloadTask class]])
    {
        MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)currentDownloadingTask_;
        if(issueZipStage == MagIssueZipStageDownloading)
        {
            [issueZipFetcher_ stopFetching];
            OfflineIssueInfo* info = [self getMagIssueInfo:t];
            info.issueStatus = IssueStatusStopped;
            [self notifyDownloadingMagIssueStatusChanged:info];
        }
        else if(issueZipStage == MagIssueZipStageUnzipping)
        {
            //NOTE:解压过程中不给取消
        }
    }
    
    isStopping = NO;
}

-(void) stop
{
    [self stopCurrentTask];
    [self cleanupCurrentTask];
    [pendingTasksArray_ removeAllObjects];
}

-(void) stopAllIssueTasks
{
    Class issTask = [MagIssueOfflineDownloadTask class];
    if(currentDownloadingTask_ && [currentDownloadingTask_ isKindOfClass:issTask])
    {
        [self stopCurrentTask];
        [self cleanupCurrentTask];
        [[DownLoadViewController sharedInstance] deleteImage];
    }
    
    
    
    for (NSInteger i=0; i<[pendingTasksArray_ count]; i++)
    {
        id task = pendingTasksArray_[i];
        
        if ([task isKindOfClass:issTask])
        {
            MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)task;
            [self removeIssueTaskWithMagId:t.magId issueId:t.issueId];
            i--;
        }
    }
    
    if(currentDownloadingTask_)
    {
        //do nothing
    }
    else if([pendingTasksArray_ count])
    {
        [self processNextTask];
    }
    else
    {
        //关闭UI
        //TODO
        [[DownLoadViewController sharedInstance] clickCloseBt];
        [[DownLoadViewController sharedInstance] setHiddenView:YES];
    }
    
}

-(BOOL) hasChannelTasksDownloadingOrPending
{
    Class hotTask = [HotChannelOfflineDownloadTask class];
    Class subsTask = [SubsChannelOfflineDownloadTask class];
    if(currentDownloadingTask_ && ([currentDownloadingTask_ isKindOfClass:hotTask] || [currentDownloadingTask_ isKindOfClass:subsTask]))
        return YES;
    
    for (id task in pendingTasksArray_)
    {
        if([task isKindOfClass:hotTask]
           || [task isKindOfClass:subsTask])
            return YES;
    }
    return NO;
}

-(BOOL) isHotChannelDownloadingOrPending:(HotChannel*)hc
{
    if(currentDownloadingTask_ && [currentDownloadingTask_ isKindOfClass:[HotChannelOfflineDownloadTask class]])
    {
        HotChannelOfflineDownloadTask* t = (HotChannelOfflineDownloadTask*)currentDownloadingTask_;
        if(t.hotChannel.channelId == hc.channelId)
            return YES;
    }
    
    for (OfflineDownloadTask* task in pendingTasksArray_)
    {
        if ([task isKindOfClass:[HotChannelOfflineDownloadTask class]])
        {
            HotChannelOfflineDownloadTask* t = (HotChannelOfflineDownloadTask*)task;
            if(t.hotChannel.channelId == hc.channelId)
                return YES;
        }
    }
    
    return NO;
}

-(BOOL) isSubsChannelDownloadingOrPending:(SubsChannel*)sc
{
    if(currentDownloadingTask_ && [currentDownloadingTask_ isKindOfClass:[SubsChannelOfflineDownloadTask class]])
    {
        SubsChannelOfflineDownloadTask* t = (SubsChannelOfflineDownloadTask*)currentDownloadingTask_;
        if(t.subsChannel.channelId == sc.channelId)
            return YES;
    }
    
    for (OfflineDownloadTask* task in pendingTasksArray_)
    {
        if ([task isKindOfClass:[SubsChannelOfflineDownloadTask class]])
        {
            SubsChannelOfflineDownloadTask* t = (SubsChannelOfflineDownloadTask*)task;
            if(t.subsChannel.channelId == sc.channelId)
                return YES;
        }
    }
    
    return NO;
}

-(BOOL) isIssueZipTmpFileExist:(long)magId issId:(long)issueId
{
    OfflineIssueInfo* info = [self getMagIssueInfoByMagId:magId andIssueId:issueId];
    if(!info) return NO;
    
    return [FileUtil fileExists:[[PathUtil pathOfOfflineMagazine] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.tmp",info.localFileName]]];
}

-(BOOL) isIssueDownloadingOrPending:(long)magId issId:(long)issueId
{
    if(currentDownloadingTask_ && [currentDownloadingTask_ isKindOfClass:[MagIssueOfflineDownloadTask class]])
    {
        MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)currentDownloadingTask_;
        if(t.magId == magId && t.issueId == issueId)
            return YES;
    }
    
    for (OfflineDownloadTask* task in pendingTasksArray_)
    {
        if ([task isKindOfClass:[MagIssueOfflineDownloadTask class]])
        {
            MagIssueOfflineDownloadTask* t = (MagIssueOfflineDownloadTask*)task;
            if(t.magId == magId && t.issueId == issueId)
                return YES;
        }
    }
    
    return NO;
}

-(OfflineIssueInfo*) getOfflineIssueInfoByMagId:(long)magId issId:(long)issueId
{
    return [self getMagIssueInfoByMagId:magId andIssueId:issueId];
}

-(NSArray*) getAllOfflineIssuesInfo
{
    return MagIssusInfo_.issues;
}

-(void) deleteDataForMagIssue:(OfflineIssueInfo*)issue
{
    //正在下载过程中，不允许删除
    if([self isIssueDownloadingOrPending:issue.magId issId:issue.issId])
        return;
    
    //清空离线数据
    [FileUtil deleteDirAndContents:[PathUtil pathOfOfflineDataForIssue:issue]];
    
    NSString* zipPath = [[PathUtil pathOfOfflineMagazine] stringByAppendingPathComponent:issue.localFileName];
    //删除.tmp文件
    [FileUtil deleteFileAtPath:[NSString stringWithFormat:@"%@.tmp",zipPath]];
    
    //删除.zip文件
    [FileUtil deleteFileAtPath:zipPath];
    
    //清空对应的info项目
    [MagIssusInfo_.issues removeObject:issue];
    [self saveIssuesInfoToFile];
}

-(BOOL) isIssueOfflineDataReady:(long)magId issId:(long)issueId
{
    //参考Docs/期刊离线包规则.txt
    
    //无对应info项，认为离线数据不存在
    OfflineIssueInfo* info = [self getMagIssueInfoByMagId:magId andIssueId:issueId];
    if(!info) return NO;
    
    return [self isIssueOfflineDataReady:info];
}

-(BOOL) isIssueOfflineDataReady:(OfflineIssueInfo*)info
{
    //对应zip包存在，认为离线数据不存在
    if([FileUtil fileExists:[[PathUtil pathOfOfflineMagazine] stringByAppendingPathComponent:info.localFileName]])
        return NO;
    
    return [FileUtil fileExists:[[PathUtil pathOfOfflineMagazine] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld/%ld/index.xml",info.magId,info.issId]]];
}

-(OfflineDownloadTask*) currentDownloadingTask
{
    return currentDownloadingTask_;
}

-(NSUInteger) pendingTasksCount
{
    if(pendingTasksArray_)
        return [pendingTasksArray_ count];
    else
        return 0;
}


#pragma mark UI

- (void)showView:(OfflineDownloadTask *)task
{
    DownLoadViewController *t = [DownLoadViewController sharedInstance];
    if (![theApp.window.subviews containsObject:t.view])
    {
//        [theApp.window addSubview:t.view];
        [theApp.window insertSubview:t.view atIndex:2];
        if ([task isKindOfClass:[SubsChannelOfflineDownloadTask class]])
        {
            isShowHotAnimotion = YES;
        }
        else if ([task isKindOfClass:[MagIssueOfflineDownloadTask class]])
        {
            isShowHotAnimotion = YES;
        }
    }
    else
    {
        if([task isKindOfClass:[HotChannelOfflineDownloadTask class]])
        {
            //            HotChannelOfflineDownloadTask* t = (HotChannelOfflineDownloadTask*)task;
            //            if ([self isHaveHotChannel:t.hotChannel]) {
            //                return;
            //            }
            if (isShowHotAnimotion)
            {
                [[DownLoadViewController sharedInstance] animationNum:[HotChannelsManager sharedInstance].visibleHotChannels.count];
                isShowHotAnimotion = NO;
            }
        }
        else if ([task isKindOfClass:[SubsChannelOfflineDownloadTask class]])
        {
            if ([theApp.window.subviews containsObject:[DownLoadViewController sharedInstance].view])
            {
                [[DownLoadViewController sharedInstance] animationNum:1];
            }
            isShowHotAnimotion = YES;
        }
        else if ([task isKindOfClass:[MagIssueOfflineDownloadTask class]])
        {
            if ([theApp.window.subviews containsObject:[DownLoadViewController sharedInstance].view])
            {
                [[DownLoadViewController sharedInstance] animationNum:1];
            }
            isShowHotAnimotion = YES;
        }
    }
}

- (BOOL)isHaveHotChannel:(HotChannel*)hc
{
    //    if(currentDownloadingTask_ && [currentDownloadingTask_ isKindOfClass:[HotChannelOfflineDownloadTask class]])
    //    {
    //        return YES;
    //    }
    
    for (OfflineDownloadTask* task in pendingTasksArray_)
    {
        if ([task isKindOfClass:[HotChannelOfflineDownloadTask class]])
        {
            return YES;
        }
    }
    
    return NO;
}


@end
