//
//  UIFont+Surf.m
//  SurfNewsHD
//
//  Created by XuXg on 15/4/27.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "UIFont+Surf.h"
#import <CoreText/CTFontManager.h>

@implementation UIFont (Surf)


// test 自定义字体
//{
//    NSString* DFGirlPath =
//    [[NSBundle mainBundle] pathForResource:@"DFGirl-W6-WIN-BF" ofType:@"TTF"];
//    NSString* heitiPath = [[NSBundle mainBundle] pathForResource:@"huakan_W4" ofType:@"TTC"];
//    
//    NSMutableArray *customFontsPath = [[NSMutableArray alloc] init];
//    [customFontsPath addObject:heitiPath];
//    [customFontsPath addObject:DFGirlPath];
//    
//    [UIFont loadCustomFont:customFontsPath];
//}
+ (void)loadCustomFont:(NSMutableArray *)customFontFilePaths
{
    for(NSString *fontFilePath in customFontFilePaths)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:fontFilePath]){
            NSData *inData = [NSData dataWithContentsOfFile:fontFilePath];
            CFErrorRef error;
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
            CGFontRef font = CGFontCreateWithDataProvider(provider);
//             NSString *fontName = (__bridge NSString *)CGFontCopyFullName(font);
            if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                NSLog(@"Failed to load font: %@", errorDescription);
                CFRelease(errorDescription);
            }
            CFRelease(font);
            CFRelease(provider);
        }
    }
}



// 自定义应用字体
//http://www.2cto.com/kf/201306/217730.html
// 添加字体 http://jingyan.baidu.com/article/8065f87febc939233124981b.html
// http://blog.csdn.net/justinjing0612/article/details/8093985
// 字体网站 http://www.webpagepublicity.com/free-fonts.html
+ (UIFont*)surfFont:(CGFloat)size
{
    return [UIFont fontWithName:@"HiraKakuProN-W3" size:size];
}
@end
