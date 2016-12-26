//
//  ImageGalleryViewController.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "PhotoGalleryHeaderView.h"
#import "PhotoGalleryChannelGridView.h"
#import "BgScrollView.h"
#import "ImageLoadModelView.h"
#import "PopMenuView.h"


@class PhotoCollectionListHorizontalScrollView;
@class RIButtonItem;

@interface PhotoGalleryViewController : PhoneSurfController <PhotoGalleryChannelGridViewDelegate,
    PhotoGalleryChannelGridViewDataSource,
    PopMenuViewDelegate,
    BgScrollViewDelegate>
{
    
    PhotoGalleryHeaderView *headerView;
    PhotoGalleryChannelGridView *gridView;
    UIImageView *titleView;
    UILabel *titleLabel;
    UIImageView *expandButtonBg;
    UIButton *expandButton;
    UIButton *collapseButton;
    UIImageView *topImageView;
    UILabel *allChannelsLabel;
    UILabel *clickChannelLabel;
    
    UITableView *_imagesTableView;    
    NSMutableArray *_photoCollectionChannelList;
    
    PhotoCollectionChannel *currentChannel;
    
    BgScrollView  *popBgView;
    PopMenuView  *_popMenu;
    
    
    UIActivityIndicatorView *_hotwheel;
    PhotoCollectionListHorizontalScrollView *_pclhsView;
    UIView*lineView;
}

// 显示的图集频道发生改变(给小司的频道列表View使用)
-(void)showPhotoCollectionChanged:(PhotoCollectionChannel*)pcc;



@end
