//
//  BannerViewCell.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-15.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BannerData;


@protocol BanerDateObsever <NSObject>

-(void)imageChanged:(BannerData *)bd;

@end


// 广告数据
@interface BannerData : NSObject
{
    UIImage *img;
    NSString *title;
    __weak ThreadSummary *threadSummary;
}


- (id)initWithThreadSummary:(ThreadSummary *)ts;

@property(nonatomic, readonly) ThreadSummary *threadSummary;
@property(nonatomic, readonly) UIImage *img;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, weak) id<BanerDateObsever> imgChanged;
@property(nonatomic) BOOL isApply; // 标记是否在使用
@end



@interface BannerViewCell : UIView<BanerDateObsever>
{
//    UILabel *title;         // 标题
    UIImageView *imgView;       // 图片视图
    BannerData *bannerData;     // 帖子数据
    UIImageView *_shadowImage;  //视频标志
    BOOL isV;                   //是否展示视频标志
}

@property(nonatomic, readonly)BannerData *bannerData;

- (void)reloadData:(BannerData *)bd isVodel:(BOOL)isVodel;

@end
