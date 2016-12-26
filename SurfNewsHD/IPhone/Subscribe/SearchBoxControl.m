//
//  SearchBoxControl.m
//  SurfNewsHD
//
//  Created by SYZ on 13-7-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SearchBoxControl.h"

#define SearchImageWidth   50.0f
#define SearchImageHeight  35.0f

@implementation SearchBoxControl

- (id)initWithFrame:(CGRect)frame tipString:(NSString *)string
{
    self = [super initWithFrame:frame];
    if (self) {
        tipString = string;
        _textFont = [UIFont systemFontOfSize:16.0f];
        
        //获得图片的CGImageRef
        NSString *path = [[NSBundle mainBundle] pathForResource:@"search_subs_channel" ofType:@"png"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        CFDataRef cfdata = CFDataCreate(NULL, [data bytes], [data length]);
        CGDataProviderRef dp = CGDataProviderCreateWithCFData(cfdata);
        CFRelease(cfdata);
        searchImage = CGImageCreateWithPNGDataProvider(dp,
                                                       NULL,
                                                       false,
                                                       kCGRenderingIntentDefault);
        CGDataProviderRelease(dp);
    }
    return self;
}

- (void)setTextFont:(UIFont *)font
{
    if (font == nil) {
        _textFont = [UIFont systemFontOfSize:16.0f];
    } else {
        _textFont = font;
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextClearRect(context, rect);
    CGContextSetInterpolationQuality(context, kCGInterpolationLow);
    
    //绘制背景
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"222223"].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"F3F1F1"].CGColor);
    }
    CGContextFillRect(context, CGRectMake (0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height));
    
    //绘制文字
    if (tipString) {
        CGRect tipRect = CGRectMake(10.0f, (self.bounds.size.height - _textFont.lineHeight) / 2, (self.bounds.size.width - SearchImageWidth - 20.0f), _textFont.lineHeight);
        [tipString surfDrawString:tipRect
                         withFont:_textFont
                        withColor:[UIColor grayColor]
                    lineBreakMode:NSLineBreakByWordWrapping
                        alignment:NSTextAlignmentLeft];
    }
    
    //绘制图片
    CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextDrawImage(context, CGRectMake((self.bounds.size.width - SearchImageWidth), (self.bounds.size.height - SearchImageHeight) / 2, SearchImageWidth, SearchImageHeight), searchImage);
    
    UIGraphicsPopContext();
}

- (void)dealloc
{
    CGImageRelease(searchImage);
}

@end
