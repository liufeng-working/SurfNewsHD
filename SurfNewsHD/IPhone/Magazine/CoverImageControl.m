//
//  CoverImageControl.m
//  SurfNewsHD
//
//  Created by SYZ on 13-11-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CoverImageControl.h"

@implementation CoverImageControl

- (id)initWithCoverBigSize:(BOOL)big
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        if (!downloaded)
            downloaded = [UIImage imageNamed:@"downloaded_periodical"];
        if (!isNew)
            isNew = [UIImage imageNamed:@"new_periodical"];
        
        if (big) {
            if (!loadingImage) {
                loadingImage = [ImageUtil imageCenterWithImage:[UIImage imageNamed:@"default_loading_image.png"]
                                                    targetSize:CGSizeMake(ImageWidth, ImageHeight)
                                               backgroundColor:[UIColor colorWithHexValue:KImageDefaultBGColor]];
            }
            
            coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ImageWidth, ImageHeight)];
            coverImage.image = loadingImage;
            [self addSubview:coverImage];
        } else {
            if (!loadingImage) {
                loadingImage = [ImageUtil imageCenterWithImage:[UIImage imageNamed:@"default_loading_image.png"]
                                                    targetSize:CGSizeMake(CoverWidth, CoverHeight)
                                               backgroundColor:[UIColor colorWithHexValue:KImageDefaultBGColor]];
            }
            
            coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CoverWidth, CoverHeight)];
            coverImage.image = loadingImage;
            [self addSubview:coverImage];
        }
    }
    return self;
}

- (void)loadData:(PeriodicalInfo *)periodical
{
    coverImage.image = loadingImage;
    
    if (periodical == nil) {
        return;
    }
    if ([[OfflineDownloader sharedInstance] isIssueOfflineDataReady:periodical.magazineId
                                                              issId:periodical.periodicalId]) {
        if (!flag) {
            flag = [[UIImageView alloc] initWithFrame:CGRectMake(coverImage.frame.size.width - 35.0f, -8.0f, 40.0f, 22.0f)];
            flag.image = downloaded;
            [self addSubview:flag];
        }
    } else if (periodical.isNew == 1) {
        if (!flag) {
            flag = [[UIImageView alloc] initWithFrame:CGRectMake(coverImage.frame.size.width - 35.0f, -8.0f, 40.0f, 22.0f)];
            flag.image = isNew;
            [self addSubview:flag];
        }
    } else {
        if (flag) {
            [flag removeFromSuperview];
            flag = nil;
        }
    }
    
    NSString *imgPath = [PathUtil pathOfPeriodicalLogo:periodical];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:imgPath]) {
        [self loadLocalImageWithPeriodical:periodical];
    } else {
        [self downloadLocalImageWithPeriodical:periodical];
    }
}

//获得本地图片
- (void)loadLocalImageWithPeriodical:(PeriodicalInfo *)per
{
    dispatch_queue_t imagequeue = dispatch_queue_create("syz.imageLoadingQueue", NULL);
    
    __block UIImage *image = nil;
    // Start the background queue
    dispatch_async(imagequeue, ^{
        NSString *imgPath = [PathUtil pathOfPeriodicalLogo:per];
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        image = [UIImage imageWithData:imgData];
        CGSize size = [ImageUtil getImageSizeWithData:imgData];
        dispatch_async(dispatch_get_main_queue(), ^{
            //首先判断图片是否比需要的图片大,再判断是否比需要的小
            if (size.width > ImageWidth * [UIScreen mainScreen].scale &&
                size.height > ImageHeight * [UIScreen mainScreen].scale) {
                image = [ImageUtil imageWithImage:image
                  scaledToSizeWithSameAspectRatio:CGSizeMake(ImageWidth * [UIScreen mainScreen].scale,
                                                             ImageHeight * [UIScreen mainScreen].scale)
                                  backgroundColor:[UIColor clearColor]];
                coverImage.image = image;
            } else if (size.width < ImageWidth * [UIScreen mainScreen].scale &&
                       size.height < ImageHeight * [UIScreen mainScreen].scale) {
                [FileUtil deleteFileAtPath:imgPath];  //删除原来的图片,重新下载
                [self downloadLocalImageWithPeriodical:per];
            } else {
                coverImage.image = image;
            }
        }); //end of main thread queue
    }); //end of imagequeue
    
//    dispatch_release(imagequeue);
}

//从网络上下载图片
- (void)downloadLocalImageWithPeriodical:(PeriodicalInfo *)per
{
    NSString *imgPath = [PathUtil pathOfPeriodicalLogo:per];
    ImageDownloadingTask *task = [ImageDownloadingTask new];
    [task setImageUrl:per.imageUrl];
    [task setUserData:per];
    [task setTargetFilePath:imgPath];
    [task setImageTargetSize:CGSizeMake(ImageWidth, ImageHeight)];
    [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
        if(succeeded && idt != nil && [idt.userData isEqual:per]){
            UIImage *image = [UIImage imageWithData:[idt resultImageData]];
            coverImage.image = image;
        }
    }];
    [[ImageDownloader sharedInstance] download:task];
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    if (controlEvents == UIControlEventTouchUpInside) {
        coverImage.alpha = 0.8f;
    } else {
        coverImage.alpha = 1.0f;
    }
}

#pragma mark Touch
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([touch view] == self && [[event allTouches]count] == 1) {
        CGPoint tp =  [touch locationInView:self];
        CGRect rect = [self bounds];
        if (CGRectContainsPoint(rect, tp)) {
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:0];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:0];
}

@end