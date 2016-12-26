//
//  PhoneNewsManager.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneNewsManager.h"
#import "GTMHTTPFetcher.h"
#import "PhoneNewsListResponst.h"
#import "EzJsonParser.h"
#import "NSString+Extensions.h"
#import "UserManager.h"
#import "FileUtil.h"
#import "PathUtil.h"
#import "ZipArchive.h"
#import "ImageDownloader.h"
#import "Encrypt.h"

#define Cover @"/Cover"
#define Zip @"/newsZip"


@interface PhoneNewsManager ()
@property NSUInteger page;
@property GTMHTTPFetcher *fetcher;
@property(nonatomic, copy) NSString* userId;
@property(nonatomic,strong)NSMutableArray *newsDataArray;
@end

@implementation PhoneNewsManager


+(PhoneNewsManager*)sharedInstance{
    static PhoneNewsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PhoneNewsManager alloc] init];
    });    
    return sharedInstance;
}

-(id)init{
    if (self = [super init]) {
        _page = 1;
    }
    return self;
}

-(void)setUserId:(NSString *)userId
{
    if (![_userId isEqual:userId]) {
        _userId = userId;
        _page = 1;
    }
}


- (BOOL)isRequestNews{
    if (_fetcher == nil) {
        return NO;
    }
    return [_fetcher isFetching] ? YES : NO;
}

- (void)cancelRequest{
    if ([_fetcher isFetching]) {
        [_fetcher stopFetching];
        _fetcher = nil;
    }
}
// 刷新手机列表
- (void)refreshPhoneNewsList:(void(^)(BOOL, NSArray*))handler{
    NSString *encryptUid = [self getEncryptUserID];
    if (encryptUid != nil) {
        [self requestPhoneNew:encryptUid page:_page completeHandler:handler];
    }
}

// 加载更多手机列表
// 注释的原因：加载更多会把之前的数据给删除，需要特殊处理下.
//- (void)loadMorePhoneNewsList:(void(^)(BOOL, NSArray*))handler{
//    
//    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];    
//    if (userInfo != nil && userInfo.userID.length > 0) {
//        [self setUserId:userInfo.userID];
//        [self requestPhoneNew:[self userId] page:++_page completeHandler:handler];
//    }
//}


-(void)requestPhoneNew:(NSString *)uid page:(NSInteger)pageCount completeHandler:(void(^)(BOOL, NSArray*))handler{
    if ([self isRequestNews]) {
        if (handler != nil){
            handler(NO, nil);
        }
        return;
    }
    
    NSURLRequest* request = [SurfRequestGenerator getPhoneNewsList:uid page:pageCount];
    _fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [_fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error)
     {
         BOOL succeeded = NO;
         NSMutableArray *tempArray = nil;
         if (error) {
             [SurfNotification surfNotification:@"刷新手机报失败！"];
         }
         else{
             NSStringEncoding encoding = [[[_fetcher response] textEncodingName] convertToStringEncoding];
             NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
             
             PhoneNewsListResponst *resp = [EzJsonParser deserializeFromJson:body AsType:[PhoneNewsListResponst class]];
             if (resp) {// 防止解析出错
                 // 0 获取列表信息成功
                 // 1 用户登录超时
                 // 2 缺失必要参数
                 // 3 获取列表信息失败
                 if (resp.resCode == 0) {
                     succeeded = YES;
                     [_newsDataArray removeAllObjects];
                     [_newsDataArray addObjectsFromArray:[resp res]];
                     [self sortThreads:_newsDataArray];                 // 排序数组
                     tempArray = _newsDataArray;
                     
                     // 保存内容到文件中
                     NSString *filePath = [PathUtil pathOfPhoneNewsList:_userId];
                     [[EzJsonParser serializeObjectWithUtf8Encoding:resp] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                 }
                 else if (resp.resCode == 1){
                     [SurfNotification surfNotification:@"用户登录超时"];
                 }
                 else if (resp.resCode == 3){
                     [SurfNotification surfNotification:@"获取列表信息失败"];
                 }
                 else{
                     [SurfNotification surfNotification:@"刷新手机报失败！"];
                 }
             }else{
                 [SurfNotification surfNotification:@"刷新手机报失败！"];
             }
         }
         
         if (handler != nil){
             handler(succeeded, tempArray);
         }
     }];
    
}

