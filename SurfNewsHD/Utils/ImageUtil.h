//
//  ImageUtil.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-2-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    JpgImage = 0,
    JpegImage,
    PngImage,
    BmpImage,
    GifImage,
    WebpImage,
    UnknownImage = 127
} ImageType;

@interface ImageUtil : NSObject

//判断是否是有效的图片格式
//即ImageType != UnknownImage
+(BOOL)isImage:(NSData*)data;

//判断图片格式
+(ImageType)guessImageType:(NSData*)data;

// 缩放图片大小，并保持图片比例,
// 如果backgroundColor = nil ，默认背景颜色是白色
+ (UIImage*)imageWithImage:(UIImage*)sourceImage
scaledToSizeWithSameAspectRatio:(CGSize)targetSize
           backgroundColor:(UIColor*)bgColor;



// 创建一个指定大小的图片，原图片指定在图片的中间
+ (UIImage*)imageCenterWithImage:(UIImage*)sourceImage
                targetSize:(CGSize)targetSize
           backgroundColor:(UIColor*)bgColor;

//快速获取某个图片的长宽
+ (CGSize)getImageSize:(NSString*)path;
+ (CGSize)getImageSizeWithData:(NSData*)data;


// 截取UIView的图片
+ (UIImage*)ScreenShots:(UIView*)view;

@end
