//
//  CommentModel.h
//  SurfNewsHD
//
//  Created by XuXg on 15/5/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonRequestBase.h"
#import "SurfJsonResponseBase.h"
#import "ThreadSummary.h"



#pragma mark 新闻评论数据模型

/**
 *  新闻评论基类
 */
@interface CommentBase : NSObject
@property(nonatomic,strong)NSString *headPic;   // 头像
@property(nonatomic,strong)NSString *nickname;  // 昵称
@property(nonatomic,strong)NSString *location;  // 地理位置
@property(nonatomic,strong)NSString *content;   // 评论内容
@property(nonatomic)double      createtime;     // 评论时间
@property(nonatomic)long        newsid;
@property(nonatomic)long        hot;
@property(nonatomic)long        commentId;      // 评论ID
@property(nonatomic)long        status;         // 0待审核，1审核通过，2驳回



// 临时数据(),对评论的态度 -1. 喷  0. 没有态度  1.赞
@property(nonatomic)NSInteger attitude;
@property(nonatomic)NSUInteger coid;
@end

// 热门评论
@interface HotComment : CommentBase
@property(nonatomic)NSInteger up;        // 被赞数
@property(nonatomic)NSInteger down;      // 被喷数
@property(nonatomic,strong)NSString *did;
@property(nonatomic,strong)NSString *uid;
@end

// 新评论
//{"commentCount":1,"countPage":1,"hasMore":0,"newList":[{"content":"大秀恩爱","createtime":1433301462940,"did":"d4cdcc4e-9731-3ad5-b149-1ddda61fa2c1","hot":0,"id":9379,"location":"江苏省宿迁","newsid":2346859,"status":1,"uid":"a76fce9c2e02ec4b5aee1375ba6a56ab","up":3}],"res":{"reCode":"1","resMessage":"Operation is successful"}}
@interface NewComment : CommentBase
@property(nonatomic)NSInteger up;        // 被赞数
@property(nonatomic)NSInteger down;      // 被喷数
@property(nonatomic,strong)NSString *did;
@property(nonatomic,strong)NSString *uid;
@end




#pragma mark HTTP 请求和接受数据模型
/**
 *  新闻评论请求
 */
@interface NewsCommentRequest : SurfJsonRequestBase

@property(nonatomic) NSInteger newsId;   // 新闻id
@property(nonatomic) NSInteger coid;     // 新闻频道id
@property(nonatomic) NSInteger page;     // 新闻频道id


-(id)initWithThreadSummary:(ThreadSummary*)ts pageNum:(NSInteger)page;
@end


/**
 *  新闻评论表态请求
 */
@interface NewsCommentAttitudeRequest : SurfJsonRequestBase

@property(nonatomic) NSInteger newsId;          // 新闻id
@property(nonatomic) NSInteger coid;            // 新闻频道id
@property(nonatomic) NSInteger commentId;       // 评论id
@property(nonatomic,strong)NSString* attitude;  // “up”：赞；”down”：喷

@end

/**
 *  提交新闻评论请求
 */
@interface CommitNewsCommentRequest : SurfJsonRequestBase

@property(nonatomic) NSInteger newsId;          // 新闻id
@property(nonatomic) NSInteger coid;            // 新闻频道id
@property(nonatomic,strong)NSString *content;   // 提交评论内容

@end


@interface NewsCommentResponse : SurfJsonResponseBase

@property(nonatomic)NSUInteger commentCount;    // 评论总数
@property(nonatomic)NSInteger countPage;        // 总页数
@property(nonatomic,strong)NSArray *hotList;    // 热推列表
@property(nonatomic,strong)NSArray *newsList;   // 新评论列表(文档中的字段newList)
@property(nonatomic)BOOL hasMore;               // 是否有更多


@end


@interface HotCommentResponse : SurfJsonResponseBase

@property(nonatomic)BOOL hasMore;               // 是否有更多
@property(nonatomic)NSInteger countPage;        // 总页数
@property(nonatomic,strong)NSArray *hotList;    // 热推列表

@end

