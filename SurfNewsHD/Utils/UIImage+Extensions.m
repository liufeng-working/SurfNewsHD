//
//  UIImage+Extensions.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UIImage+Extensions.h"

@implementation UIImage(Extensitons)

+(UIImage*)imageNamedNewImpl:(NSString*)imageName
{
    if (!imageName || [imageName length] == 0 ) {
        return nil;
    }
    
    
    NSMutableString *imageNameMutable = [imageName mutableCopy];
    
    //Delete png extension
    NSRange extension = [imageName rangeOfString:@".png" options:NSBackwardsSearch | NSAnchoredSearch];
    if (extension.location != NSNotFound) {
        [imageNameMutable deleteCharactersInRange:extension];
    }
    
//    NSInteger scale = [[UIScreen mainScreen] scale];
    NSInteger scale = 2;
    if (scale >= 2) {
        NSString *keyword = [NSString stringWithFormat:@"@%@x",@(scale)];
        // 找到@2x关键字
        NSRange retinaAtSymbol = [imageName rangeOfString:keyword];
        if (retinaAtSymbol.location == NSNotFound) {
            NSString *name2x = [imageNameMutable stringByAppendingString:keyword];
            
            // 判断文件是否存在，不存在还要使用默认图片
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:name2x ofType:@"png"];
            if (imagePath != nil && [fm fileExistsAtPath:imagePath]) {
                [imageNameMutable appendString:keyword];
            }
        }
    }


    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:@"png"];
    
    // 在iphone里面，图片都是2倍的图片大
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    return [UIImage imageWithCGImage:img.CGImage
                               scale:scale
                         orientation:UIImageOrientationUp];
}


// 获取合适的启动画面
// 因启动画面使用asset 就不能获取到启动图片
// 参考：http://www.cnblogs.com/ChenYilong/p/4020384.html
+(UIImage*)fitLaunchImage
{
    NSDictionary *imageNames =
    @{@"480" : @"LaunchImage.png",                //  320 × 480
      @"960" : @"LaunchImage@2x.png",             //  640 × 960
      //      @"1136": @"LaunchImage-700@2x.png",         //  640 × 960
      @"1136": @"LaunchImage-568h@2x.png",        //  640 × 1136
      //      @"1136": @"LaunchImage-700-568h@2x.png",    //  640 × 1136
      @"1334": @"LaunchImage-800-667h@2x.png",    //  750 × 1334
      @"2208": @"LaunchImage-800-Portrait-736h@3x.png"};// 1242 × 2208
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat screenHeight = CGRectGetHeight([screen bounds]);
    NSString *imgKey = [NSString stringWithFormat:@"%@",@(floorf(screenHeight*[screen scale]))];
    return [UIImage imageNamed:[imageNames objectForKey:imgKey]];
}
@end
