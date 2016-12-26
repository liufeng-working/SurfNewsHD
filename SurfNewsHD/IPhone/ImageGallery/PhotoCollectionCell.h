//
//  PhotoCollectionCell.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurfTableViewCell.h"



@class PhotoCollection;
@interface PhotoCollectionCell : SurfTableViewCell{

    UIImage *_icon;
    __weak PhotoCollection *_pc;
    BOOL _isLoadImage;
    UIColor *_bgColor;
    UIColor *_selectedColor;  // 选择高亮颜色
}

+ (float)CellHeight;
- (void)reloadDateWithPhotoCollection:(PhotoCollection*)pc;

//这个函数在不TableView滚动完成的时候使用
- (void)requestImage;

@end
