//
//  WebPUtil.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "WebPUtil.h"
#import "WebP/decode.h"

static void FreeImageData(void *info, const void *data, size_t size) {
    free((void*)data);
}

@implementation WebPUtil


+(BOOL) convertWebP:(NSString *)srcPath saveAsJpgOrPng:(NSString *)targetPath
{
    return [self convertWebPData:[NSData dataWithContentsOfFile:srcPath] saveAsJpgOrPng:targetPath];
}

+(BOOL) convertWebPData:(NSData *)data saveAsJpgOrPng:(NSString *)targetPath
{
    return [[self convertWebPDataToJpgOrPngData:data] writeToFile:targetPath atomically:YES];
}

+(NSData*) convertWebPDataToJpgOrPngData:(NSData *)data
{
    WebPDecoderConfig config;
    if (!WebPInitDecoderConfig(&config)) {
        return nil;
    }
    
    WebPBitstreamFeatures features;
    WebPGetFeatures([data bytes], [data length], &features);
    
    //注意：大写的RGB表示alpha未预乘，小写的已预乘
    //默认output.colorspace即为MODE_rgbA
    config.output.colorspace = MODE_rgbA;
    config.options.use_threads = true;
    
    // Decode the WebP image data into a RGBA value array.
    if (WebPDecode([data bytes], [data length], &config) != VP8_STATUS_OK) {
        return nil;
    }
    
    int width = config.input.width;
    int height = config.input.height;
    if (config.options.use_scaling)
    {
        width = config.options.scaled_width;
        height = config.options.scaled_height;
    }
    
    // Construct a UIImage from the decoded RGBA value array.
    CGDataProviderRef provider =
    CGDataProviderCreateWithData(NULL, config.output.u.RGBA.rgba,
                                 config.output.u.RGBA.size, FreeImageData);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    
    CGImageRef imageRef =
    CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo,
                  provider, NULL, NO, kCGRenderingIntentDefault);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    //无需调用WebPFreeDecBuffer(config.output.u.RGBA)
    //因为CGDataProviderCreateWithData创建provider时的回调FreeImageData
    //中的实现为free config.output.u.RGBA.rgba
    
    UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if (features.has_alpha)
    {
        return UIImagePNGRepresentation(newImage);
    }
    else
    {
        return UIImageJPEGRepresentation(newImage, 0.9);
    }
}
@end
