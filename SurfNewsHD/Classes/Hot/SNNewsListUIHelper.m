//
//  SNNewsListUIHelper.m
//  SurfNewsHD
//
//  Created by XuXg on 15/8/13.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNNewsListUIHelper.h"
#import "NSString+Extensions.h"

#define TitleFontSize 16.0f         // 标题字体大小
#define SourceFontSize 12.f         // 来源字体大小
#define EnergyFontSize 9.f          // 正负能量字体大小
#define FontLineSpacing ((IOS7)?3.0f:0.f)



@implementation SNNewsListUIHelper

+ (SNNewsListUIHelper*)sharedInstance
{
    static SNNewsListUIHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [SNNewsListUIHelper new];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        _contentEdge = UIEdgeInsetsMake(20.f, 15.f, 15.f, 15.f); // 上，左，下，右
        _titleFont = [UIFont systemFontOfSize:TitleFontSize];
        _sourceFont = [UIFont systemFontOfSize:SourceFontSize];
        _energyScoreFont = [UIFont systemFontOfSize:EnergyFontSize];
        
        // 无图模式
        _titleAndSourceSpace_noimage = 9.f;        // 标题和来源的间隔
        _digestAndSourceSpace_noimage = 5.f;        // 摘要和来源的间隔
        _titleAndDigestStretchSpace_noimage = 0;    // 标题和摘要的收缩间隔（zyl）
        _digestAndSourceStretchSpace_noimage = 0;
        
        // 有图模式
        _titleAndDigestStretchSpace_image = -2;      // 标题和摘要的收缩间隔（zyl）
        _digestAndSourceStretchSpace_image = -2;     // 摘要和来源的收缩间隔（zyl）
        _imageAndTextSpace_image = 11.f;             // 图片和文字之间的间隔
        _titleAndSourceSpace_image = 9.f;            // 标题和来源之间的间隔
        
        // 多图模式
        _titleAndImagesUDSpace_multiImg = 7.f;       // 标题和图片的上下间隔
        _imagesAndSourceUDSpace_multiImg = 6.f;      // 图片和来源的上下间隔
        _imagesLRSpace_multiImg = 2.5f;              // 图片左右间隔
        
        _contentWidth = kContentWidth-_contentEdge.left-_contentEdge.right;
        
        
        // 底部状态栏的高度
        _footHeight = _sourceFont.lineHeight;
        _verticalSpace = 8.f;       //状态栏距离上方一个UI的距离（只是其中一种距离）
        _footSpace=5.f;             //状态栏内部，每个UI的横向距离
        
        // 新闻图片高度(145*95)图片高宽比 1.53
        // 图片左右间距20px，三图之间的间距为2.5px；单图和三图的图片尺寸一样
        _newsCellImageWidth = (_contentWidth-_imagesLRSpace_multiImg-_imagesLRSpace_multiImg) / 3;
        _newsCellImageHeight = _newsCellImageWidth / 1.53;
        
        
        //【管理后台】新闻列表中单条大图新闻图片尺寸：480x240 图片宽高比 2
        _newsBigImageWidth = _contentWidth;
        _newsBigImageHeight = floor(_contentWidth / 2);
        
        
        // 广告大图尺寸 450*200 图片宽高比 2.25
        _newsAdBigImageWidth = _contentWidth;
        _newsAdBigImageHeight = floor(_contentWidth / 2.25);
    
    }
    return self;
}

