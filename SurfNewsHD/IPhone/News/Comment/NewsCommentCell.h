//
//  NewsCommentCell.h
//  SurfNewsHD
//
//  Created by XuXg on 15/6/3.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsCommentModel.h"

@interface NewsCommentCell : UITableViewCell


@property (nonatomic, readonly, weak)CommentBase *commentData;
@property (nonatomic)BOOL isShowPraiseButton; // default YES
@property (nonatomic)BOOL isDots;             // 是否是虚线default NO
@property (nonatomic)CGFloat dotsEdge;        // 虚线边距，默认为0
/**s
 *  加载评论数据
 *
 *  @param comment      评论数据源
 *  @param firstComment 是不是第一个评论，主要目的是用来绘制topLine
 */
-(void)loadCommentData:(CommentBase*)comment
        isFirstComment:(BOOL)firstComment;



/**
 *  刷新点赞控件
 */
-(void)refreshPraiseControl;


/**
 *  计算新闻评论cell高度
 *
 *  @param comment 评论信息
 *
 *  @return cell 高度
 */
+(NSInteger)calcCellHeight:(CommentBase*)comment;

@end
