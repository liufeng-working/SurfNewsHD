//
//  SNNewsListUIHelper.h
//  SurfNewsHD
//
//  Created by XuXg on 15/8/13.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsListUIHelper : NSObject {
    
@public
    
    UIFont *_titleFont;         // 标题字体
    UIFont *_sourceFont;        // 来源字体
    UIFont *_energyScoreFont;   // 正负能量字体
    UIEdgeInsets _contentEdge;  // 内容区域边距
    
    // 无图模式
    CGFloat _titleAndSourceSpace_noimage;         // 标题和来源的间隔
    CGFloat _digestAndSourceSpace_noimage;        // 摘要和来源的间隔
    CGFloat _titleAndDigestStretchSpace_noimage;  // 标题和摘要的收缩间隔
    CGFloat _digestAndSourceStretchSpace_noimage; // 摘要和来源之间的收缩间隔
    
    // 有图模式
    CGFloat _titleAndDigestStretchSpace_image;    // 标题和摘要的收缩间隔
    CGFloat _digestAndSourceStretchSpace_image;   // 摘要和来源的收缩间隔
    CGFloat _imageAndTextSpace_image;             // 图片和标题之间的间隔
    CGFloat _titleAndSourceSpace_image;           // 标题和来源之间的间隔
    
    // 多图模式
    CGFloat _titleTopSpace_multiImg;              // 顶部间隔
    CGFloat _titleAndImagesUDSpace_multiImg;      // 标题和图片的上下间隔
    CGFloat _imagesAndSourceUDSpace_multiImg;     // 图片和来源的上下间隔
    CGFloat _imagesLRSpace_multiImg;              // 图片左右间隔
    
    CGFloat _contentWidth; // 用来计算文字的显示宽度
    
    
    // 底部状态栏
    CGFloat _footHeight;        //状态栏的高度
    CGFloat _verticalSpace;     //状态栏距离上方一个UI的距离（只是其中一种距离）
    CGFloat _footSpace;             //状态栏内部，每个UI的横向距离
    
    CGFloat _newsCellImageWidth;// 图片宽度(134*100)
    CGFloat _newsCellImageHeight;
    
    CGFloat _newsBigImageWidth;     // 新闻大图尺寸
    CGFloat _newsBigImageHeight;
    
    CGFloat _newsAdBigImageWidth; // 广告大图尺寸
    CGFloat _newsAdBigImageHeight;
    
}

+ (SNNewsListUIHelper*)sharedInstance;
- (CGFloat)calcHeightWithThreadSummary:(ThreadSummary*)ts;

// 新闻图片大小
-(CGSize)newsImageSize;
-(CGSize)newsBigImageSize;
-(CGSize)newsAdBigImageSize; // 广告大图大小


// 默认线宽度
+ (CGFloat)lineWidth;

// 专题顶部线宽
+ (CGFloat)lineWidthForSpecial;



// 字体行间隔
+(CGFloat)fontLineSpace;


@end
