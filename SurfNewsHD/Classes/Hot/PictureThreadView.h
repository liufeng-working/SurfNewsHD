//
//  PictureThreadView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadsManager.h"
#import "ThemeMgr.h"
#import "ThreadSummary.h"


@class HotChannelsListResponse;
@class VerticallyAlignedLabel;
@interface PictureThreadView : UIView{
    ThreadSummary *threadSum;
    ThreadReadChangedHandler regThread;
    UIImage *threadImg;
    UIImage *hotImage;
    
    // 三张图片新闻使用
    NSMutableDictionary *_images;
    
    // 分割线颜色
    UIColor *lineColor;
    
    NSMutableArray *_imagesTalk;
}

@property(nonatomic) BOOL isFirstCell;
@property(nonatomic,strong)HotChannel * hotchannel;   //用于调用方法，判断是不是视频频道

+ (CGFloat)viewHeight:(ThreadSummary*)ts;
- (void)reloadThreadSummary:(ThreadSummary*)_ts;
//- (void)setHotImage:(UIImage *)hotImg imageName:(NSString*)name;
@end