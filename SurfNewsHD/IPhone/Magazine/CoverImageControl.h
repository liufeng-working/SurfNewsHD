//
//  CoverImageControl.h
//  SurfNewsHD
//
//  Created by SYZ on 13-11-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileUtil.h"
#import "ImageDownloader.h"
#import "ImageUtil.h"
#import "PathUtil.h"
#import "GetPeriodicalListResponse.h"
#import "OfflineDownloader.h"

#define NewFlagWidth         40.0f
#define NewFlagHeight        22.0f
#define CoverWidth           120.0f
#define CoverHeight          160.0f
#define ImageWidth           135.0f
#define ImageHeight          180.0f

/**
 SYZ -- 2014/08/11
 CoverImageControl是展示期刊封面的control
 coverImage    显示封面图片
 flag          显示已下载图片或者是新期刊的图片
 loadingImage  默认的封面加载图片
 downloaded    已下载的图片
 isNew         新期刊的图片
 */
@interface CoverImageControl : UIControl
{
    UIImageView *coverImage;
    UIImageView *flag;
    UIImage *loadingImage;
    UIImage *downloaded;
    UIImage *isNew;
}

/**
 SYZ -- 2014/08/11
 有两种大小的期刊封面,在未改版之前有两种size的封面图片
 现在只有一种size,所以现在参数都默认是YES
 */
- (id)initWithCoverBigSize:(BOOL)big;
- (void)loadData:(PeriodicalInfo*)periodical;

@end
