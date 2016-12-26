//
//  PhotoGalleryChannelGridView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCollectionData.h"
#import "PhotoCollectionManager.h"

//图集各个频道之间的距离
@interface GalleryChannelGridViewItemSpace : NSObject

@property(nonatomic) CGRect aRect;
@property(nonatomic) CGRect bRect;

@end

//******************************************************************************

//图集频道的各频道的视图
@interface GalleryChannelGridViewItem : UIControl
{
    UILabel *itemNameLabel;
}

@property(nonatomic, strong) PhotoCollectionChannel *galleryChannel;

- (void)applyTheme:(BOOL)isNight;
- (void)setCurrentItemBorder;
- (void)clickEvent;

@end

//******************************************************************************

@protocol PhotoGalleryChannelGridViewDataSource <NSObject>

- (NSInteger)gridViewCurrentIndex;

@end

@protocol PhotoGalleryChannelGridViewDelegate <NSObject>

- (void)gridViewItemClicked:(PhotoCollectionChannel*)channel;

@end

@interface PhotoGalleryChannelGridView : UIView
{
    UIImageView *topImageView;
}

@property(nonatomic, weak) id<PhotoGalleryChannelGridViewDelegate> delegate;
@property(nonatomic, weak) id<PhotoGalleryChannelGridViewDataSource> dataSource;
@property(nonatomic, strong) NSMutableArray *galleryChannelArray;
@property(nonatomic) float widthOfView;                                 //view的宽度
@property(nonatomic) float heightOfView;                                //view的高度
@property(nonatomic) float itemVerticalSpacing;                         //垂直cell之间的间距
@property(nonatomic) float itemHorizontalSpacing;                       //横向cell之间的间距
@property(nonatomic) NSInteger itemCountPerRow;                         //每行放置cell的最大个数
@property(nonatomic) UIEdgeInsets edgeInsets;                           //指定边缘值

- (void)reloadView;
- (void)applyTheme:(BOOL)isNight;

@end
