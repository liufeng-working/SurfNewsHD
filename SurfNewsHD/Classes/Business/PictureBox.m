//
//  PictureBox.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PictureBox.h"


//#define MRScreenWidth      CGRectGetWidth([UIScreen mainScreen].applicationFrame)
//#define MRScreenHeight     CGRectGetHeight([UIScreen mainScreen].applicationFrame)

#define kItemViewGap 20.f       // PictureItem之间的间隔
#define kImageViewMaxScale 2.f  // 图片View的缩放比例



typedef  NS_ENUM(NSInteger, PictureAlignment){
    EPictureAlignmentCenter,
    EPictureAlignmentFullWidth,
    EPictureAlignmentFullHeight,
};




@class PictureItem;



@interface PictureBox ()
@property(nonatomic,strong)UIScrollView *pictureScrollView; //  图片滚动窗口

@property(nonatomic,strong)PictureItem* pItemOne;
@property(nonatomic,strong)PictureItem* pItemTwo;
@property(nonatomic,strong)PictureItem* pItemThree;

@property(nonatomic,strong)NSMutableArray* picturesArray;
@end


//////////////////////////////////////////////////////////////////////////////////////

@interface PictureItem : UIScrollView <UIScrollViewDelegate>
{
    UIImageView *imageView;
}
@property(nonatomic)PictureAlignment pictureAligment;
@property(nonatomic)CGFloat imageViewScale;

- (void)setImage:(UIImage*)img;
// 恢复图片比例
- (void)recoverImageScale;
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end


@implementation PictureBox


+ (PictureBox*)CreatePictureBox:(NSArray*)pictureArray{
    CGRect frame = CGRectMake(0.f, 0.f, kContentWidth, kContentHeight);
    PictureBox *pb = [[PictureBox alloc] initWithFrame:frame];
    [pb reloadDataWithArray:pictureArray];
    return pb;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _picturesArray = [NSMutableArray arrayWithCapacity:10];
        
        CGRect pictureRect = CGRectMake(0, 0, CGRectGetWidth(frame) + kItemViewGap, CGRectGetHeight(frame));
        _pictureScrollView = [[UIScrollView alloc] initWithFrame:pictureRect];
        _pictureScrollView.delegate = self;
        _pictureScrollView.pagingEnabled = YES;
        _pictureScrollView.userInteractionEnabled = YES;
        _pictureScrollView.showsHorizontalScrollIndicator = NO;
        _pictureScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_pictureScrollView];
        

     
        float offW = CGRectGetWidth(pictureRect);
        CGRect itemRect1 = [self bounds];
        CGRect itemRect2 = itemRect1;
        itemRect2.origin.x = offW;
        CGRect itemRect3 = itemRect2;
        itemRect3.origin.x += offW;
        _pItemOne = [[PictureItem alloc] initWithFrame:itemRect1];
        _pItemTwo = [[PictureItem alloc] initWithFrame:itemRect2];
        _pItemThree = [[PictureItem alloc] initWithFrame:itemRect3];
        [_pictureScrollView addSubview:_pItemOne];
        [_pictureScrollView addSubview:_pItemTwo];
        [_pictureScrollView addSubview:_pItemThree];
        
        
        // test
        UIImage *img1 = [UIImage imageNamed:@"split_Divider"];
        UIImage *img2 = [UIImage imageNamed:@"icon"];
        UIImage *img3 = [UIImage imageNamed:@"why_login"];
        UIImage *img4 = [UIImage imageNamed:@"guide_image1"];
         UIImage *img5 = [UIImage imageNamed:@"icon"];
        NSArray *array = [[NSArray alloc] initWithObjects:img1, img2, img3, img4,img5,nil];
        
//                NSArray *array = [[NSArray alloc] initWithObjects: img2,nil];
        [self reloadDataWithArray:array];
        // test end
    }
    return self;
}

