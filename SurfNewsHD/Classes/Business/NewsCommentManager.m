//
//  NewsCommentManager.m
//  SurfNewsHD
//
//  Created by XuXg on 15/5/21.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "NewsCommentManager.h"
#import "SurfRequestGenerator.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "MJExtension.h"
#import "NewsCommentModel.h"
#import "ImageDownloader.h"
#import "SurfDbManager.h"

@implementation NewsCommentPraiseResult

@end

@implementation NewsCommentManager
GTMHTTPFetcher *_httpFecther;

+ (NewsCommentManager*)sharedInstance
{
    static NewsCommentManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [NewsCommentManager new];
    });
    return sharedInstance;
}


-(id)init
{
    self = [super init];
    if (self) {
        _praise_cache = [NSMutableArray arrayWithCapacity:10];
        _userHeadIcon = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

/**
 *  新闻评论列表
 *
 *  @param ts 新闻信息
 
 */
-(void)refreshNewsCommentsList:(ThreadSummary*)ts withCompletionHandler:(void(^)(NewsCommentResponse*))handler
{
    NSURLRequest *req = [SurfRequestGenerator getNewsCommentRequest:ts pageNum:1];
    if ([_httpFecther isFetching]) {
        [_httpFecther stopFetching];
    }
    
    
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:req];
    __block GTMHTTPFetcher *weakFecther = _httpFecther;
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error)
    {
        _hotCommentPage = 1;
        _newCommentPage = 1;
        NewsCommentResponse *resp = nil;
        if (error != nil) {
          // status code or network error

            
        } else {
          // succeeded
            NSStringEncoding encoding = [[[weakFecther response] textEncodingName] convertToStringEncoding];
            NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
            
            DJLog(@"%@", body);
            
            // json to model
            resp = [NewsCommentResponse objectWithKeyValues:body];
            
            if ([resp.newsList count] > 0) {
                [resp.newsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    ((CommentBase*)obj).coid = ts.channelId;
                }];
            }
            if ([resp.hotList count] >0) {
                [resp.hotList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    ((CommentBase*)obj).coid = ts.channelId;
                }];
            }
        }
        
        
        if (handler) {
            handler(resp);
        }
    }];
    
}


/**
 *  获取更多新闻评论
 *
 *  @param ts 新闻信息
 */
-(void)getMoreHotCommentsList:(ThreadSummary*)ts
        withCompletionHandler:(void(^)(HotCommentResponse *))handler
{
    if ([_httpFecther isFetching]) {
        DJLog(@"还有刷新新闻评论请求没有完成");
        return;
    }
    
    NSURLRequest *req = [SurfRequestGenerator moreHotNewsCommentRequest:ts pageNum:_hotCommentPage+1];
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:req];
    __block GTMHTTPFetcher *weakFecther = _httpFecther;
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error)
     {
         HotCommentResponse *resp = nil;
         if (!error) {
             // succeeded
             _hotCommentPage += 1;
             NSStringEncoding encoding = [[[weakFecther response] textEncodingName] convertToStringEncoding];
             NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
             
             DJLog(@"%@", body);
             
             // json to model
             resp = [HotCommentResponse objectWithKeyValues:body];
             if ([resp.hotList count] >0) {
                 [resp.hotList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                     ((CommentBase*)obj).coid = ts.channelId;
                 }];
             }
         }
        
         if (handler)   handler(resp);
         
     }];
}


/**
 *  获取更多新评论数据
 *
 *  @param ts              新闻帖子
 *  @param huid         获取数据后的回调
 */
-(void)getMoreNewCommentList:(ThreadSummary*)ts
       withCompletionHandler:(void(^)(NewsCommentResponse*))handler
{
    if ([_httpFecther isFetching]) {
        DJLog(@"还有刷新新闻评论请求没有完成。。。");
        return;
    }
    
    NSURLRequest *req =
    [SurfRequestGenerator getNewsCommentRequest:ts
                                        pageNum:_newCommentPage+1];
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:req];
    __block GTMHTTPFetcher *weakFecther = _httpFecther;
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error)
     {
         NewsCommentResponse *resp = nil;
         if (!error) {
             // succeeded
             _newCommentPage += 1;
             NSStringEncoding encoding = [[[weakFecther response] textEncodingName] convertToStringEncoding];
             NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
             
             DJLog(@"%@", body);
             
             // json to model
             resp = [NewsCommentResponse objectWithKeyValues:body];
             if ([resp.newsList count] > 0) {
                 [resp.newsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                     ((CommentBase*)obj).coid = ts.channelId;
                 }];
             }
         }
         
         if (handler)   handler(resp);
         
     }];
}


