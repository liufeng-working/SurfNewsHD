//
//  PhotoGalleryHeaderView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-8-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoGalleryHeaderView.h"
#import "PhotoGalleryViewController.h"

#define ItemWidth        54.0f
#define ItemHeight       35.0f
#define ScrollViewOffSet 34.0f

@implementation PhotoGalleryHeaderItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        itemLabel = [[UILabel alloc] initWithFrame:self.bounds];
        itemLabel.backgroundColor = [UIColor clearColor];
        itemLabel.font = [UIFont systemFontOfSize:15.0f];
        [itemLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:itemLabel];
        
        selectedView = [[UIView alloc] initWithFrame:CGRectMake(7.0f, 32.0f, 40.0f, 4.0f)];
        [self addSubview:selectedView];
    }
    return self;
}

- (void)setChannal:(PhotoCollectionChannel *)c
{
    _channal = c;
    
    itemLabel.text = _channal.name;
}

- (void)setItemSelected
{
    selected = YES;
    
    itemLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
    selectedView.backgroundColor = [UIColor colorWithHexString:@"AD2F2F"];
}

- (void)setItemUnselected
{
    selected = NO;
    
    selectedView.backgroundColor = [UIColor clearColor];
    
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        itemLabel.textColor = [UIColor whiteColor];
    } else {
        itemLabel.textColor = [UIColor colorWithHexString:@"34393D"];
    }
}

- (void)applyTheme
{    
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        if (selected) {
            itemLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
        } else {
            itemLabel.textColor = [UIColor whiteColor];
        }
    } else {
        if (selected) {
            itemLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
        } else {
            itemLabel.textColor = [UIColor colorWithHexString:@"34393D"];
        }
    }
}

@end

@implementation PhotoGalleryHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        currentTag = -1;
        
        bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:bgImageView];
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.tag = 1000;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollView];
    }
    return self;
}

- (void)reloadViewWithPhotoChannelArray:(NSArray*)array
{
    _channelArray = array;
    
    for (UIView *view in [scrollView subviews]) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < [_channelArray count]; i ++) {
        PhotoGalleryHeaderItemView *itemView = [[PhotoGalleryHeaderItemView alloc] initWithFrame:CGRectMake(ItemWidth * i, 0.0f, ItemWidth, ItemHeight)];
        itemView.channal = [_channelArray objectAtIndex:i];
        itemView.tag = i;
        [itemView addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [itemView applyTheme];
        [scrollView addSubview:itemView];
    }
    
    //ScrollViewOffSet是多出的一块
    [scrollView setContentSize:CGSizeMake(ItemWidth * [_channelArray count] + ScrollViewOffSet, ItemHeight)];
}

//item被点击时执行的方法
- (void)itemSelected:(id)sender
{
    NSInteger tag = [sender tag];
    if (currentTag == tag) {
        return;
    }
    currentTag = tag;
    
    [self setChannelSelectedWithTag:tag];
    
    
    //做选中的操作
    Class classType = [PhotoGalleryViewController class];
    PhotoGalleryViewController *controller = [self findUserObject:classType];
    if ([controller isKindOfClass:classType]) {
        [controller showPhotoCollectionChanged:_channelArray[tag]];
    }
}

//item被点击后区分选中和未选中的状态
- (void)setChannelSelectedWithTag:(NSInteger)tag
{
    //设置选中和未选中的状态
    for (PhotoGalleryHeaderItemView *view in [scrollView subviews]) {
        if (view.tag == tag) {
            [view setItemSelected];
        } else {
            [view setItemUnselected];
        }
    }
}

//在gridView上点击时滑动的特定位置
- (void)scrollToTheLocationWhenClickGridView:(NSInteger)tag
{
    if (((tag - 6) * ItemWidth + ScrollViewOffSet) < scrollView.contentOffset.x &&
        ((tag - 5) * ItemWidth + ScrollViewOffSet) > scrollView.contentOffset.x) {
        [scrollView setContentOffset:CGPointMake((tag - 5) * ItemWidth + ScrollViewOffSet, 0.0f) animated:YES];
    } else if (tag * ItemWidth < scrollView.contentOffset.x &&
               (tag + 1) * ItemWidth > scrollView.contentOffset.x) {
        [scrollView setContentOffset:CGPointMake(tag * ItemWidth, 0.0f) animated:YES];
    }
}

//选择后滑到特定的位置
- (void)scrollToTheLocation:(NSInteger)tag
{
    if (scrollView.contentOffset.x > tag * ItemWidth) {
        [scrollView setContentOffset:CGPointMake(tag * ItemWidth, 0.0f) animated:YES];
    } else if (((tag - 5) * ItemWidth + ScrollViewOffSet) > scrollView.contentOffset.x) {
        [scrollView setContentOffset:CGPointMake((tag - 5) * ItemWidth + ScrollViewOffSet, 0.0f) animated:YES];
    }
}

- (void)applyTheme
{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        UIImage *image = [UIImage imageNamed:@"hot_gridview_bg_night.png"];
        [bgImageView setImage:[image stretchableImageWithLeftCapWidth:1.0f topCapHeight:0.0f]];
    } else {
        UIImage *image = [UIImage imageNamed:@"hot_gridview_bg.png"];
        [bgImageView setImage:[image stretchableImageWithLeftCapWidth:1.0f topCapHeight:0.0f]];
    }
    
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[PhotoGalleryHeaderItemView class]]) {
            PhotoGalleryHeaderItemView *hView = (PhotoGalleryHeaderItemView*)view;
            [hView applyTheme];
        }
    }
}

@end
