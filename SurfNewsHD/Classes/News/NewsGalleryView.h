//
//  NewsGalleryView.h
//  SurfNewsHD
//
//  Created by apple on 13-1-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsGalleryView : UIView<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UIImageView *imageView;
    UIScrollView *scrollView;
	CGRect startRect;
    UIButton *collectButton;
}
+(NewsGalleryView*)sharedInstance;
-(BOOL)isShowGallery;
-(void)showGallery;
-(void)showGallery:(UIImage *)image;
-(void)showGallery:(UIImage *)image :(CGRect)rect;
@end
