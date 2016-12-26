//
//  PictureBox.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadContentResolver.h"
#import "PhotoGalleryPreviewItem.h"

@class PictureItem;

typedef NS_ENUM(NSInteger, PictureBoxType){
    PBTypeWeb = 0,          // web
    PBTypeImageContainer,   // 图集类型
};


// 图片浏览模式的业务逻辑
@protocol PictureBoxDelegate <NSObject>

@optional

// 浏览模式展示完成
- (void)pictureBoxShowFinish;

@end


/////////////////////////////////////////////////////////////////
// PictureBox
/////////////////////////////////////////////////////////////////
// 只有浏览器使用高清图片
typedef enum
{
    PictureTypeHighDefinition,          // 高清模式
    PictureTypeGeneral,                 // 一般图片
} PictureType;

typedef enum
{
    PictureBoxNone,
    PictureBoxPhotoCollection
} PictureBoxModel;


@interface PictureBox : UIView<UIScrollViewDelegate, UIGestureRecognizerDelegate, PhotoGalleryPreviewItemDelegate>{
    
    PictureBoxModel _model;
    BOOL isHightDefinition;//是否支持高清
    BOOL isDownLoadingImage;
}

@property(nonatomic)PictureType pictureType;
@property(nonatomic,weak)id<PictureBoxDelegate> delegate;
@property(nonatomic,strong)NSString *shareUrl;


// 正对正文图片使用
//isHightDefinition 是否支持高清
- (void)reloadDataWithImageInfoV2Array:(NSString*)title
                            imageArray:(NSArray*)imgArray
                            imageIndex:(NSUInteger)imgIdx
                     isHightDefinition:(BOOL)hight;

// 针对图集使用
- (void)reloadDataWithPhotoDateArray:(PhotoCollection*)pc;

// 图片发生改变
- (void)notifyImageInfoChenged:(ThreadContentImageInfoV2*)imgInfo;

// 通知图片加载进度
-(void)notifyImageLoadingProgress:(ThreadContentImageInfoV2*)imgInfo;
@end




