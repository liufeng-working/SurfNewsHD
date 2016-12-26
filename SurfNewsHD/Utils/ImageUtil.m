//
//  ImageUtil.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-2-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ImageUtil.h"
#import <ImageIO/ImageIO.h>

@implementation ImageUtil

+(BOOL)isImage:(NSData*)data
{
    return [self guessImageType:data] != UnknownImage;
}

+(ImageType)guessImageType:(NSData*)data
{
    const char* bytes = data.bytes;
    
    //  {[]byte("\xff\xd8\xff\xe2"), "image/jpeg"},
    //	{[]byte("\xff\xd8\xff\xe1"), "image/jpeg"},
    //	{[]byte("\xff\xd8\xff\xe0"), "image/jpeg"},
    //	{[]byte("\xff\xd8\xff\xdb"), "image/jpeg"},
    
    if ([data length] > 10 && //第6～9字节为JFIF
        bytes[6] == 0x4a &&
        bytes[7] == 0x46 &&
        bytes[8] == 0x49 &&
        bytes[9] == 0x46)
        return JpgImage;
    else if ([data length] > 4 &&
             (UInt8)bytes[0] == 0xff &&
             (UInt8)bytes[1] == 0xd8 &&
             (UInt8)bytes[2] == 0xff &&
             ((UInt8)bytes[3] == 0xe2 ||
              (UInt8)bytes[3] == 0xe1 ||
              (UInt8)bytes[3] == 0xe0 ||
              (UInt8)bytes[3] == 0xdb))
        return JpegImage;
    else if ([data length] > 4 && //0x89 PNG - 文件头标识 (8 bytes)   89 50 4E 47 0D 0A 1A 0A
             (UInt8)bytes[0] == 0x89 &&
             (UInt8)bytes[1] == 0x50 &&
             (UInt8)bytes[2] == 0x4e &&
             (UInt8)bytes[3] == 0x47)
        return PngImage;
    else if ([data length] > 6 &&  //GIF89a/GIF87a
             bytes[0] == 0x47 &&
             bytes[1] == 0x49 &&
             bytes[2] == 0x46 &&
             bytes[3] == 0x38 &&
             (bytes[4] == 0x39 || bytes[4] == 0x37) &&
             bytes[5] == 0x61)
        return GifImage;
    else if ([data length] > 2 && //BM
             bytes[0] == 0x42 &&
             bytes[1] == 0x4d)
        return BmpImage;
    else if([data length] > 12 &&   //RIFF____WEBP
            bytes[0] == 0x52 &&
            bytes[1] == 0x49 &&
            bytes[2] == 0x46 &&
            bytes[3] == 0x46 &&
            bytes[8] == 0x57 &&
            bytes[9] == 0x45 &&
            bytes[10] == 0x42 &&
            bytes[11] == 0x50)
        return WebpImage;
    else
        return UnknownImage;
}

// 缩放图片大小，并保持图片比例
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
           backgroundColor:(UIColor*)bgColor
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    NSInteger targetWidth = targetSize.width;
    NSInteger targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointZero;
    
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = heightFactor;
        }
        else {
            scaleFactor = widthFactor;
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {            
            thumbnailPoint.x = ceil((targetWidth - scaledWidth) * 0.5);
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.y = ceil((targetHeight - scaledHeight) * 0.5);
        }
    }
    
    
    // 图片信息
    CGImageRef imageRef = [sourceImage CGImage];
//    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
//    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
//    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();

    
//    if (bitmapInfo == kCGImageAlphaNone) {
//        bitmapInfo = kCGImageAlphaNoneSkipLast;
//    }

    
    CGContextRef bitmap;
//    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
//    size_t perRow = CGImageGetBytesPerRow(imageRef);
//    if (sourceImage.imageOrientation == UIImageOrientationUp ||
//        sourceImage.imageOrientation == UIImageOrientationDown) {
 
//        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight,
//                                       bitsPerComponent,
//                                       targetWidth * 4,
//                                       colorSpaceRef, bitmapInfo);
        
