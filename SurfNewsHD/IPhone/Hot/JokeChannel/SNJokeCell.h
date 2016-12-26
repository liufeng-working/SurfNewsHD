//
//  SNJokeCell.h
//  SurfNewsHD
//
//  Created by Tianyao on 16/2/2.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "SNTableViewCell.h"
#import "SNJokeLayout.h"

@class SNJokeCell;

/**
 *  底部操作栏
 */
@interface SNJokeInlineActionsView : UIView

@property (nonatomic, strong) UIButton *upButton;
@property (nonatomic, strong) UIImageView *upImageView;
@property (nonatomic, strong) UILabel *upLabel;

@property (nonatomic, strong) UIButton *downButton;
@property (nonatomic, strong) UIImageView *downImageView;
@property (nonatomic, strong) UILabel *downLabel;

@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIImageView *commentImageView;
@property (nonatomic, strong) UILabel *commentLabel;

@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIImageView *shareImageView;
@property (nonatomic, strong) UILabel *shareLabel;

@property (nonatomic, strong) NSMutableArray *upImages;
@property (nonatomic, strong) NSMutableArray *downImages;

@property (nonatomic, weak) SNJokeCell *cell;

- (void)updateUpWithAnimation;
- (void)updateDownWithAnimation;

@end


/**
 *  cell视图
 */
@interface SNJokeView : UIView

@property (nonatomic, strong) UIView *topLine;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) SNJokeInlineActionsView *inlineActionsView;

@property (nonatomic, weak) SNJokeCell *cell;

- (void)setWithLayout:(SNJokeLayout *)layout;

// 更新已读状态
- (void)updateThreadSummaryState:(ThreadSummary *)thread;

@end


/**
 *  底部按钮点击代理
 */
@protocol SNJokeCellDelegate <NSObject>

@optional
- (void)cellDidClickUp:(SNJokeCell *)cell;
- (void)cellDidClickDown:(SNJokeCell *)cell;
- (void)cellDidClickComment:(SNJokeCell *)cell;
- (void)cellDidClickShare:(SNJokeCell *)cell;
@end


/**
 *  段子的cell
 */
@interface SNJokeCell : SNTableViewCell

@property (nonatomic, strong) SNJokeView *jokeView;

@property (nonatomic, strong) SNJokeLayout *layout;

@property (nonatomic, weak) id<SNJokeCellDelegate> delegate;

@end
