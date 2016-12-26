//
//  NewsCommentManager.h
//  SurfNewsHD
//
//  Created by XuXg on 15/5/21.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsCommentModel.h"

// 因业务需要，需要一些处理一些特殊逻辑关系
@protocol NewsCommentManagerDelegate <NSObject>


/**
 *  因热门评论和最新评论新闻数据一样，导致最新新闻或热门新闻用户点赞后，数据不能更新的问题
 *
 *  @param commentId 新闻评论id
 *  @param praise    点赞总数
 */
-(void)commentPraiseChanged:(NSUInteger)commentId
               praiseCount:(NSUInteger)praise;

@end


/**
 *  新闻评论点赞
 */
@interface NewsCommentPraiseResult : NSObject

@property(nonatomic) BOOL isSucceed;
@property(nonatomic) NSUInteger increment; // 点赞增量
@property(nonatomic,weak) id userInfo;

@end


/**
 *  新闻评论管理器
 */
@interface NewsCommentManager : NSObject {
    NSMutableDictionary *_userHeadIcon; // 用户头像管理
    
    UIImage* _default_head;             // 默认头像(白天)
    UIImage* _default_head_n;           // 默认头像(夜天)
    
    NSInteger _hotCommentPage;
    NSInteger _newCommentPage;
    
    // 标记评论是否发表态度
    NSMutableArray *_praise_cache;
}

@property(nonatomic,weak)id<NewsCommentManagerDelegate> commentDelegate;

/**
 *  新闻评论管理器
 *
 *  @return 新闻评论管理器对象
 */
+ (NewsCommentManager*)sharedInstance;



/**
 *  获取新闻评论列表
 *
 *  @param ts 新闻信息
 */
-(void)refreshNewsCommentsList:(ThreadSummary*)ts
     withCompletionHandler:(void(^)(NewsCommentResponse*))handler;


/**
 *  获取更多新闻评论
 *
 *  @param ts 新闻信息
 */
-(void)getMoreHotCommentsList:(ThreadSummary*)ts
        withCompletionHandler:(void(^)(HotCommentResponse*))handler;


/**
 *  获取更多新评论数据
 *
 *  @param ts              新闻帖子
 *  @param huid         获取数据后的回调
 */
-(void)getMoreNewCommentList:(ThreadSummary*)ts
       withCompletionHandler:(void(^)(NewsCommentResponse*))handler;


// 提交点赞请求
-(void)commitCommentAttitude:(CommentBase*)comment
       withCompletionHandler:(void(^)(NewsCommentPraiseResult*))handler;

-(UIImage*)defaultHeadIcon;

/**
 *  获取评论头像图片
 *
 *  @param comment 评论信息
 */
-(void)getCommentHeadIcon:(CommentBase*)comment
                 headIcon:(void(^)(CommentBase*comment, UIImage *headIcon))handler;


/**
 *  清空评论数据
 */
-(void)clearCommentData;


// 是否在请求处理
-(BOOL)isLoadingComment;
// 停止请求
-(void)stopLoadingComment;
// 是否点赞
-(BOOL)isPraise:(CommentBase*)comment;
/**
 *  添加点赞操作
 *
 *  @param comment          点赞对象
 *  @param praiseIncrement  点赞增量
 *
 *  @return 是否操作成功
 */
-(BOOL)addPraise:(CommentBase*)comment
 praiseIncrement:(NSUInteger)pi;

// 删除一样数据，返回一个增量数据
-(NSArray*)removeSameCommentData:(NSArray*)commentSource
                      addComment:(NSArray*)addComment;
@end
