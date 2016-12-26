//
//  MagazineDowLoadTask.h
//  SurfNewsHD
//
//  Created by yujiuyin on 13-8-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "FileUtil.h"
#import "MagazineManager.h"
#import "ZipArchive.h"
#import "PathUtil.h"

@interface MagazineDownLoadTask : NSObject
{
    
}
@property (nonatomic, copy)NSString *urlStr;//下载url地址
@property (nonatomic, copy)NSString *foldPath;
@property (nonatomic, copy)NSString *filePath;//文件保存的地址
@property (nonatomic,readonly) BOOL finished; //是否完成
@property (nonatomic, copy)NSString *name;
//下载进度，可以不设置
@property(nonatomic,strong) void(^progressHandler)(double percent,MagazineDownLoadTask* task);

//下载完成后的回调，必须设置
@property(nonatomic,strong) void(^completionHandler)(BOOL succeeded,MagazineDownLoadTask* task);
@property(nonatomic,strong,readonly) NSData* resultImageData;   //下载完成后的数据，

@end


@protocol MagazineDownLoaderDelegate <NSObject>

- (void)magazineWillBegin:(MagazineDownLoadTask *)task;
- (void)progressHander:(float)hander andTask:(MagazineDownLoadTask *)task;
- (void)magazineWillEnd:(MagazineDownLoadTask *)task;
@end

@interface MagazineDownLoader : NSObject
{
    GTMHTTPFetcher* fetcher;
}
@property (nonatomic, assign)id<MagazineDownLoaderDelegate> delegate;

+ (MagazineDownLoader *)sharedInstance;

-(void) download:(MagazineDownLoadTask*)task;
-(void) cancelDownload;

@end
