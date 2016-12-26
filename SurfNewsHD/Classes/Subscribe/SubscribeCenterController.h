//
//  SubscribeRootController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "SubsChannelsManager.h"
#import "GetSubsCateResponse.h"
#import "SubsChannelsListResponse.h"
#import "SubscribeCenterCell.h"
#import "SubscribeChannelGridView.h"
#import "SearchResultView.h"


@interface SearchSubscribeView : UIView
{
    UITextField *searchField;
}

@property(nonatomic, strong) UITextField *searchField;

- (id)initWithFrame:(CGRect)frame controller:(id)controller;

@end

@interface SubscribeCenterController : SurfNewsViewController<UITableViewDataSource,
UITableViewDelegate,SubscribeCenterCellDelegate,
ImageDownloaderDelegate,
SubscribeChannelGridViewDataSource,
SubscribeChannelGridViewDelegate,
SubsChannelChangedObserver>
{
    SubscribeChannelGridView *gridView;
    
    NSMutableArray *subsChannels;
    UIView *subscribView;
    UIImageView *imageView;
    UITableView *tableview;
    
    SearchSubscribeView *searchView;
    UIView *searchBackgroundView;
    
    SearchResultView *searchResultView;
    
    int currentShowCategory;
    
    UIControl *shadowHead;
    UIControl *shadowFoot;
    
    SubscribeImagePool *imgPool;
    
    BOOL gridViewShow;
    
    UIImageView *refreshImage;
}
-(void)loadCategories;
- (void)mySubscribe:(UIButton*)button;
@end
