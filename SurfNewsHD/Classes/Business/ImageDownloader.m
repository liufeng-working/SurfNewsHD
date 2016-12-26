//
//  ImageDownloader.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ImageDownloader.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "FileUtil.h"
#import "ImageUtil.h"
#import "WebPUtil.h"
#import "CKImageAdditions.h"
#import "NSString+Extensions.h"

@interface ImageDownloadingTask()
{
@public
    NSData* _resultImageData;
}
@end

@implementation ImageDownloadingTask

@synthesize imageUrl = _imageUrl;
@synthesize resultImageData = _resultImageData;

-(void)setImageUrl:(NSString*)url
{
    _imageUrl = [url completeUrl];
}

@end

@interface ImageDownloadingInternalTask : NSObject
{
    NSMutableArray* tasks_;
    GTMHTTPFetcher* fetcher_;
}
@end

@implementation ImageDownloadingInternalTask

-(id)initWithTask:(ImageDownloadingTask*)task andCompetionHandler:(void(^)(BOOL succeeded))handler
{
    if(self = [self init])
    {
        tasks_ = [NSMutableArray new];
        [tasks_ addObject:task];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:task.imageUrl]];
        request.timeoutInterval = 15.f; // 图片请求的超时时间
        fetcher_ = [GTMHTTPFetcher fetcherWithRequest:request];
        fetcher_.servicePriority = 1;
        __weak id __tasks = tasks_;
        __weak GTMHTTPFetcher *__fetcher = fetcher_;
        
        [fetcher_ beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
         {
             [[NSURLCache sharedURLCache] removeAllCachedResponses];
             [[NSURLCache sharedURLCache] setDiskCapacity:0];
             [[NSURLCache sharedURLCache] setMemoryCapacity:0];
             
             if(error)
             {
                 DJLog(@"图片下载异常 = %@  , 信息 = %@, 下载对象信息 = %@", @(error.code) , error.domain, __tasks[0] );
                 //下载失败
                 for (ImageDownloadingTask* task in __tasks)
                 {
                     task->_finished = YES;
                     task.completionHandler(NO,task);
                 }
                 handler(NO);
             }
             else
             {
                 //下载成功
                 
                 //判断是否是有效的图片数据
                 ImageType imgType = [ImageUtil guessImageType:data];
                 if(imgType != UnknownImage)
                 {
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                                    {
                                        NSData* supportedData = data;
                                        if(imgType == WebpImage)
                                        {
                                            //对于webp，需要先解码
                                            supportedData = [WebPUtil convertWebPDataToJpgOrPngData:data];
                                        }
                                        NSData* targetData = supportedData;
                                        
                                        //使用者要求转换图片尺寸
                                        if (task.imageTargetSize.width > 0 && task.imageTargetSize.height > 0)
                                        {
                                            UIImage *sourceImage = [UIImage imageWithData:supportedData];
                                            //UIImage *targetImage = [ImageUtil imageWithImage:sourceImage scaledToSizeWithSameAspectRatio:task.imageTargetSize backgroundColor:[UIColor clearColor]];
                                            UIImage* targetImage = [sourceImage imageWithSize:task.imageTargetSize contentMode:UIViewContentModeScaleAspectFit];
                                            
                                            if (CGImageGetAlphaInfo(targetImage.CGImage) == kCGImageAlphaNone)
                                            {
                                                targetData = UIImageJPEGRepresentation(targetImage, 0.8f);
                                            }
                                            else
                                            {
                                                targetData = UIImagePNGRepresentation(targetImage);
                                            }
                                        }
                                    
                                        // 保存图片文件
                                        if(task.targetFilePath &&
                                           ![task.targetFilePath isEmptyOrBlank]){
                                            [targetData writeToFile:task.targetFilePath atomically:YES];
                                        }
                                        
                                        dispatch_sync(dispatch_get_main_queue(), ^(void)
                                                      {
                                                          for (ImageDownloadingTask* task in __tasks)
                                                          {
                                                              task->_resultImageData = targetData;
                                                              task->_finished = YES;
                                                              task.completionHandler(YES,task);
                                                          }
                                                          handler(YES);
                                                      });
                                    });
                 }
                 else
                 {
                     for (ImageDownloadingTask* task in __tasks)
                     {
                         task->_finished = YES;
                         task.completionHandler(NO,task);
                         
                         DJLog(@"图片格式不支持,URL = %@",task.imageUrl);
                     }
                     handler(NO);
                 }
             }
         }];
        
        //更新下载数据
        __fetcher.receivedDataBlock = ^(NSData* dataRecvedSofar)
        {
            if(__fetcher.response.expectedContentLength == 0)
            {
                //do nothing
            }
            else
            {
                for (ImageDownloadingTask* task in __tasks)
                {
                    if(task.progressHandler)
                    {
                        task.progressHandler([dataRecvedSofar length] * 1.0 / __fetcher.response.expectedContentLength,task);
                    }
                }
            }
        };
        
        return self;
    }
    return nil;
}