// 获取加密的用户id
-(NSString*)getEncryptUserID{
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    if (userInfo == nil) {
        return nil;
    }
    else{
        [self setUserId:[userInfo encryptUserID]];
        return [self userId];
    }
}

// 获取本地手机列表
- (NSArray*)getLocalPhoneNew{
    if (_newsDataArray) {
        return _newsDataArray;
    }
    
    _newsDataArray = [NSMutableArray arrayWithCapacity:10];
    NSString *uid = [self getEncryptUserID];
    if (uid != nil && uid.length > 0) {
  
        //从文件载入
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *listPath = [PathUtil pathOfPhoneNewsList:uid];
        
        // 检测文件是否存在
        if ([fm fileExistsAtPath:listPath]) {

            NSError *error = nil;
            NSString *body = [NSString stringWithContentsOfFile:listPath encoding:NSUTF8StringEncoding error:&error];            
            if (error == nil) { // 读取文件成功
                PhoneNewsListResponst *resp = [EzJsonParser deserializeFromJson:body AsType:[PhoneNewsListResponst class]];
                if (resp && resp.resCode == 0) {// 防止解析出错
                    // 0 获取列表信息成功
                    // 1 用户登录超时
                    // 2 缺失必要参数
                    // 3 获取列表信息失败
                    if ([[resp res] count] > 0) {
                        [_newsDataArray addObjectsFromArray:[resp res]];
                        [self sortThreads:_newsDataArray];
                    }
                    
                    // 处理冗余数据
                    // step 1 获取Cover图片文件夹中的图片名
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                        NSString *coverDir = [PathUtil dirOfPhoneNewsCover];
                        NSMutableArray *images = [NSMutableArray arrayWithArray:[fm contentsOfDirectoryAtPath:coverDir error:nil]];
                        if ([images count] > [_newsDataArray count]){
                            for (PhoneNewsData * newsData in _newsDataArray) {
                                if ([newsData isKindOfClass:[PhoneNewsData class]]) {
                                    for (NSInteger i = 0; i< [images count]; ++i) {
                                        NSString *imgName = [images objectAtIndex:i];
                                        NSRange rang = [imgName rangeOfString:newsData.hashcode];
                                        if (rang.length > 0 ) {
                                            [images removeObjectAtIndex:i];
                                            break;
                                        }
                                    }
                                }
                            }
                            
                            // 找到冗余图片的名称，删除
                            if ([images count] > 0) {
                                for (NSInteger i=0; i<[images count]; ++i) {
                                    NSString *imgName = [images objectAtIndex:i];
                                    PhoneNewsData *oldData = [PhoneNewsData new];
                                    oldData.hashcode = [imgName stringByDeletingPathExtension];;
                                    [self deleteNewsFile:oldData]; // 删除文件
                                }
                            }
                        }                    
                    });
                  
                }
                else{
                    // 删除手机报列表                    
                    [fm removeItemAtPath:listPath error:nil];
                }
            }
            else{
                // 删除手机报列表
                [fm removeItemAtPath:listPath error:nil];
            }
        }
    }
    return _newsDataArray;
}


