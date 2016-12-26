//
//  PictureBox.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PictureBoxType){
    PBTypeWeb = 0,          // web
    PBTypeImageContainer,   // 图集类型
};

@interface PictureBox : UIView<UIScrollViewDelegate>


+ (PictureBox*)CreatePictureBox:(NSArray*)pictureArray;

- (void)reloadDataWithArray:(NSArray*)imgArray;
@end




