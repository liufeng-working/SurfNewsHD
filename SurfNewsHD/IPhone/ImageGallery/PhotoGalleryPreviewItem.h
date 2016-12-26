//
//  PhotoGalleryPreviewItem.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-10-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoCollectionCell;
@class PreviewPhotoCollectionData;


@protocol PhotoGalleryPreviewItemDelegate <NSObject>
@required
-(void)notifySelectPhotoCollection:(PhotoCollection*)pc;

@end



// 图集预览图片，给PictureBox使用
@interface PhotoGalleryPreviewItem : UIView{
    UIImage *_defalutIcon;
    UIScrollView * _scrollView;
}

@property(nonatomic,weak) id<PhotoGalleryPreviewItemDelegate> delegate;
@property(nonatomic,readonly)PreviewPhotoCollectionData *photoCollectionData;

- (void)loadPreviewData:(PreviewPhotoCollectionData*)data;





@end



///////////////////////////////////////////////////////////////
// 预览图集列表数据
///////////////////////////////////////////////////////////////
@interface PreviewPhotoCollectionData : NSObject{
    NSMutableArray* _photoCollectionList;  // 预览图集列表
    
    
}

@property(nonatomic,strong) PhotoCollection* curPhotoCollection;       // 当前图集
@property(nonatomic,weak) PhotoCollection* selectPhotoCollection;    // 选择的图集，默认为第一个


- (NSUInteger)PhotoCollectionListCount;
-(void)addPhotoCollectionList:(NSArray*)pcList;
-(void)clearPhotoCollectionList;
-(PhotoCollection*)getPhotoCollectionAtIndex:(NSUInteger)index;
-(BOOL)isContainsPhotoCollection:(PhotoCollection*)pc;
@end