//        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight,
//                                       bitsPerComponent,
//                                       perRow,
//                                       colorSpaceRef, bitmapInfo);
//    data                 指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
//    width                bitmap的宽度,单位为像素
//    height               bitmap的高度,单位为像素
//    bitsPerComponent     内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
//    bytesPerRow          bitmap的每一行在内存所占的比特数
//    colorspace           bitmap上下文使用的颜色空间。
//    bitmapInfo           指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
    
    bitmap = [ImageUtil createContextRef:targetSize bgColor:[bgColor CGColor]];    

    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;        
        CGFloat angle = M_PI_2; //         
        CGContextRotateCTM (bitmap, angle);
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation ==UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        CGContextRotateCTM (bitmap, -M_PI_2);
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown){
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, M_PI);
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x,thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    

    CGImageRelease(ref);
    CGContextRelease(bitmap);
    return newImage;
}


// 创建一个指定大小的图片，原图片指定在图片的中间
+ (UIImage*)imageCenterWithImage:(UIImage*)sourceImage
                      targetSize:(CGSize)targetSize
                 backgroundColor:(UIColor*)bgColor
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    NSInteger targetWidth = targetSize.width;
    NSInteger targetHeight = targetSize.height;
    CGPoint thumbnailPoint = CGPointMake((targetWidth - width) * 0.5f, (targetHeight - height) * 0.5f);
    
    
    // 图片信息
    CGImageRef imageRef = [sourceImage CGImage];    
    CGContextRef bitmap = [ImageUtil createContextRef:targetSize bgColor:[bgColor CGColor]];

    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x,thumbnailPoint.y, width, height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGImageRelease(ref);
    CGContextRelease(bitmap);
    return newImage;
}

+ (CGContextRef)createContextRef:(CGSize)size
                         bgColor:(CGColorRef)colorRef
{
    CGFloat scaleFactor = [[UIScreen mainScreen] scale];
    CGFloat width = size.width * scaleFactor;
    CGFloat height = size.height * scaleFactor;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef bgColorRef = colorRef;
    CGContextRef contextRef;
    contextRef = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpaceRef,
                                      kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    
    CFRelease(colorSpaceRef);
    CGContextScaleCTM(contextRef, scaleFactor, scaleFactor);
    CGContextSetFillColorWithColor(contextRef, bgColorRef);
    CGContextFillRect(contextRef, CGRectMake(0.f, 0.f,size.width, size.height));
    return contextRef;
}

+ (CGSize)getImageSize:(NSString*)path
{
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], NULL);
    
    //unsupported image file
    if(!source)
        return CGSizeZero;
    
    CFDictionaryRef propDict = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    CFNumberRef height = CFDictionaryGetValue(propDict, kCGImagePropertyPixelHeight);
    CFNumberRef width = CFDictionaryGetValue(propDict, kCGImagePropertyPixelWidth);
    CFRelease(propDict);
    
    NSInteger x = 0,y = 0;
    
    //CFNumberGetType(height) == kCFNumberSInt32Type
    CFNumberGetValue(height, CFNumberGetType(height), &y);
    CFNumberGetValue(width, CFNumberGetType(width), &x);
    CFRelease(source);
    
    return CGSizeMake(x, y);
}

+ (CGSize)getImageSizeWithData:(NSData*)data
{
    CFDataRef cfdata = CFDataCreate(NULL, [data bytes], [data length]);
    CGImageSourceRef source = CGImageSourceCreateWithData(cfdata, NULL);
    CFRelease(cfdata);
    
    //unsupported image file
    if(!source)
        return CGSizeZero;
    
    CFDictionaryRef propDict = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    CFNumberRef height = CFDictionaryGetValue(propDict, kCGImagePropertyPixelHeight);
    CFNumberRef width = CFDictionaryGetValue(propDict, kCGImagePropertyPixelWidth);
    CFRelease(propDict);
    
    NSInteger x = 0,y = 0;
    
    //CFNumberGetType(height) == kCFNumberSInt32Type
    CFNumberGetValue(height, CFNumberGetType(height), &y);
    CFNumberGetValue(width, CFNumberGetType(width), &x);
    CFRelease(source);
    
    return CGSizeMake(x, y);
}

// 截取UIView的图片
+ (UIImage*)ScreenShots:(UIView*)view{    
    CGSize size = view.bounds.size;
    float scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