// 加载数据
- (void)reloadDataWithArray:(NSArray*)imgArray{
    [[self picturesArray] removeAllObjects];
    [[self picturesArray] addObjectsFromArray:imgArray];
    
    int imgCount = [imgArray count];
    [self setHidden:imgCount == 0 ? YES : NO];
    CGSize contentSize = CGSizeMake(CGRectGetWidth([_pictureScrollView bounds]) * (imgCount > 3 ? 3 : imgCount),
                                    CGRectGetHeight([_pictureScrollView bounds]));
    [_pictureScrollView setContentSize:contentSize];
    
    
    
    if ([imgArray count] == 1) {
        UIImage *img = [imgArray objectAtIndex:0];
        [_pItemOne setImage:img];
        
        // 一张图设置区域要大一点，不然就不滚动了
        contentSize.width += 1.f;
        [_pictureScrollView setContentSize:contentSize];
    }
    else if([imgArray count] == 2){
        UIImage *img1 = [imgArray objectAtIndex:0];
        UIImage *img2 = [imgArray objectAtIndex:1];
        [_pItemOne setImage:img1];
        [_pItemTwo setImage:img2];
    }
    else if ([imgArray count] >= 3){
        UIImage *img1 = [imgArray objectAtIndex:0];
        UIImage *img2 = [imgArray objectAtIndex:1];
        UIImage *img3 = [imgArray objectAtIndex:2];
        [_pItemOne setImage:img1];
        [_pItemTwo setImage:img2];
        [_pItemThree setImage:img3];        
        [_pItemOne setTag:0];
        [_pItemTwo setTag:1];
        [_pItemThree setTag:2];
        
        [_pItemOne setBackgroundColor:[UIColor grayColor]];
        [_pItemTwo setBackgroundColor:[UIColor greenColor]];
        [_pItemThree setBackgroundColor:[UIColor redColor]];
    }
        
}



// scrollView 完成拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate){        
         [self recoverPictureItemScale:scrollView];    // 回复图片缩放比例
    }
    
    
    // 如何拖拽到最左边或最右边，就退出
    CGPoint point = [scrollView contentOffset];
    
    if ([_picturesArray count] == 1) {
        if (point.x < 0 || point.x > 0) {
            [self setHidden:YES];
        }
    }
    else if([_picturesArray count] == 2) {
        if (point.x < 0 || point.x > _pItemTwo.frame.origin.x) {
            [self setHidden:YES];
        }
    }
    else if([_picturesArray count] >= 3){
        if (point.x < 0 || point.x > _pItemThree.frame.origin.x) {
            [self setHidden:YES];
        }
    }


    
    
}
// 滚动窗口滑动完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{    
    [self recoverPictureItemScale:scrollView];  // 回复图片缩放比例    
    
    
    if (![self isHidden]){
        CGFloat width = CGRectGetWidth([scrollView bounds]);
        int page = floor((scrollView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2
        
        if (page == 0) {
            [self pageMoveToRight:scrollView];
        }
        else if (page >= 2) {            
            [self pageMoveToLeft:scrollView];
        }
    }
    
}

// 页面向右边移
- (void)pageMoveToRight:(UIScrollView *)scrollView{
    if ([_picturesArray count] == 0) {
        return;
    }
    
    
    int idex = [_pItemOne tag];
    if (idex > 0 && idex < [_picturesArray count]) {
        CGRect itemOneRect = _pItemOne.frame;
        CGRect itemTwoRect = _pItemTwo.frame;
        CGRect itemThreeRect = _pItemThree.frame;
        PictureItem* tempView = _pItemOne;
        _pItemOne = _pItemThree;
        _pItemThree = _pItemTwo;
        _pItemTwo = tempView;
        [_pItemOne setFrame:itemOneRect];
        [_pItemTwo setFrame:itemTwoRect];
        [_pItemThree setFrame:itemThreeRect];
    
        --idex;
        [_pItemOne setTag:idex];
        [_pItemOne setImage:[_picturesArray objectAtIndex:idex]];
        [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
    }
    
}

// 页面向左边移
- (void)pageMoveToLeft:(UIScrollView *)scrollView{
    if ([_picturesArray count] == 0) {
        return;
    }
    
    
    int idex = [_pItemThree tag];
    if (idex > 0 && idex < [_picturesArray count]-1) {
        CGRect itemOneRect = _pItemOne.frame;
        CGRect itemTwoRect = _pItemTwo.frame;
        CGRect itemThreeRect = _pItemThree.frame;
        PictureItem* tempView = _pItemOne;
        _pItemOne = _pItemTwo;
        _pItemTwo = _pItemThree;
        _pItemThree = tempView;
        [_pItemOne setFrame:itemOneRect];
        [_pItemTwo setFrame:itemTwoRect];
        [_pItemThree setFrame:itemThreeRect];
        
        ++idex;
        [_pItemThree setTag:idex];
        [_pItemThree setImage:[_picturesArray objectAtIndex:idex]];
        [scrollView setContentOffset:CGPointMake([scrollView bounds].size.width, 0.f)];
    }
    

}

// 恢复图片缩放比例
- (void)recoverPictureItemScale:(UIScrollView *)scrollView{   
    for (UIView* view in scrollView.subviews) {
        if ([view isKindOfClass:[PictureItem class]]) {
            [(PictureItem*)view recoverImageScale];
        }
    }
}


@end



/////////////////////////////////////////////////////////////////////
#pragma mark PictureItem class
/////////////////////////////////////////////////////////////////////





@implementation PictureItem


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.delegate = self;        
        [self initImageView];
    }
    return self;
}

