//
//  MagazineDowLoadTask.m
//  SurfNewsHD
//
//  Created by yujiuyin on 13-8-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "MagazineDownLoader.h"


@implementation MagazineDownLoadTask

- (void)setUrlStr:(NSString *)urlStr
{
    _urlStr = [urlStr completeUrl];
}

@end


@implementation MagazineDownLoader
-(id) init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}


+ (MagazineDownLoader *)sharedInstance
{
    static MagazineDownLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MagazineDownLoader alloc] init];
    });
    
    return sharedInstance;
}

- (long)isHaveMagazineTMP:(MagazineDownLoadTask *)task
{
    NSString *filePath = [NSString stringWithFormat:@"%@.tmp", task.filePath];
    return [FileUtil fileSizeAtPath:filePath];
}

//  http://www.cocoachina.com/bbs/job.php?action=download&aid=32364

-(void) download:(MagazineDownLoadTask*)task
{
    if (task && task.urlStr)
    {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:task.urlStr]];
        
        long size = [self isHaveMagazineTMP:task];
        if (0 != size)
        {
            NSString *range = [[NSString alloc] initWithFormat:@"bytes=%ld-",size];
            [request addValue:range forHTTPHeaderField:@"Range"];
        }
        
        fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        
        NSString* targetPath = [NSString stringWithFormat:@"%@.tmp", task.filePath];
        [FileUtil ensureSuperPathExists:targetPath];
        if(![FileUtil fileExists:targetPath])
            [[NSFileManager defaultManager] createFileAtPath:targetPath contents:nil attributes:nil];
        NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:targetPath];
       
        fetcher.downloadFileHandle = handle;
        
        __block GTMHTTPFetcher *__fetcher = fetcher;
        
        if ([self.delegate respondsToSelector:@selector(magazineWillBegin:)])
        {
            [self.delegate magazineWillBegin:task];
        }
        
        [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
         {
             [[NSURLCache sharedURLCache] removeAllCachedResponses];
             [[NSURLCache sharedURLCache] setDiskCapacity:0];
             [[NSURLCache sharedURLCache] setMemoryCapacity:0];
             
             if(error)
             {
                 NSLog(@"%@", error);
             }
             else
             {
                 NSString *filePath = [NSString stringWithFormat:@"%@.tmp", task.filePath];
                 if ([FileUtil fileExists:filePath])
                 {
                     NSError *err;
                     if ([[NSFileManager defaultManager] moveItemAtPath:filePath toPath:task.filePath error:&err])
                     {
                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                             if (!err)
                             {
                                 [self unZip:task.filePath];
                                 
                                 
                                 [self clearCache:task.filePath];
                             }
                             else
                                 NSLog(@"unzip error");
                         });
                     }
                     else
                     {
                          NSLog(@"rename error");
                     }
                 }
             }
             
             if ([self.delegate respondsToSelector:@selector(magazineWillEnd:)])
             {
                 [self.delegate magazineWillEnd:task];
             }
         }];
        
        
        __fetcher.receivedDataBlock = ^(NSData* dataRecvedSofar)
        {
//            if(__fetcher.response.expectedContentLength == 0)
//            {
//                
//            }
//            else
//            {
//                if(task.progressHandler)
//                {
//                    if ([self.delegate respondsToSelector:@selector(progressHander:andTask:)])
//                    {
//                        [self.delegate progressHander:[dataRecvedSofar length] * 1.0 / __fetcher.response.expectedContentLength andTask:task];
//                    }
//                }
//                
//                NSString *path = [NSString stringWithFormat:@"%@.tmp", task.filePath];
//                NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path];
//                if (file)
//                {
//                    [file seekToEndOfFile];
//                    [file writeData: dataRecvedSofar];
//                    [file closeFile];
//                }
//                else
//                {
//                    NSFileManager *fileManager = [NSFileManager defaultManager];
//                    BOOL isDirectory;
//                    if (![fileManager fileExistsAtPath:task.foldPath isDirectory:&isDirectory] || !isDirectory)
//                    {
//                        [fileManager createDirectoryAtPath:task.foldPath withIntermediateDirectories:YES attributes:nil error:nil];
//                    }
//                    
//                    [dataRecvedSofar writeToFile:path atomically:YES];
//                }
//            }
        };
    }
}

- (void)unZip:(NSString *)path
{
    ZipArchive* zipArchive = [[ZipArchive alloc] init];
    BOOL unzip = YES;
    BOOL openFile = [zipArchive UnzipOpenFile:path];
    if (openFile)
    {
        unzip = [zipArchive UnzipFileTo:path overWrite:YES];
        if (!unzip) {
            DJLog(@"unzip file failed:%@", path);
        }
    }
    else
    {
        DJLog(@"open zip file failed:%@", path);
    }
    [zipArchive UnzipCloseFile];
}

- (void)clearCache :(NSString *)path
{
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
}

-(void) cancelDownload
{
    if (fetcher)
    {
        [fetcher stopFetching];
        fetcher = nil;
    }
    
    [self setDelegate:nil];
}



@end
