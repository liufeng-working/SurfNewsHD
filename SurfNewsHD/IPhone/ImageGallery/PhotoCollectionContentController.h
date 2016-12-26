//
//  PhotoCollectionContent.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "PictureBox.h"
#import "PhoneWeiboController.h"

@class PhotoCollection;

@interface PhotoCollectionContentController : PhoneWeiboController <PictureBoxDelegate> {
    PictureBox *_pictureBox;
    
}
//@property(nonatomic,strong) PhotoCollectionChannel* pcc;    // 图集频道
@property(nonatomic,strong) PhotoCollection* photoColl;     // 图集
@end