- (void)initImageView
{
    imageView = [[UIImageView alloc]init];
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];

    
    // Add gesture,double tap zoom imageView.
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [imageView addGestureRecognizer:doubleTapGesture];
//    [self addGestureRecognizer:doubleTapGesture];

    
//    float minimumScale = self.frame.size.width / imageView.frame.size.width;
//    [self setMinimumZoomScale:minimumScale];
//    [self setZoomScale:minimumScale];
}

- (void)setImage:(UIImage*)img{
    // 恢复数据
    [imageView setImage:img];
    [self setMinimumZoomScale:1.f];
    [self setZoomScale:1.f];
    
    
    
    // 设置图片相关数据
    if (img != nil && img.size.height > 0 && img.size.width > 0) {
        CGRect imgViewRect = CGRectZero;
        float imgW = img.size.width;
        float imgH = img.size.height;
        
        
        if (img.size.width <= CGRectGetWidth([self bounds]) &&
            img.size.height <= CGRectGetHeight([self bounds])) {
            
            [self setPictureAligment:EPictureAlignmentCenter];
            // 对小于显示区域的图片
            imgViewRect.origin.x = ([self bounds].size.width - imgW) * 0.5;
            imgViewRect.origin.y = ([self bounds].size.height - imgH) * 0.5;
            imgViewRect.size.width = imgW * kImageViewMaxScale;
            imgViewRect.size.height = imgH * kImageViewMaxScale;
            [imageView setFrame:imgViewRect];
            
            // 设置ScrollView缩放比例
            [self setImageViewScale:(CGFloat)(imgW / imgViewRect.size.width)];
            [self setMinimumZoomScale:[self imageViewScale]];
            [self setMaximumZoomScale:[self imageViewScale] + 0.5f];
            [self setZoomScale:[self imageViewScale]];
            
        }
        else{
            float width = CGRectGetWidth([self bounds]);
            float height = CGRectGetHeight([self bounds]);
            if (imgW > width + width || imgH > height + height) {
                
                float tempScaleW = width / imgW;
                float tempScaleH = height / imgH;
                float minScale = 0;
                if (tempScaleW < tempScaleH) {
                    minScale = tempScaleW;
                }else{
                    minScale = tempScaleH;
                }                
                
                imgViewRect.size.width = imgW * minScale;
                imgViewRect.size.height = imgH * minScale;
            }
            else{
                imgViewRect.size.width = imgW * kImageViewMaxScale;
                imgViewRect.size.height = imgH * kImageViewMaxScale;
            }
            
            
            float minimumScaleW = CGRectGetWidth([self bounds]) / CGRectGetWidth(imgViewRect);
            float minimumScaleH = CGRectGetHeight([self bounds]) / CGRectGetHeight(imgViewRect);
            
            if (minimumScaleW < minimumScaleH) {
                [self setImageViewScale:minimumScaleW];
                [self setPictureAligment:EPictureAlignmentFullWidth];                
                imgViewRect.origin.y = (CGRectGetHeight([self bounds]) - CGRectGetHeight(imgViewRect)*[self imageViewScale]) * 0.5f;
            }
            else{
                [self setImageViewScale:minimumScaleH];
                [self setPictureAligment:EPictureAlignmentFullHeight];
                imgViewRect.origin.x = (CGRectGetWidth([self bounds]) - CGRectGetWidth(imgViewRect)*[self imageViewScale]) * 0.5f;
            }
          
            [imageView setFrame:imgViewRect];
            
            
            // 设置ScrollView缩放比例
            [self setMinimumZoomScale:[self imageViewScale]];
            [self setMaximumZoomScale:[self imageViewScale] + 0.5f];
            [self setZoomScale:[self imageViewScale]];
        }
    }    
}


// 恢复图片比例
- (void)recoverImageScale{
    [self setZoomScale:[self imageViewScale]];
}

#pragma mark - Zoom methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
//    float newScale = self.zoomScale * 1.5;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
//    [self zoomToRect:zoomRect animated:YES];
    
    
    if ( [self zoomScale] == [self imageViewScale]) {
        float newScale = self.zoomScale * kImageViewMaxScale;
        CGPoint p = [gesture locationInView:imageView];
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:p];
        [self zoomToRect:zoomRect animated:YES];
    }
    else{
        [self setZoomScale:[self imageViewScale] animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self)
        return imageView;
    else
        return hitView;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [scrollView setZoomScale:scale animated:NO];
}

@end


