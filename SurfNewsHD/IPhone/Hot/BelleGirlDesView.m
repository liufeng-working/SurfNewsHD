//
//  BelleGirlDesView.m
//  SurfNewsHD
//
//  Created by XuXg on 15/11/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "BelleGirlDesView.h"
#import "ThreadsManager.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "UIImage+Extensions.h"



@implementation LikeBelleGirlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!loveIconImageView) {
            loveIconImageView = [[UIImageView alloc] initWithFrame:self.bounds];
            loveIconImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|
            UIViewAutoresizingFlexibleHeight;
            UIImage *img = [UIImage imageNamed:@"pictuer_praise2"];
            CGFloat top = 0;        // 顶端盖高度
            CGFloat bottom = 0 ;    // 底端盖高度
            CGFloat left = 14;      // 左端盖宽度
            CGFloat right = 5;      // 右端盖宽度
            UIEdgeInsets insets =
            UIEdgeInsetsMake(top, left, bottom, right);
            // 指定为拉伸模式，伸缩后重新赋值
            UIImage *stretchImg = [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
            
            [loveIconImageView setImage:stretchImg];
            [self addSubview:loveIconImageView];
        }
        
        if (!loveValue) {
            loveValue = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 10, self.bounds.size.height)];
            [loveValue setBackgroundColor:[UIColor clearColor]];
            [loveValue setFont:[UIFont systemFontOfSize:12]];
            [loveValue setTextAlignment:NSTextAlignmentCenter];
            [loveValue setTextColor:[UIColor redColor]];
            [self addSubview:loveValue];
        }
        
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        [bt setFrame:self.bounds];
        [bt setBackgroundColor:[UIColor clearColor]];
        [bt addTarget:self action:@selector(clickBt) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bt];
    }
    return self;
}

- (void)clickBt
{
    if ([_delegate respondsToSelector:@selector(setLikeGirlLoveValue)]) {
        [_delegate setLikeGirlLoveValue];
    }
}

- (void)setLoveValue:(NSInteger)loveValueint
{
    if([loveValue.text integerValue] == loveValueint) {
        return;
    }
    
    [loveValue setText:[NSString stringWithFormat:@"%@", @(loveValueint)]];
    
    
    CGFloat height = CGRectGetHeight(self.bounds);
    CGPoint center = self.center;
    CGSize vSize = [loveValue sizeThatFits:CGSizeMake(0, height)];
    vSize.width += 10.f;
    [loveValue setFrame:CGRectMake(10, 0, vSize.width, vSize.height)];

    vSize.width += 10.f;
    [self setFrame:CGRectMake(0, 0, vSize.width, vSize.height)];
    self.center = center;
}

@end








@implementation BelleGirlDesView

static UIImage *defaultImage = nil;
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        if (!mainScrollView) {
            mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
            mainScrollView.delegate=self;
            mainScrollView.backgroundColor = [UIColor clearColor];
            mainScrollView.scrollsToTop = NO;
//            mainScrollView.bounces = YES;
            [mainScrollView setShowsVerticalScrollIndicator:NO];
            [mainScrollView setShowsHorizontalScrollIndicator:NO];
            mainScrollView.contentSize = CGSizeMake(self.frame.size.width + 50, kScreenHeight);
            
            [self addSubview:mainScrollView];
        }
        
        if (!defaultImage) {
            defaultImage = [UIImage imageNamedNewImpl:@"default_loading_image"];
        }
        
        if (!_belleImageView) {
            _belleImageView = [[UIImageView alloc] initWithImage:defaultImage];
            [mainScrollView addSubview:_belleImageView];
            _belleImageView.center = self.center;
        }
        
        
        [self initLikeGirlView];
    }
    
    return self;
}


-(void)setThread:(ThreadSummary *)thread
{
    _thread = thread;
    _img = nil;
    _belleImageView.image = nil;
    [likeView setLoveValue:_thread.intimacyDegree];
    mainScrollView.contentOffset = CGPointZero;
    mainScrollView.contentSize = self.bounds.size;
    [self loadingBeautyImage];
}

// 更新状态
-(void)updateState
{
    [likeView setLoveValue:_thread.intimacyDegree];
}
// 加载美女图片
-(void)loadingBeautyImage
{
    NSString *imgPath = [PathUtil pathOfThreadLogo:_thread];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // 图片文件不存在
    if (![fm fileExistsAtPath:imgPath])
    {
        // 给一个默认图片
        CGPoint centerP = mainScrollView.center;
        centerP.y -= 50.f;
        _belleImageView.image = defaultImage;
        [_belleImageView sizeToFit];
        _belleImageView.center = centerP;
        CGFloat sW = CGRectGetWidth(mainScrollView.bounds);
        CGFloat sH = CGRectGetHeight(mainScrollView.bounds);
        mainScrollView.contentSize = CGSizeMake(sW +2, sH);
        
        
        // 请求图片数据
        if (_thread.imgUrl && ![_thread.imgUrl isEmptyOrBlank])
        {
            ImageDownloadingTask *task = [ImageDownloadingTask new];
            [task setImageUrl:_thread.imgUrl];
            [task setUserData:_thread];
            [task setTargetFilePath:imgPath];
            [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
                if(succeeded && idt && _thread == idt.userData){
                    _img = [UIImage imageWithData:idt.resultImageData];
                    [self setBelleGirlImageView];
                }
            }];
            
            [[ImageDownloader sharedInstance] download:task];
        }
    }
    else{
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        _img = [UIImage imageWithData:imgData];
        
        [self setBelleGirlImageView];
    }
}

