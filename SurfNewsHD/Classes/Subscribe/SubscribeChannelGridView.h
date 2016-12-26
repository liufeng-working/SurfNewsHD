//
//  SubscribeChannelGridView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubsChannelsListResponse.h"
#import "SubsChannelsManager.h"

@interface CellSpace : NSObject

@property(nonatomic) CGRect aRect;
@property(nonatomic) CGRect bRect;

@end

@interface SubscribeChannelGridViewCell : UIView
{
    UIImageView *backgroundView;
    
    UILabel *label;
    UIButton *deleteButton;
}

@property(nonatomic, strong) SubsChannel *subsChannel;

- (void)setCellBackground:(NSString *)imageName textColor:(NSString*)color;
- (BOOL)pointInDeleteButton:(CGPoint)point;
- (void)setSubsChannel:(SubsChannel *)subsChannel onlyOne:(BOOL)only;

@end


@protocol SubscribeChannelGridViewDelegate;
@protocol SubscribeChannelGridViewDataSource;

@interface SubscribeChannelGridView : UIView <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property(nonatomic, unsafe_unretained) id<SubscribeChannelGridViewDelegate> delegate;
@property(nonatomic, unsafe_unretained) id<SubscribeChannelGridViewDataSource> dataSource;
@property(nonatomic, strong) NSMutableArray *invisibleChannelArray;
@property(nonatomic, strong) NSMutableArray *visibleChannelArray;
@property(nonatomic) float widthOfView;                                 //view的宽度
@property(nonatomic) float heightOfView;                                //view的高度
@property(nonatomic) float cellVerticalSpacing;                         //垂直cell之间的间距
@property(nonatomic) float cellHorizontalSpacing;                       //横向cell之间的间距
@property(nonatomic) UIEdgeInsets edgeInsets;                           //指定边缘指

- (void)reloadView;

@end

#pragma mark Protocol SubscribeChannelGridViewDelegate
@protocol SubscribeChannelGridViewDelegate <NSObject>

@required
- (void)saveSubscribe;

@end

#pragma mark Protocol SubscribeChannelGridViewDataSource
@protocol SubscribeChannelGridViewDataSource <NSObject>

@required
- (NSMutableArray*)arrayOfInvisibleCell;
- (NSMutableArray*)arrayOfVisibleCell;
- (SubscribeChannelGridViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath;

@end