- (void)getPhoneNewsHtmlDate:(PhoneNewsData*)newData complete:(void(^)(BOOL, NSString*))handler{
    if (newData == nil) {
        if (handler) {
            handler(NO, nil);
        }
        return;
    }
    
    [self loadPhoneNewsZipFile:newData complete:handler];
    
}
// 加载手机Zip包
- (void)loadPhoneNewsZipFile:(PhoneNewsData*)phoenDate complete:(void(^)(BOOL, NSString*))handler{
    
    // 好坑爹啊
    // 判读解zip文件包是否存在
    NSString *htmlPath = [self getHtmlPath:phoenDate];
    if (htmlPath != nil && htmlPath.length > 0) {
        NSError *error;
        NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&error];
        if (handler){
            handler(error.code == 0 ?YES:NO, html);
        }
    }
    else{    
        
        NSString* url = [phoenDate.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [SurfRequestGenerator getPhoneNewsZIP:url];
        GTMHTTPFetcher *fetcher_ = [GTMHTTPFetcher fetcherWithRequest:request];
        [fetcher_ beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            BOOL isResult = NO;
            NSString* htmalData = nil;
            if (error) {
                [SurfNotification surfNotification:@"请求内容失败"];
            }
            else{
                NSString *zipFile = [self getZipPath:phoenDate];
                NSString *unZipPath = [self getUnzipPath:phoenDate];
                [data writeToFile:zipFile atomically:YES];

                
                // 不存在zip包，就需要请求zip包
                ZipArchive* zip = [[ZipArchive alloc] init];
                if( [zip UnzipOpenFile:zipFile] ){
                    BOOL result = [zip UnzipFileTo:unZipPath overWrite:YES];
                    if( YES == result ){
                        //添加代码
                        isResult = YES;
                        htmalData =[NSString stringWithContentsOfFile:[self getHtmlPath:phoenDate]
                                                             encoding:NSUTF8StringEncoding error:nil];
                         DJLog(@"%@", htmalData);
                    }
                    [zip UnzipCloseFile];
                }
                
                // 异步删除zip压缩包            
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[NSFileManager defaultManager] removeItemAtPath:zipFile error:nil];
                    DJLog(@"删除OK");
                });
               
                
            }         
         
            if (handler){
                 handler(isResult, htmalData);
            }
            
        }];
        
    }

}


#pragma mark 获取图片
// 获取手机报封面图片
- (void)getPhoneNewsCoverImg:(PhoneNewsData*)newData complete:(void(^)(BOOL, UIImage*))handler{
    if (newData == nil || [newData.hashcode length] == 0) {
        if (handler) {
            handler(NO, nil);
        }
        return;
    }

    // 在本地查找是否有图片
    NSString *coverPath = [self getCoverPath:newData];
    if ([FileUtil fileExists:coverPath]) {
        // 文件存在，就加载本地缓存       
        if (handler) {
            handler(YES, [UIImage imageWithContentsOfFile:coverPath]);
        }
    }
    else{
     
        // 请求图片
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setTargetFilePath:coverPath];
        [task setImageUrl:[[newData imgurl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *task) {
            UIImage *img = nil;
            if (succeeded && task.resultImageData != nil) {
                img = [UIImage imageWithData:task.resultImageData];
            }
            
            if (handler) {
                handler(succeeded, img);
            }
        }];
        [[ImageDownloader sharedInstance] download:task];
    }
}

// 取消手机报收藏
- (void)cancelPhoneNewsFavs:(PhoneNewsData*)newData complete:(void(^)(BOOL))handler{
    if (newData == nil || [newData.hashcode length] == 0) {
        if (handler) {
            handler(NO);
        }
        return;
    }
        
    NSURLRequest* request = [SurfRequestGenerator getPhoneNEwsCancleFavs:[self getEncryptUserID] hashCode:newData.hashcode];
    GTMHTTPFetcher *fetcher_ = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher_ beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        BOOL result = NO;
        if (error == nil) {
            //检测成功
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher_ response] textEncodingName] convertToStringEncoding]];
            PhoneNewsCancelFavsResponst* resp = [EzJsonParser deserializeFromJson:body
                                                                           AsType:[PhoneNewsCancelFavsResponst class]];
            if (resp && resp.resCode == 0) {
                result = YES;
                
                [_newsDataArray removeObject:newData];
                [self deleteNewsFile:newData]; // 删除文件
                [self deletePhoneNewsDataInList:newData];// 删除本地手机报列表
            }
        }
        
        if (handler) {
            handler(result);
        }
    }];
}

#pragma mark Path


