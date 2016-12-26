//
//  GuideViewController.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GuideViewController.h"

#define kGuideCount 1


@interface GuideView () {
    
    BOOL _isRemoveAction;
}

@end
@implementation GuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initScrollView];
    }
    return self;
}

- (void)setStateHidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)initScrollView
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGRect sR = CGRectMake(0, 0, 120, kScreenHeight-100);
    _pageScroll = [[UIScrollView alloc] initWithFrame:sR];
    _pageScroll.delegate = self;
    _pageScroll.pagingEnabled = YES;
    _pageScroll.backgroundColor = [UIColor clearColor];
    _pageScroll.scrollsToTop = YES;
    _pageScroll.bounces = NO;
    [_pageScroll setShowsVerticalScrollIndicator:NO];
    [_pageScroll setShowsHorizontalScrollIndicator:NO];
    _pageScroll.contentSize = CGSizeMake(width*(kGuideCount+1), kScreenHeight);

    for (NSInteger i = 0; i < kGuideCount; i++) {
        // 加载图片
//        NSString *imgName = [NSString stringWithFormat:@"guide_long_%@", @(i + 2)];
        
        NSString *imgName = @"guide_long_3";
        UIImage *img = [UIImage imageNamed:imgName];
        
        //让图片完整显示，不进行裁剪
//        if (img && [img size].height != kScreenHeight) {
//            img = [self getImageFromImage:img];
//        }
        
        // 创建ImageVIew;
        UIImageView *image =
        [[UIImageView alloc] initWithFrame:CGRectMake(width*i, 0, width, kScreenHeight)];
        [image setImage:img];
        [self.pageScroll addSubview:image];
        
    }
    [self addSubview:self.pageScroll];
    

    // 显示动画
    [UIView beginAnimations:@"animationName" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3]; //动画持续的秒数
    [UIView setAnimationDidStopSelector:@selector(setStateHidden)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [_pageScroll setFrame:CGRectMake(0, 0, width, kScreenHeight)];
    [UIView commitAnimations];

}

//裁剪上下多余区域
-(UIImage *)getImageFromImage:(UIImage*) superImage
{
    if(!superImage)
        return nil;
    
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat imgY = superImage.size.height - height;
    CGSize subImageSize = CGSizeMake(width, height);
    
    //定义裁剪的区域相对于原图片的位置
    CGRect subImageRect = CGRectMake(0, imgY, width*scale, height*scale);
    CGImageRef imageRef = superImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
    UIGraphicsBeginImageContext(subImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subImageRect, subImageRef);
    UIImage* subImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    //返回裁剪的部分图像
    return subImage;
}


- (void)removeView
{
    if (!_isRemoveAction) {
        _isRemoveAction = YES;
        
        
        [UIView animateWithDuration:0.5 animations:^{
            [self setFrame:CGRectMake(-320, 0, 320, kScreenHeight)];
        } completion:^(BOOL finished) {
            [self guideHidden];
        }];
        
    }
    
}

- (void)guideHidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    if ([self.guideDelegate respondsToSelector:@selector(finishLoadGuideView)])
    {
        [self.guideDelegate finishLoadGuideView];
    }
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.1];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)pageScroll
{
    if (self.pageScroll == pageScroll) {
        CGFloat offsetX   = self.pageScroll.contentOffset.x;
        self.bgScrollView.contentOffset = CGPointMake(floorf(offsetX), 0);
        if (self.pageScroll.contentOffset.x > 320*(kGuideCount-1) + 50) {
            [self removeView];
        }
        else if(self.pageScroll.contentOffset.x <= 0)
        {
            [self.pageScroll setFrame:CGRectMake(0, 0, 320, kScreenHeight)];
        }
    }
}


@end