// 提交点赞请求
-(void)commitCommentAttitude:(CommentBase*)comment
       withCompletionHandler:(void(^)(NewsCommentPraiseResult*))handler
{
    NSURLRequest *req =
    [SurfRequestGenerator commitCommentAittitude:comment];
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:req];
    _httpFecther.userData = comment;
    __block GTMHTTPFetcher *weakFecther = _httpFecther;
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error)
     {
         NewsCommentPraiseResult *result =
         [NewsCommentPraiseResult new];
         result.userInfo = weakFecther.userData;
         if (!error) {
             result.isSucceed = YES;
             NSStringEncoding encoding = [[[weakFecther response] textEncodingName] convertToStringEncoding];
             NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
             DJLog(@"%@", body);
            
             // json to model
             SurfJsonResponseBase *resp =
             resp = [SurfJsonResponseBase objectWithKeyValues:body];
             if ([resp.res.reCode isEqualToString:@"1"]) {
                 result.increment = 1;
             }
         }
         
         if (handler)   handler(result);
         
     }];
    
}


/**
 *  获取默认头像图片
 *
 *  @return 图片信息
 */
-(UIImage*)defaultHeadIcon
{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        if (!_default_head_n) {
            _default_head_n = [UIImage imageNamed:@"headPicImageNew"];
        }
        return _default_head_n;
    }
    else {
        if (!_default_head) {
            _default_head = [UIImage imageNamed:@"headPicImageNew"];
        }
        return _default_head;
    }
    return nil;
}

/**
 *  获取评论头像图片
 *
 *  @param comment 评论信息
 */
-(void)getCommentHeadIcon:(CommentBase*)comment
                 headIcon:(void(^)(CommentBase*comment, UIImage *headIcon))handler
{
    if (!comment ||
        ![comment headPic] ||
        [[comment headPic] isEmptyOrBlank]) {
        if (handler) {
            handler(comment,[self defaultHeadIcon]);
            return;
        }
    }
    
    id key = [NSNumber numberWithInteger:comment.commentId];
    UIImage *icon = [_userHeadIcon objectForKey:key];
    if (!icon) {
        // 下载图片
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:[comment headPic]];
        [task setUserData:comment];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
            if(succeeded && idt != nil){
                UIImage *img = [UIImage imageWithData:[idt resultImageData]];
                if (!img) {
                    img = [self defaultHeadIcon];
                }
                CommentBase *cb = idt.userData;
                id k = [NSNumber numberWithInteger:cb.commentId];
                [_userHeadIcon setObject:img forKey:k];
                if (handler) {
                    handler(comment,img);
                }
            }
        }];
        [[ImageDownloader sharedInstance] download:task];
    }
    else{
        if (handler) {
            handler(comment,icon);
        }
    }
}

-(void)clearCommentData
{
    [_userHeadIcon removeAllObjects];
    [_praise_cache removeAllObjects];
}


-(BOOL)isLoadingComment
{
    return [_httpFecther isFetching];
}

-(void)stopLoadingComment
{
    if ([_httpFecther isFetching]) {
        [_httpFecther stopFetching];
    }
}
// 是否点赞
-(BOOL)isPraise:(CommentBase*)comment
{
    if ([_praise_cache containsObject:comment]) {
        return YES;
    }
    BOOL isP = [[SurfDbManager sharedInstance] isCommentRated:comment];
    if (isP) {
        [_praise_cache addObject:comment];
    }
    return isP;
}
// 点赞
-(BOOL)addPraise:(CommentBase*)comment
     praiseIncrement:(NSUInteger)pi
{
    if ([self isPraise:comment]) {
        return YES;
    }
    
    BOOL isSucceed = NO;
    if ([[SurfDbManager sharedInstance]
         addCommentRatingHistory:comment]) {
        isSucceed = YES;
        [_praise_cache addObject:comment];
        
        NSUInteger up = [[comment valueForKey:@"up"] integerValue];
        if (pi > 0 ) {
            [comment setValue:@(up + pi) forKey:@"up"];
            up += pi;
        }
        
        if ([_commentDelegate respondsToSelector:@selector(commentPraiseChanged: praiseCount:)]) {
            [_commentDelegate commentPraiseChanged:comment.commentId praiseCount:up];
        }
        
    }
    return isSucceed;
}

// 删除和原始数据一样的数据
-(NSArray*)removeSameCommentData:(NSArray*)commentSource
                      addComment:(NSArray*)addComment
{
    if (!addComment || [addComment count] == 0) {
        return nil;
    }
    
    if (!commentSource || [commentSource count] == 0) {
        return addComment;
    }
    
    NSMutableArray *commentList = [NSMutableArray array];
    for (CommentBase *ac in addComment) {
        BOOL isSame = NO;
        for (CommentBase *c in commentSource) {
            if (ac.commentId == c.commentId) {
                isSame = YES;
                break;
            }
        }
        
        if (!isSame) {
            [commentList addObject:ac];
        }
    }
    
    return commentList;
}
@end
