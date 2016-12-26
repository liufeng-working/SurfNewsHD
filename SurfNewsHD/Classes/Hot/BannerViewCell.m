//
//  BannerViewCell.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-15.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "BannerViewCell.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "ImageUtil.h"

static UIImage* defImg = nil;

@implementation BannerViewCell
@synthesize bannerData;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imgView];
        
        // 加载默认图片 // 80*60
        if (defImg == nil) {
            defImg = [ImageUtil imageCenterWithImage:[UIImage imageNamed:@"loading"]
                                          targetSize:CGSizeMake(frame.size.width, frame.size.height)
                                     backgroundColor:[UIColor colorWithHexValue:KImageDefaultBGColor]];
        }
    }
    return self;
}

- (void)reloadData:(BannerData *)bd isVodel:(BOOL)isVodel
{
    isV = isVodel;
    bannerData = bd;
    bd.imgChanged = self;
    if(bd != nil){
        imgView.image = bd.img;
    }
    else{
        imgView.image = nil;
    }
    
    [self showVodelIcon:isVodel];
}

-(void)imageChanged:(BannerData *)bd
{
    if(bannerData == bd)
        imgView.image = bd.img;
    [self showVodelIcon:isV];
}

-(void)showVodelIcon:(BOOL)isVodel
{
    if (isVodel && imgView.image != defImg) {
        
        if(!_shadowImage) {
            UIImage * image = [UIImage imageNamed:@"movie_shadow2"];
            CGFloat imageW = image.size.width;
            CGFloat imageH = image.size.height;
            CGFloat imageX = (CGRectGetWidth(self.frame) - imageW)/2.0;
            CGFloat imageY = (CGRectGetHeight(self.frame) - imageH)/2.0;
            _shadowImage = [[UIImageView alloc]initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
            _shadowImage.image=image;
            [self addSubview:_shadowImage];
        }
    }
    else {
        [_shadowImage removeFromSuperview];
        _shadowImage = nil;
    }
}

@end



@implementation BannerData

@synthesize img;
@synthesize title;
@synthesize threadSummary;




- (id)initWithThreadSummary:(ThreadSummary *)ts
{
    self = [super init];
    if (self && ts != nil) {
        title = ts.title;
        threadSummary = ts;        
        img = defImg;   // 显示一个默认图片
        
        NSString *imgPath = [PathUtil pathOfThreadLogo:ts];
        NSFileManager* fm = [NSFileManager defaultManager];      
        // 本地没有bannel图片，就需要请求。
        if (![fm fileExistsAtPath:imgPath]) {
            [self requestImage]; // 请求图片数据
        }
    }
    return self;
}


-(void)setIsApply:(BOOL)isApply{
    _isApply = isApply;
    
    if (_isApply) {
        // 从本地数据中加载图片
        NSString *imgPath = [PathUtil pathOfThreadLogo:threadSummary];
        NSFileManager* fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:imgPath]) {
            NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
            img = [UIImage imageWithData:imgData];
        }
        else{
            img = defImg;
        }        
    }
    else{
        img = nil;  //释放内存空间
        img = defImg;
    }
}

// 请求图片
-(void)requestImage{
    if (!threadSummary || threadSummary.imgUrl.length == 0) {
        return;
    }
    
    // 请求图片数据
    NSString *imgPath = [PathUtil pathOfThreadLogo:threadSummary];
    ImageDownloadingTask *task = [ImageDownloadingTask new];
    [task setImageUrl:threadSummary.imgUrl];
    [task setTargetFilePath:imgPath];   // 指定路径，下载完成就会保持图片
    [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
        if(succeeded && idt != nil && [self isApply]){
            img = [UIImage imageWithData:[idt resultImageData]];
            // 通知图片发生改变
            if (self.imgChanged != nil && [self.imgChanged respondsToSelector:@selector(imageChanged:)]) {
                [self.imgChanged imageChanged:self];
            }
        }
    }];
    [[ImageDownloader sharedInstance] download:task];
}

@end
