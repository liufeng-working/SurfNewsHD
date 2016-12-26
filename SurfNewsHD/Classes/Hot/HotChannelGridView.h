//
//  HotChannelGridView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotChannelsListResponse.h"
#import "SubscribeChannelGridView.h"
#import "HotChannelsManager.h"

@interface HotChannelGridViewCell : UIView
{
    UIImageView *backgroundView;
    UILabel *label;
}

@property(nonatomic, strong) HotChannel *hotChannel;
@property(nonatomic) NSInteger cellFlag;
@property(nonatomic) BOOL unDrag;                       //不可拖拽

- (void)setCellBackground:(NSString *)imageName textColor:(NSString*)color;

@end

@protocol HotChannelGridViewDataSource;

@protocol HotChannelGridViewDelegate <NSObject>

- (void)removeCurrentHotChannel:(HotChannel*)channel;
- (void)foldHotChannels;

@end

@interface HotChannelGridView : UIView

@property(nonatomic, unsafe_unretained) id<HotChannelGridViewDataSource> dataSource;
@property(nonatomic, unsafe_unretained) id<HotChannelGridViewDelegate> delegate;
@property(nonatomic, strong) NSMutableArray *invisibleChannelArray;
@property(nonatomic, strong) NSMutableArray *visibleChannelArray;
@property(nonatomic) float widthOfView;                                 //view的宽度
@property(nonatomic) float heightOfView;                                //view的高度
@property(nonatomic) float cellVerticalSpacing;                         //垂直cell之间的间距
@property(nonatomic) float cellHorizontalSpacing;                       //横向cell之间的间距
@property(nonatomic) NSInteger cellCountPerRow;                         //每行放置cell的最大个数
@property(nonatomic) UIEdgeInsets edgeInsets;                           //指定边缘指

- (void)reloadView;

@end

#pragma mark Protocol HotChannelGridViewDataSource
@protocol HotChannelGridViewDataSource <NSObject>

@required
- (NSMutableArray*)arrayOfInvisibleCell;
- (NSMutableArray*)arrayOfVisibleCell;
- (CGSize)sizeForCell;
- (HotChannelGridViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath;

@end