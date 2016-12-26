//
//  PhotoGalleryHeaderView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-8-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCollectionData.h"

@interface PhotoGalleryHeaderItemView : UIControl
{
    UIView *selectedView;
    UILabel *itemLabel;
    BOOL selected;
}

@property(nonatomic, strong) PhotoCollectionChannel *channal;

- (void)setItemSelected;
- (void)setItemUnselected;
- (void)applyTheme;

@end

@interface PhotoGalleryHeaderView : UIView
{
    UIImageView *bgImageView;
    UIScrollView *scrollView;
    NSInteger currentTag;
}

@property(nonatomic, strong) NSArray *channelArray;

- (void)reloadViewWithPhotoChannelArray:(NSArray*)array;
//选择后滑到特定的位置
- (void)scrollToTheLocation:(NSInteger)tag;
//在gridView上点击时滑动的特定位置
- (void)scrollToTheLocationWhenClickGridView:(NSInteger)tag;
//item被点击后区分选中和未选中的状态
- (void)setChannelSelectedWithTag:(NSInteger)tag;
- (void)applyTheme;

@end