- (NSString*)getHtmlPath:(PhoneNewsData*)data{
    
    BOOL isDir = FALSE;
    NSString *htmlPath = nil;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *unzipDir = [self getUnzipPath:data];
    BOOL isDirExist = [fileMgr fileExistsAtPath:unzipDir isDirectory:&isDir];
    if (isDirExist && unzipDir) {        
        // 获取文件夹中的文件名
        NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:unzipDir error:nil];
        for (NSString *path in fileList) {
            if ([path isKindOfClass:[NSString class]]) {
                NSRange rang = [(NSString*)path rangeOfString:@"index"];
                if (rang.length > 0) {
                    htmlPath = [unzipDir stringByAppendingPathComponent:path];
                    break;
                }
            }
        }
        
        // 如何是不知道什么文件，就删除，从新下载
        if (htmlPath == nil && [htmlPath length] == 0) {
            [FileUtil deleteDirAndContents:unzipDir];
        }
    }
    return htmlPath;
}

- (NSString*)getCoverPath:(PhoneNewsData*)data{
    return [[PathUtil dirOfPhoneNewsCover] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.img",data.hashcode]];
}

- (NSString*)getZipPath:(PhoneNewsData*)data{
    return [self getZipPathWithHashcode:data.hashcode];
}
- (NSString*)getZipPathWithHashcode:(NSString *)hashCode{
    return [[PathUtil dirOfPhoneNewsZip] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.zip",hashCode]];
}

- (NSString*)getUnzipPath:(PhoneNewsData*)data{
    return [[PathUtil dirOfPhoneNewsZip] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@_unzip",data.hashcode]];
}

// 删除文件
- (void)deleteNewsFile:(PhoneNewsData*)data{
    if (data) {        
        NSString *coverPath = [self getCoverPath:data];
        NSString *zipPath = [self getZipPath:data];
        NSString *unzipPath = [self getUnzipPath:data];
        
//        [FileUtil deleteContentsOfDir:coverPath];   // 删除封面图片
//        [FileUtil deleteContentsOfDir:zipPath];     // 删除ZIP包
//        [FileUtil deleteDirAndContents:unzipPath];  // 解压的ZIP包
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];        
        [fileMgr removeItemAtPath:coverPath error:nil];
        [fileMgr removeItemAtPath:zipPath error:nil];
        [fileMgr removeItemAtPath:unzipPath error:nil];
    }
}

// 删除手机报列表中的信息
- (void)deletePhoneNewsDataInList:(PhoneNewsData*)data{
    
    // 修改本地列表中的数据
    NSString *filePath = [PathUtil pathOfPhoneNewsList:self.userId];
    NSString *body = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    PhoneNewsListResponst *resp = [EzJsonParser deserializeFromJson:body AsType:[PhoneNewsListResponst class]];
    if (resp) {// 防止解析出错
        //                 0 获取列表信息成功
        //                 1 用户登录超时
        //                 2 缺失必要参数
        //                 3 获取列表信息失败
        if (resp.resCode == 0 && [[resp res] count] > 0) {
            if ([[resp res] isKindOfClass:[NSMutableArray class]]) {
                
                for (PhoneNewsData *newData in [resp res]) {
                    if ([newData isKindOfClass:[PhoneNewsData class]]) {
                        if ([[newData hashcode] isEqualToString:data.hashcode] ) {
                            [((NSMutableArray*)[resp res]) removeObject:newData];
                            
                            // 在保存到文件中
                            [[EzJsonParser serializeObjectWithUtf8Encoding:resp] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            
                            break;
                        }
                        
                    }
                }
            }
        }
    }
    
}

// 手机报按时间排序
-(void)sortThreads:(NSMutableArray*)phoneNewsArray
{
    [phoneNewsArray sortUsingComparator:^NSComparisonResult(id obj1,id obj2)
     {
         PhoneNewsData* t1 = (PhoneNewsData*)obj1;
         PhoneNewsData* t2 = (PhoneNewsData*)obj2;
         if(t1.datetime < t2.datetime)
         {
             return NSOrderedDescending;
         }
         else
         {
             return NSOrderedAscending;
         }
     }];    
}

@end
