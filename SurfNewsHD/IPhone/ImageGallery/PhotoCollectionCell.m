//
//  PhotoCollectionCell.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoCollectionCell.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "ImageDownloader.h"
#import "PhotoCollectionData.h"
#import "CGContextUtil.h"
#import "UIColor+extend.h"
#import "NSString+Extensions.h"


#define Cell_Height 150
#define Cell_Width 300

@implementation PhotoCollectionCell
static UIImage *DefaultIcon = nil;
static UIImage *ImageNumIcon = nil;

+ (float)CellHeight{
    return Cell_Height;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!DefaultIcon) {
            DefaultIcon = [UIImage imageNamed:@"loading"];
            ImageNumIcon = [UIImage imageNamed:@"imageNumIcon"];
        }
        
        _selectedColor = [UIColor colorWithHexValue:0x50FFFFFF]; // zyl 图集点击颜色
        self->contentView.backgroundColor = [UIColor clearColor];
        [self viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect rect = self.frame;
    rect.size.width = Cell_Width;
    self.frame = rect;
    
}



- (void)reloadDateWithPhotoCollection:(PhotoCollection*)pc{
    // 如果本地有缓存，就使用本地缓存，没有就从网络上加载 
    _pc = pc;
    _icon = DefaultIcon;
    _isLoadImage = NO;
    if (pc == nil) {
        return;
    }
    
    // 获取本地Icon路径
    NSString *iconPath = [PathUtil pathOfPhotoCollectionIcon:pc];
    if ([FileUtil fileExists:iconPath]) {
        _icon = [UIImage imageWithContentsOfFile:iconPath];
    }
  
}

- (void)requestImage{
    if (_icon == DefaultIcon && !_isLoadImage) {
        _isLoadImage = YES;
        PhotoCollection *pc = _pc;
        NSString *iconPath = [PathUtil pathOfPhotoCollectionIcon:_pc];
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        task.imageUrl = _pc.imgUrl;
        task.targetFilePath = iconPath;
        task.userData = pc;
        task.imgPriority = kPriority_Higher;
        task.completionHandler = ^(BOOL succeeded,ImageDownloadingTask* t){
            if (succeeded && _pc && t.userData == _pc) {
                _icon = [UIImage imageWithData:[t resultImageData]];
                [self setNeedsDisplay];
            }
        };
        [[ImageDownloader sharedInstance] download:task];
    }
}


- (void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight)
    {
        _bgColor = [UIColor colorWithHexValue:0xFF232426];
    }
    else
    {
        _bgColor = [UIColor colorWithHexValue:0xFFF7F7F7];
    }
    
    if (_icon == DefaultIcon)
    {
        [self setNeedsDisplay];
    }
}

- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    if (_pc == nil) {
        return;
    }

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGRect iconRect = self.bounds;
    if (_icon == DefaultIcon){
        iconRect.size = _icon.size;
        iconRect.origin.x = (CGRectGetWidth(self.bounds)-CGRectGetWidth(iconRect)) * 0.5;
        iconRect.origin.y = (CGRectGetHeight(self.bounds)-CGRectGetHeight(iconRect)) * 0.5;
        
        // 背景颜色
        CGContextSetFillColorWithColor(context, _bgColor.CGColor);
        CGContextFillRect(context, rect);
    }
    
    // 封面图片
    [_icon drawInRect:iconRect];

    
    // 标题
    if (_pc.title.length > 0) {
        // 背景
        float bgHeight = 25.f;
        float beginY = CGRectGetHeight(self.bounds)-bgHeight;
        CGRect bgRect = self.bounds;
        bgRect.origin.y = beginY;
        bgRect.size.height = bgHeight;
        CGContextSetFillColorWithColor(context, [UIColor colorWithHexValue:0xCC2B2B2B].CGColor);
        CGContextFillRect(context, bgRect);        

        // 标题
        float numWidth = 20.f;
        float imgAndNumWidth = numWidth + ImageNumIcon.size.width;
        UIFont *font = [UIFont systemFontOfSize:15.f];
        float dy = (CGRectGetHeight(bgRect) - font.lineHeight ) * 0.5;
        CGRect titleRect = CGRectInset(bgRect, 10, dy);
        titleRect.size.width -= imgAndNumWidth;
//        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//        [_pc.title drawInRect:titleRect withFont:font lineBreakMode:NSLineBreakByTruncatingTail];
        [_pc.title surfDrawString:titleRect
                         withFont:font
                        withColor:[UIColor whiteColor]
                    lineBreakMode:NSLineBreakByTruncatingTail
                        alignment:NSTextAlignmentLeft];
        
        
        // 图标
        CGPoint imgNumIconPoint = CGPointZero;
        imgNumIconPoint.x = titleRect.origin.x + titleRect.size.width;
        imgNumIconPoint.y = beginY + (bgHeight-ImageNumIcon.size.height)*0.5;
        [ImageNumIcon drawAtPoint:imgNumIconPoint];
        
        // 图片个数(zyl)
        float space = 7.f;
        UIFont *numStrFont = [UIFont systemFontOfSize:12.f];
        CGRect imgNumRect = CGRectOffset(titleRect, titleRect.size.width+ImageNumIcon.size.width + space, 0);
        imgNumRect.origin.y = beginY + (bgHeight-numStrFont.lineHeight)*0.5;
        imgNumRect.size = CGSizeMake(numWidth, numStrFont.lineHeight);
//        CGContextSetFillColorWithColor(context, [UIColor colorWithHexValue:0xFFFFFFFF].CGColor);
//        [[NSString stringWithFormat:@"%d",_pc.imgc] drawInRect:imgNumRect withFont:numStrFont
//                                                 lineBreakMode:NSLineBreakByCharWrapping
//                                                     alignment:NSTextAlignmentLeft];
        [[NSString stringWithFormat:@"%d",_pc.imgc]
         surfDrawString:imgNumRect
                withFont:numStrFont
                withColor:[UIColor whiteColor]
            lineBreakMode:NSLineBreakByCharWrapping
                alignment:NSTextAlignmentLeft];
    }
    
    
    // 因图集比较特别，所以就在绘制的表面上绘制一个半透明的蒙板
    if (highlighted)
    {
        CGContextSetFillColorWithColor(context, _selectedColor.CGColor);
        CGContextFillRect(context, rect);
    }
    
    UIGraphicsPopContext();
}
@end