// 计算帖子需要多高的显示空间
- (CGFloat)calcHeightWithThreadSummary:(ThreadSummary*)ts
{
    if (!ts) return 0;
    
    // 推测类型
    if (ts.showType == 0) {
        ts.showType = TSShowType_Image_None;
        if (ts.newsUrl && ![ts.newsUrl isEmptyOrBlank]) {
            ts.showType = TSShowType_Image_Only;
        }
    }
    
    
    CGFloat vH = 0;
    switch (ts.showType) {
        case TSShowType_Image_Only: // 单图模式
//            vH =_newsCellImageHeight + _contentEdge.top + _contentEdge.bottom;
            vH = 94;
            vH += 5;//目测下面空间太小，自主加上了5   如果不需要，可以去掉
            break;
        case TSShowType_Image_mutable: // 多图模式
        {
            vH = _newsCellImageHeight;
            vH += _contentEdge.top + _contentEdge.bottom;
            vH += _titleAndImagesUDSpace_multiImg; // 标题和图片之间的间隔
            vH += _imagesAndSourceUDSpace_multiImg; // 图片和底部状态栏的间隔
            vH += _footHeight;      //底部状态栏的高度
            // 标题的绘制高度
            CGSize titleSize =
            [self calcTitleSize:ts.title showWidth:_contentWidth];
            vH += titleSize.height;
            
            break;
        }
        case TSShowType_Image_None://无图
        {
            vH = _contentEdge.top+_contentEdge.bottom;
            vH += _footHeight;
            vH += _verticalSpace;
            CGFloat textWidth = _contentWidth;
            if (ts.isTPlusNews) {
                textWidth -= 15.f;
            }
            
            // 计算title是单行还是双行
            CGSize titleSize =[self calcTitleSize:ts.title showWidth:textWidth];
            vH += titleSize.height;
            
            
            // 禅道4257(bicong) 无图的新闻列表间隔正常，每条无图新闻高度与单图新闻高度相同；
            
            
            
            
            if([ts isBigImageType]){
                vH += _newsBigImageHeight;
                vH += _verticalSpace+1; // 标题和图片之间的间隔
                DJLog(@"广告大图bigImg ：  %@",ts.title);
            }
            
            break;
        }
        case TSShowType_Adver_BigImage:     // 广告大图
        {
            DJLog(@"广告大图：  %@",ts.title);
            CGSize titleSize =
            [self calcTitleSize:ts.title showWidth:_contentWidth];
            vH = titleSize.height + _newsBigImageHeight;
            vH += _contentEdge.top + _contentEdge.bottom;
            vH += _footHeight;
            vH += _verticalSpace; // 标题和图片之间的间隔
            vH += _verticalSpace; // 图片和底部状态栏的间隔
            break;
        }
        case TSShowType_Adver_SmallImage:   // 广告小图
        {
            vH = _newsCellImageHeight + _contentEdge.top + _contentEdge.bottom;;
            break;
        }
        case TSShowType_Special_Image:      // 专题有图片
        {
            for(ThreadSummary *t in ts.special_list){
                vH += [self calcHeightWithThreadSummary:t];
            }
            break;
        }
        case TSShowType_Special_None:// 专题无图片
        {
            for(ThreadSummary *t in ts.special_list){
                vH += [self calcHeightWithThreadSummary:t];
            }
            break;
        }
        default:
            break;
    }
    
    return vH;

}

/**
 *  计算标题的高度
 *
 *  @param title        标题内容
 *  @param contentWidth 显示宽度
 *
 *  @return 返回需要显示的高度
 */
- (CGSize)calcTitleSize:(NSString*)title
              showWidth:(CGFloat)contentWidth
{
    if (!title || [title isEmptyOrBlank]) {
        return CGSizeZero;
    }
    
    CGSize constrainedToSize = CGSizeMake(contentWidth, MAXFLOAT);
    CGFloat titleMaxH = ceil(_titleFont.lineHeight + _titleFont.lineHeight + FontLineSpacing);
    CGSize titleSize =
    [title surfSizeWithFont:_titleFont
          constrainedToSize:constrainedToSize
              lineBreakMode:NSLineBreakByWordWrapping
            fontLineSpacing:FontLineSpacing];
    
    if (titleSize.height > titleMaxH) {
        titleSize.height = titleMaxH;
    }
    return titleSize;
}

// 默认线宽度
+ (CGFloat)lineWidth
{
    return 1.f;
}

// 专题顶部线宽
+ (CGFloat)lineWidthForSpecial
{
    return 4.f;
}
// 新闻图片大小
-(CGSize)newsImageSize
{
    
    return CGSizeMake(_newsCellImageWidth, _newsCellImageHeight);
}

-(CGSize)newsBigImageSize
{
    return CGSizeMake(_newsBigImageWidth, _newsBigImageHeight);
}

-(CGSize)newsAdBigImageSize
{
    return CGSizeMake(_newsAdBigImageWidth, _newsAdBigImageHeight);
}

// 字体行间隔
+(CGFloat)fontLineSpace
{
    return FontLineSpacing;
}
@end
