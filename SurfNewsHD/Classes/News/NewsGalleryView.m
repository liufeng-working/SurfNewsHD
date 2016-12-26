//
//  NewsGalleryView.m
//  SurfNewsHD
//
//  Created by apple on 13-1-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NewsGalleryView.h"
#import "AppDelegate.h"
#import "SurfRootViewController.h"

@implementation NewsGalleryView
#define kAnimationTime 0.5

+(NewsGalleryView*)sharedInstance
{
    static NewsGalleryView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIViewController *viewController = appDelegate.window.rootViewController;
        sharedInstance = [[NewsGalleryView alloc] initWithFrame:viewController.view.bounds];
        sharedInstance.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    });
    
    return sharedInstance;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.delegate = self;
        scrollView.clipsToBounds = YES;
        [scrollView setShowsHorizontalScrollIndicator:NO];
		[scrollView setShowsVerticalScrollIndicator:NO];
        scrollView.minimumZoomScale = 0.6;
        scrollView.maximumZoomScale = 3.0;
        scrollView.contentMode = UIViewContentModeCenter;
        [self addSubview:scrollView];
        
        collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        collectButton.frame = CGRectMake(self.frame.size.width-50.0f, self.frame.size.height/4, 50.0f, 75.0f);
        [collectButton addTarget:self action:@selector(collectImage) forControlEvents:UIControlEventTouchUpInside];
        [collectButton setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        collectButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:collectButton];
        
        
        
        UIButton *closeImg = [UIButton buttonWithType:UIButtonTypeCustom];
        closeImg.frame = CGRectMake(self.frame.size.width-55.0f, 20.0f, 50.0f, 40.0f);
        [closeImg addTarget:self action:@selector(hiddenGallery) forControlEvents:UIControlEventTouchUpInside];
        [closeImg setBackgroundImage:[UIImage imageNamed:@"closeImg"] forState:UIControlStateNormal];
        closeImg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:closeImg];

        
        UITapGestureRecognizer * tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapDetected:)];
        tapGR.delegate = self;
        [scrollView addGestureRecognizer: tapGR];
        
    }
    return self;
}
-(BOOL)isShowGallery
{
    return imageView != nil;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
-(void)showGallery:(UIImage *)image :(CGRect)rect
{
    [self showGallery:image];
    startRect = rect;
    imageView.frame = rect;
    imageView.alpha = .0f;
    collectButton.alpha = .0f;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationTime];
    imageView.alpha = 1.0f;
    collectButton.alpha = 1.0f;
    imageView.frame = CGRectMake((self.frame.size.width-image.size.width)/2 ,
                                 (self.frame.size.height-image.size.height)/2,
                                 image.size.width, image.size.height);
    [UIView commitAnimations];
}
-(void)showGallery:(UIImage *)image
{
    DJLog(@"%@",NSStringFromCGSize(image.size));
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
    imageView.image = image;
//    imageView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleTopMargin |
                                UIViewAutoresizingFlexibleBottomMargin;
//    imageView.layer.borderWidth = 3.0;
    imageView.center = scrollView.center;
    [scrollView addSubview:imageView];
    [self showGallery];
    
    
}

-(void)showGallery
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
#ifdef ipad
    SurfRootViewController *viewController = (SurfRootViewController *)appDelegate.window.rootViewController;
    viewController.alertView = self;
    [viewController.view addSubview:self];
    self.frame = viewController.view.bounds;
#else
    
#endif

}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sView
{
    return imageView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView            {
    imageView.center = self.center;
}
- (void) singleTapDetected: (UITapGestureRecognizer *) sender
{
    
    if (startRect.origin.x>0)
    {
        [UIView animateWithDuration:kAnimationTime animations:^{
            imageView.frame = startRect;
            imageView.alpha = .0f;
            collectButton.alpha = .0f;
        } completion:^(BOOL finished) {
            [self hiddenGallery];
        }];
    }else{
        [self hiddenGallery];
    }
    
    
}
-(void)hiddenGallery
{
    [imageView removeFromSuperview];
    imageView = nil;
    startRect = CGRectMake(-200, 0, 0, 0);
    imageView.alpha = 1.0f;
    collectButton.alpha = 1.0f;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
#ifdef ipad
    SurfRootViewController *viewController = (SurfRootViewController *)appDelegate.window.rootViewController;
    viewController.alertView = nil;
#else
    
#endif
    [self removeFromSuperview];
}
-(void)collectImage
{
    @try {
        UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message...
        [SurfNotification surfNotification:@"保存失败！"];
    }
    else
    {
        [SurfNotification surfNotification:@"保存成功！"];
    }
}
@end
