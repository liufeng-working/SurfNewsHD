//
//  HotIconFlagManager.m
//  SurfNewsHD
//
//  Created by XuXg on 14/12/17.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "HotIconFlagManager.h"
#import "ImageDownloader.h"
#import "PathUtil.h"
#import "FileUtil.h"


@interface HotIconFlagManager () {
    NSMutableDictionary *_images;
    NSMutableDictionary *_imageNotification;
}
@end




@implementation HotIconFlagManager


+ (HotIconFlagManager*)sharedInstance
{
    static HotIconFlagManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [HotIconFlagManager new];
    });
    return sharedInstance;
}

- (id)init{
    if (self = [super init]) {
        _images = [NSMutableDictionary dictionaryWithCapacity:5];
        _imageNotification = [NSMutableDictionary dictionaryWithCapacity:5];
        _pEnergyImg = [UIImage imageNamed:@"positive_big"];
        _nEnergyImg = [UIImage imageNamed:@"negative_big"];
        _nEnergyImg_night = [UIImage imageNamed:@"bad_icon_night"];
        _commentFlag = [UIImage imageNamed:@"commentFlag"];
    }
    return self;
}


// 获取热点标记
- (UIImage*)getHotIconWithUrl:(NSString*)imgUrl
         imgCompletionHandler:(void(^)(NSString*imgName , UIImage* iconImg))handler
{
    NSString *imgName = [imgUrl lastPathComponent];
    UIImage *image = [_images objectForKey:imgName];
    if (image == nil) {
        // 没有图片，需要到本地文件中去查找
        NSString* iconPath = [[PathUtil pathOfHotIconDir] stringByAppendingPathComponent:imgName];
        if ([FileUtil fileExists:iconPath]){
            NSData *imgData = [NSData dataWithContentsOfFile:iconPath];
            image = [UIImage imageWithData:imgData];
            [_images setObject:image forKey:imgName];
        }
        else{
            
            if (!handler) {
                return image;
            }
            
            // 本地没有图片文件，就去服务器上下载
            NSMutableArray *views = [_imageNotification objectForKey:imgName];
            if (views == nil) {
                views = [NSMutableArray array];
                [views addObject:handler];
                [_imageNotification setObject:views forKey:imgName];
                
                // 下载图片
                [self downloadImage:imgUrl imagePath:iconPath imageName:imgName];
            }
            else{
                if (![views containsObject:handler]) {
                    [views addObject:handler];
                }
            }
        }
    }
    return image;
}

// 下载图片并保持到文件夹中
- (void)downloadImage:(NSString*)imageUrl
            imagePath:(NSString*)imagePath
            imageName:(NSString*)imageName
{
    ImageDownloadingTask *task = [ImageDownloadingTask new];
    task.targetFilePath = imagePath;
    task.imageUrl = imageUrl;
    task.userData = imageName;
    task.completionHandler = ^(BOOL succeeded, ImageDownloadingTask* t)
    {
        if (succeeded && t.finished) {
            UIImage *downloadImage = [UIImage imageWithData:t.resultImageData];
            if (downloadImage) {
                NSString *imgName = t.userData;
                [_images setObject:downloadImage forKey:imgName];
                NSMutableArray *views = [_imageNotification objectForKey:imgName];
                if (views != nil) {
                    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        void(^h)(NSString* , UIImage*) = obj;
                        h(imgName,downloadImage);
                    }];
                    [views removeAllObjects];
                    [_imageNotification removeObjectForKey:imgName];
                }
            }
        }
    };
    [[ImageDownloader sharedInstance] download:task];
}
@end
