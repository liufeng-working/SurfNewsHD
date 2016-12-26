//
//  SNJokeCell.m
//  SurfNewsHD
//
//  Created by Tianyao on 16/2/2.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "SNJokeCell.h"
#import "PathUtil.h"
#import "ThreadsManager.h"

@interface SNJokeInlineActionsView () {
    ThreadSummary *_thread;     // 段子模型
}

@end

@implementation SNJokeInlineActionsView

- (instancetype)init {
    self = [super init];
    self.width = kJContentWidth;
    self.height = kJActionsViewHeight;
    
    CGFloat itemW = kJActionItemWidth;  // 每个操作item占的宽
    CGFloat itemLeft = self.width * 0.25 - itemW;   // 每个item的左边距离
    /** 点赞 */
    NSArray *upImageNames = @[
                              @"up_1",
                              @"up_2",
                              @"up_3",
                              @"up_4",
                              @"up_5",
                              ];
    _upImages = [NSMutableArray array];
    for (NSString *imageName in upImageNames) {
        UIImage *upImage = [UIImage imageNamed:imageName];
        [_upImages addObject:upImage];
    }
    
    _upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _upImageView = [UIImageView new];
    _upLabel = [UILabel new];
    
    _upButton.size = CGSizeMake(kJActionItemWidth, kJActionsViewHeight);
    _upButton.centerY = self.height * 0.5;
    _upButton.left = itemLeft;
    _upButton.exclusiveTouch = YES;
    
    _upImageView.size = CGSizeMake(kJActionsViewHeight, kJActionsViewHeight);
    _upImageView.centerY = _upButton.centerY;
    _upImageView.left = _upButton.left;
    _upImageView.contentMode = UIViewContentModeCenter;
    _upImageView.image = [UIImage imageNamed:@"up_off"];
    
    _upLabel.width = itemW - _upImageView.width;
    _upLabel.height = _upButton.height;
    _upLabel.left = _upImageView.right;
    _upLabel.userInteractionEnabled = NO;
    _upLabel.font = SNJokeCellCountFont;
    _upLabel.textColor = [UIColor colorWithHexString:@"999999"];
    
    // 按钮添加点击事件
    [_upButton addTarget:self action:@selector(upButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 分割线
    UIView *grayLine1 = [[UIView alloc] init];
    grayLine1.frame = CGRectMake(self.width * 0.25, _upLabel.top, 0.5f, kJActionsViewHeight);
    grayLine1.backgroundColor = [UIColor colorWithHexString:@"999999"];
    
    [self addSubview:_upButton];
    [self addSubview:_upImageView];
    [self addSubview:_upLabel];
    [self addSubview:grayLine1];
    
    /** 点踩 */
    NSArray *downImageNames = @[
                                @"down_1",
                                @"down_2",
                                @"down_3",
                                @"down_4",
                                @"down_5"
                                ];
    _downImages = [NSMutableArray array];
    for (NSString *imageName in downImageNames) {
        UIImage *downImage = [UIImage imageNamed:imageName];
        [_downImages addObject:downImage];
    }
    
    _downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _downImageView = [UIImageView new];
    _downLabel = [UILabel new];
    
    _downButton.size = CGSizeMake(kJActionItemWidth, kJActionsViewHeight);
    _downButton.centerY = self.height * 0.5;
    _downButton.left = grayLine1.right + itemLeft;
    _downButton.exclusiveTouch = YES;
    
    _downImageView.size = CGSizeMake(kJActionsViewHeight, kJActionsViewHeight);
    _downImageView.centerY = _downButton.centerY;
    _downImageView.left = _downButton.left;
    _downImageView.contentMode = UIViewContentModeCenter;
    _downImageView.image = [UIImage imageNamed:@"down_off"];
    
    _downLabel.width = itemW - _downImageView.width;
    _downLabel.height = _downButton.height;
    _downLabel.left = _downImageView.right;
    _downLabel.userInteractionEnabled = NO;
    _downLabel.font = SNJokeCellCountFont;
    _downLabel.textColor = [UIColor colorWithHexString:@"999999"];
    
    // 按钮添加点击事件
    [_downButton addTarget:self action:@selector(downButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 分割线
    UIView *grayLine2 = [[UIView alloc] init];
    grayLine2.frame = CGRectMake(self.width * 0.5, _downLabel.top, 0.5f, kJActionsViewHeight);
    grayLine2.backgroundColor = [UIColor colorWithHexString:@"999999"];
    
    [self addSubview:_downButton];
    [self addSubview:_downImageView];
    [self addSubview:_downLabel];
    [self addSubview:grayLine2];
    
    /** 分享 */
    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareImageView = [UIImageView new];
    _shareLabel = [UILabel new];
    
    _shareButton.size = CGSizeMake(kJActionItemWidth, kJActionsViewHeight);
    _shareButton.centerY = self.height * 0.5;
    _shareButton.left = grayLine2.right + itemLeft;
    _shareButton.exclusiveTouch = YES;
    
    _shareImageView.size = CGSizeMake(kJActionsViewHeight, kJActionsViewHeight);
    _shareImageView.centerY = _shareButton.centerY;
    _shareImageView.left = _shareButton.left;
    _shareImageView.contentMode = UIViewContentModeCenter;
    _shareImageView.image = [UIImage imageNamed:@"share"];
    
    _shareLabel.width = itemW - _shareImageView.width;
    _shareLabel.height = _shareButton.height;
    _shareLabel.left = _shareImageView.right;
    _shareLabel.userInteractionEnabled = NO;
    _shareLabel.font = SNJokeCellCountFont;
    _shareLabel.textColor = [UIColor colorWithHexString:@"999999"];
    
    // 按钮添加点击事件
    [_shareButton addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 分割线
    UIView *grayLine3 = [[UIView alloc] init];
    grayLine3.frame = CGRectMake(self.width * 0.75, _shareLabel.top, 0.5f, kJActionsViewHeight);
    grayLine3.backgroundColor = [UIColor colorWithHexString:@"999999"];
    
    [self addSubview:_shareButton];
    [self addSubview:_shareImageView];
    [self addSubview:_shareLabel];
    [self addSubview:grayLine3];
    
    /** 评论 */
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentImageView = [UIImageView new];
    _commentLabel = [UILabel new];
    
    _commentButton.size = CGSizeMake(kJActionItemWidth, kJActionsViewHeight);
    _commentButton.centerY = self.height * 0.5;
    _commentButton.left = grayLine3.right + itemLeft;
    _commentButton.exclusiveTouch = YES;
    
    
    _commentImageView.size = CGSizeMake(kJActionsViewHeight, kJActionsViewHeight);
    _commentImageView.centerY = _commentButton.centerY;
    _commentImageView.left = _commentButton.left;
    _commentImageView.contentMode = UIViewContentModeCenter;

    if (_thread.isComment == 1) {   // 评论功能打开
        _commentImageView.image = [UIImage imageNamed:@"comment_on"];
        _commentButton.enabled = YES;
        _commentLabel.textColor = [UIColor colorWithHexString:@"999999"];
    } else {                        // 评论功能关闭
        _commentImageView.image = [UIImage imageNamed:@"comment_off"];
        _commentButton.enabled = NO;
        _commentLabel.textColor = [UIColor colorWithHexString:@"cccccc"];
    }
    
    
    _commentLabel.width = itemW - _commentImageView.width;
    _commentLabel.height = _commentButton.height;
    _commentLabel.left = _commentImageView.right;
    _commentLabel.userInteractionEnabled = NO;
    _commentLabel.font = SNJokeCellCountFont;
    
    // 按钮添加点击事件
    [_commentButton addTarget:self action:@selector(commentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_commentButton];
    [self addSubview:_commentImageView];
    [self addSubview:_commentLabel];
    
    return self;
}

/**
 *  点赞按钮点击
 */
- (void)upButtonClick {
    
    if (!_thread.uped && !_thread.downed) {
        if ([self.cell.delegate respondsToSelector:@selector(cellDidClickUp:)]) {
            [self.cell.delegate cellDidClickUp:self.cell];  // 更新数据，播放动画
        }
        // 更新已读状态
        self.cell.jokeView.textLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
        // 标记为已读存储到数据库
        [[ThreadsManager sharedInstance] markThreadAsRead:_thread];
        // 提交点赞
        [SurfRequestGenerator commitUpDownShareWithNewsId:_thread.newsId type:1 withCompletionHandler:^(BOOL successed) {
            if (successed) {    // 提交点赞成功
                // 赞或踩状态存储到数据库
                [[ThreadsManager sharedInstance] markJokeThreadAsUpedOrDowned:_thread];
            } else {
                [PhoneNotification autoHideJokeWithText:@"网络异常"];
            }
            
        }];
        
    } else {
        if (_thread.uped) {
            [PhoneNotification autoHideJokeWithText:@"已点过赞"];
        } else {
            [PhoneNotification autoHideJokeWithText:@"已点过踩"];
        }
    }
}

/**
 *  点踩按钮点击
 */
- (void)downButtonClick {

    if (!_thread.uped && !_thread.downed) {
        if ([self.cell.delegate respondsToSelector:@selector(cellDidClickDown:)]) {
            [self.cell.delegate cellDidClickDown:self.cell];
        }
        // 更新已读状态
        self.cell.jokeView.textLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
        [[ThreadsManager sharedInstance] markThreadAsRead:_thread];  // 标记为已读
        [SurfRequestGenerator commitUpDownShareWithNewsId:_thread.newsId type:2 withCompletionHandler:^(BOOL successed) {
            if (successed) {
                // 赞或踩存储到数据库
                [[ThreadsManager sharedInstance] markJokeThreadAsUpedOrDowned:_thread];
            } else {
                [PhoneNotification autoHideJokeWithText:@"网络异常"];
            }
        }];
        
        
    } else {
        if (_thread.downed) {
            [PhoneNotification autoHideJokeWithText:@"已点过踩"];
        } else {
            [PhoneNotification autoHideJokeWithText:@"已点过赞"];
        }
    }
    
}

/**
 *  分享按钮点击
 */
- (void)shareButtonClick {
    if ([self.cell.delegate respondsToSelector:@selector(cellDidClickShare:)]) {
        [self.cell.delegate cellDidClickShare:self.cell];
    }
}

/**
 *  评论按钮点击
 */
- (void)commentButtonClick {
    if ([self.cell.delegate respondsToSelector:@selector(cellDidClickComment:)]) {
        [self.cell.delegate cellDidClickComment:self.cell];
    }
}

- (void)setWithLayout:(SNJokeLayout *)layout {

    _thread = layout.joke;  // 获取段子模型
    
    if (_thread.uped) {
        _upImageView.image = [UIImage imageNamed:@"up_on"];
    } else {
        _upImageView.image = [UIImage imageNamed:@"up_off"];
    }
    
    if (_thread.downed) {
        _downImageView.image = [UIImage imageNamed:@"down_on"];
    } else {
        _downImageView.image = [UIImage imageNamed:@"down_off"];
    }
    
    // 赞数
    _upLabel.text = [NSString stringWithFormat:@" %ld", (long)_thread.upCount];
    
    // 踩数
    _downLabel.text = [NSString stringWithFormat:@" %ld", (long)_thread.downCount];
    
    // 分享数
    _shareLabel.text = [NSString stringWithFormat:@" %ld", (long)_thread.shareCount];
    
    // 评论数
    _commentLabel.text = [NSString stringWithFormat:@" %ld", (unsigned long)_thread.comment_count];
}

- (void)updateUpWithAnimation {

    if (_thread.uped) {
        _upImageView.image = [UIImage imageNamed:@"up_on"];
    } else {
        _upImageView.image = [UIImage imageNamed:@"up_off"];
    }
    
    // 播放动画
    _upImageView.animationImages = _upImages;
    _upImageView.animationDuration = 0.7f;
    _upImageView.animationRepeatCount = 1;
    [_upImageView startAnimating];
//    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        [_upImageView.layer setValue:@(1.5) forKeyPath:@"transform.scale"];
//    } completion:^(BOOL finished) {
//       [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//           [_upImageView.layer setValue:@(1) forKeyPath:@"transform.scale"];
//       } completion:nil];
//    }];
    
    // 更新点赞数字
    if (_thread.upCount > 0) {
        _upLabel.hidden = NO;
        _upLabel.text = [NSString stringWithFormat:@" %ld", (long)_thread.upCount];
    } else {
        _upLabel.hidden = YES;
    }
    
}

- (void)updateDownWithAnimation {
    
    if (_thread.downed) {
        _downImageView.image = [UIImage imageNamed:@"down_on"];
    } else {
        _downImageView.image = [UIImage imageNamed:@"down_off"];
    }
    
    // 播放动画
    _downImageView.animationImages = _downImages;
    _downImageView.animationDuration = 0.7f;
    _downImageView.animationRepeatCount = 1;
    [_downImageView startAnimating];
    
    // 动画
//    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        [_downImageView.layer setValue:@(1.5) forKeyPath:@"transform.scale"];
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            [_downImageView.layer setValue:@(1) forKeyPath:@"transform.scale"];
//        } completion:nil];
//    }];
    
    // 更新点踩数字
    if (_thread.downCount > 0) {
        _downLabel.hidden = NO;
        _downLabel.text = [NSString stringWithFormat:@" %ld", (long)_thread.downCount];
    } else {
        _downLabel.hidden = YES;
    }
}

@end

@implementation SNJokeView

- (instancetype)init {
    self = [super init];
    self.width = kScreenWidth;
    self.backgroundColor = [UIColor whiteColor];
    self.exclusiveTouch = YES;
    self.clipsToBounds = YES;
    
    _textLabel = [UILabel new];
    _textLabel.textAlignment = NSTextAlignmentNatural;
    _textLabel.font = SNJokeCellContentFont;
    _textLabel.textColor = [UIColor colorWithHexString:@"333333"];
    _textLabel.numberOfLines = 0;
//    _textLabel.adjustsFontSizeToFitWidth = YES;
    
#warning duanzizhengwenyanse
    _textLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_textLabel];
    
    _inlineActionsView = [SNJokeInlineActionsView new];
    _inlineActionsView.left = kJCellLeftPadding;
    [self addSubview:_inlineActionsView];
    
    _topLine = [UIView new];
    _topLine.width = kScreenWidth;
    _topLine.height = 1.0 / [UIScreen mainScreen].scale;
    _topLine.backgroundColor = [UIColor colorWithWhite:0.823 alpha:1.0];
    [self addSubview:_topLine];
    
    return self;
}

- (void)setWithLayout:(SNJokeLayout *)layout {
    ThreadSummary *thread = layout.joke;
    self.height = layout.height;
    
    _textLabel.text = thread.content;
    _textLabel.frame = layout.textF;
//    _textLabel.width = kJContentWidth;
    // 更新已读状态
    [self updateThreadSummaryState:thread];
    
    _inlineActionsView.centerY = self.height - kJActionsViewHeight * 0.5 - 13.5f;
    [_inlineActionsView setWithLayout:layout];
}

- (void)setCell:(SNJokeCell *)cell {
    _cell = cell;
    
    _inlineActionsView.cell = cell;
}

// 更新已读状态
- (void)updateThreadSummaryState:(ThreadSummary *)thread {
    // 判断cell是否为已读
    BOOL isRead = [[ThreadsManager sharedInstance] isThreadRead:thread];
    if (isRead) {
        _textLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
    } else {
        _textLabel.textColor = [UIColor blackColor];
    }
}

@end

@implementation SNJokeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    _jokeView = [SNJokeView new];
    _jokeView.cell = self;
    
    [self.contentView addSubview:_jokeView];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    return self;
}

- (void)setLayout:(SNJokeLayout *)layout {
    _layout = layout;
    self.contentView.height = layout.height;
    _jokeView.height = layout.height;
    [_jokeView setWithLayout:_layout];
}

@end
