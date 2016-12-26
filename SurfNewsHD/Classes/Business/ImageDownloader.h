//
//  ImageDownloader.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 注意：ImageDownloader设计为单例
 */

typedef enum{
    kPriority_None = 0,
    kPriority_Lower = -1,
    kPriority_Higher = 1,
}ImagePriority;

@interface ImageDownloadingTask : NSObject
{
@public
    BOOL _finished;
}
@property(nonatomic,strong,setter = setImageUrl:) NSString* imageUrl;        //图片url
@property(nonatomic,strong) NSString* targetFilePath;   //图片下载后存储的目标路径。包含文件名
@property(nonatomic) CGSize imageTargetSize;            //默认值为(0,0),表示使用原图大小,否则使用设定的大小
@property(nonatomic,weak) id userData;                  //用户自定义数据
@property(nonatomic,weak) id userData2;                  //用户自定义数据
@property(nonatomic,readonly) BOOL finished;            //是否完成
//下载进度，可以不设置
@property(nonatomic,strong) void(^progressHandler)(double percent,ImageDownloadingTask* task);

//下载完成后的回调，必须设置
@property(nonatomic,strong) void(^completionHandler)(BOOL succeeded,ImageDownloadingTask* task);
@property(nonatomic,strong,readonly) NSData* resultImageData;   //下载完成后的图片数据
@property(nonatomic)ImagePriority imgPriority;
@end



@interface ImageDownloader : NSObject
{
    NSMutableArray* internalTasks_;
}

//access the singleton ImageDownloader instance
+ (ImageDownloader *)sharedInstance;

-(void) download:(ImageDownloadingTask*)task;
-(void) cancelDownload:(ImageDownloadingTask*)task;

@end