- (void)setBelleGirlImageView
{
    if (!_img) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(mainScrollView.bounds);
    CGFloat height = CGRectGetHeight(mainScrollView.bounds);
    CGSize imgSize = [self getImageSize];
    CGFloat imgW = imgSize.width;
    CGFloat imgH = imgSize.height;
    
    if (imgW < width) {
        // 不加2，在默认图片的适合不能滑动
        mainScrollView.contentSize = CGSizeMake(width+2, height);
    }
    else {
        mainScrollView.contentSize = CGSizeMake(imgW, height);
    }
    
    [_belleImageView setImage:_img];
    [_belleImageView setFrame:CGRectMake(0, 0, imgW, imgH)];
    CGFloat offX = mainScrollView.contentSize.width / 2;
    _belleImageView.center = CGPointMake(offX, height/2);
    
    
    // 上面的设置保证的内容区域大于窗口的大小
    offX = (mainScrollView.contentSize.width - width)/2;
    [mainScrollView setContentOffset:CGPointMake(offX, 0) animated:NO];
    
        
    
    
}

- (void)initLikeGirlView
{
    if (!likeView) {
        likeView = [[LikeBelleGirlView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 100, 50, 80, 16)];
        likeView.loveCenter=likeView.center;
        [likeView setDelegate:self];
        [likeView setBackgroundColor:[UIColor clearColor]];
        [likeView setLoveValue:_thread.intimacyDegree];
        [self addSubview:likeView];
    }
}

- (CGSize)getImageSize{
    NSString *dm = _thread.dm;
    NSRange range = [dm rangeOfString:@"*"];
    
    float image_W = [[dm substringWithRange:NSMakeRange(0, range.location)] intValue] / 2;
    float image_H = [[dm substringFromIndex:range.location + 1] intValue] / 2;
    
    float hh = image_H / image_W;
    belleimage_H = kScreenHeight;
    belleimage_W = belleimage_H / hh;
    
    return CGSizeMake(belleimage_W, belleimage_H);
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    CGFloat maxOFFX = mainScrollView.contentSize.width - CGRectGetWidth(mainScrollView.bounds);
    if (mainScrollView.contentOffset.x > maxOFFX + 50){
        if ([_delegate respondsToSelector:@selector(nextRight)]) {
            [_delegate nextRight];
        }
    }
    else if (mainScrollView.contentOffset.x < -50){
        if ([_delegate respondsToSelector:@selector(nextRight)]) {
            [_delegate priorLeft];
        }
    }
}

#pragma mark LikeBelleGirlViewDelegate
- (void)setLikeGirlLoveValue
{
    if ([_delegate respondsToSelector:@selector(didBelleGirlDesViewToolBarBelleGirlBt:)]) {
        [_delegate didBelleGirlDesViewToolBarBelleGirlBt:_thread];
    }
}

@end


@implementation BelleGirlView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *actionBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [actionBt setFrame:self.bounds];
        [actionBt addTarget:self action:@selector(UserClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:actionBt];
        
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        [bgView setBackgroundColor:[UIColor whiteColor]];
        [bgView setAlpha:0.8];
        bgView.center = self.center;
        [self addSubview:bgView];
        
        UIButton *hateBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [hateBt setTag:Belle_hate];
        [hateBt setFrame:CGRectMake(10, 15, 180, 30)];
        [hateBt setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"] forState:UIControlStateNormal];
        [hateBt setTitle:@"不喜欢" forState:UIControlStateNormal];
        [hateBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [hateBt.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [hateBt addTarget:self action:@selector(clickMenuBt:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:hateBt];
        
        UIButton *reportBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [reportBt setTag:Belle_report];
        [reportBt setFrame:CGRectMake(10, 60, 180, 30)];
        [reportBt setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"] forState:UIControlStateNormal];
        [reportBt setTitle:@"举 报" forState:UIControlStateNormal];
        [reportBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [reportBt.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [reportBt addTarget:self action:@selector(clickMenuBt:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:reportBt];
    }
    return self;
}


- (void)UserClicked:(id)sender{
    if ([_delegate respondsToSelector:@selector(removeBelleView:)]) {
        [_delegate removeBelleView:self];
    }
}

- (void)clickMenuBt:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(clickBt:)]) {
        [_delegate clickBt:sender.tag];
    }
    
    if ([_delegate respondsToSelector:@selector(removeBelleView:)]) {
        [_delegate removeBelleView:self];
    }
}

@end