-(NSString*)imageUrl
{
    return [(ImageDownloadingTask*)[tasks_ objectAtIndex:0] imageUrl];
}

-(void)addTask:(ImageDownloadingTask*)task
{
    if(![tasks_ containsObject:task])
        [tasks_ addObject:task];
}

-(void)removeTask:(ImageDownloadingTask*)task
{
    [tasks_ removeObject:task];
    if([tasks_ count] == 0)
    {
        //取消下载
        [fetcher_ stopFetching];
        fetcher_ = nil;
    }
}

-(NSUInteger)tasksCount
{
    return [tasks_ count];
}

-(ImagePriority)getImagePriority
{
    if ([tasks_ count] > 0) {
        ImagePriority priority = kPriority_Higher;
        for (ImageDownloadingTask* t in tasks_) {
            if (priority > t.imgPriority) {
                priority = t.imgPriority;
            }
        }
        return priority;
    }
    return kPriority_None;
}

@end

@implementation ImageDownloader(private)

-(id) init
{
    self = [super init];
    if(self)
    {
        internalTasks_ = [NSMutableArray new];
    }
    return self;
}

-(ImageDownloadingInternalTask*) findInternalTaskByTask:(ImageDownloadingTask*)task
{
    for (ImageDownloadingInternalTask* iTask in internalTasks_)
    {
        if([[iTask imageUrl] caseInsensitiveCompare:[task imageUrl]] == NSOrderedSame)
        {
            return iTask;
        }
    }
    return nil;
}


@end


@implementation ImageDownloader

+ (ImageDownloader *)sharedInstance
{
    static ImageDownloader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImageDownloader alloc] init];
    });
    
    return sharedInstance;
}

-(void) download:(ImageDownloadingTask*)task
{
    if(!task.imageUrl || [task.imageUrl isEmptyOrBlank]){
        // 没有连接玩个屁啊
        task.completionHandler(NO,task);
        return;
    }
    
    ImageDownloadingInternalTask* internalTask = [self findInternalTaskByTask:task];
    if(!internalTask)
    {
        //新任务
        internalTask = [[ImageDownloadingInternalTask alloc] initWithTask:task andCompetionHandler:^(BOOL succeeded)
                        {
                            //注意：这里不能直接使用internalTask变量，因为它在block之后被重新赋值
                            //如果在block中直接引用，其值将始终是nil
                            ImageDownloadingInternalTask* iTaskRefind = [self findInternalTaskByTask:task];
                            [internalTasks_ removeObject:iTaskRefind];
                        }];
        [internalTasks_ addObject:internalTask];
        [self sortInternalTasks];
    }
    else
    {
        //已经存在同样的图片url处于下载进度中
        [internalTask addTask:task];
    }
}

-(void) cancelDownload:(ImageDownloadingTask*)task
{
    ImageDownloadingInternalTask* internalTask = [self findInternalTaskByTask:task];
    if(internalTask)
    {
        [internalTask removeTask:task];
        if([internalTask tasksCount] == 0)
        {
            [internalTasks_ removeObject:internalTask];
        }
    }
}

-(void)sortInternalTasks{
    if ([internalTasks_ count] > 1) {
        [internalTasks_ sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ImageDownloadingInternalTask *t1 = obj1;
            ImageDownloadingInternalTask *t2 = obj2;
            if ([t1 getImagePriority] > [t2 getImagePriority])
                return NSOrderedAscending;
            else if ([t1 getImagePriority] < [t2 getImagePriority])
                return NSOrderedDescending;
            return NSOrderedSame;
        }];
    }
}
@end
