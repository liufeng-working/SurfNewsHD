//
//  SNThreadImageBrowserViewController.m
//  SurfNewsHD
//
//  Created by Tianyao on 16/1/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "SNThreadImageBrowserController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation SNThreadImageBrowserController
{
    //UI
    UIScrollView *wholeScoll;
    UIPageControl *pageControl;
    UILabel *pageLabel;
    UIButton *downButton;
    UIButton *closeButton;
    //member
    NSArray * mImgUrlArr;             //图片链接数组
    NSArray * mImgLocationArr;        //本地图片数组
    NSUInteger pagesCount;            //图片总数
    NSUInteger mcurpage;              //当前显示页
    CGSize  maxSize;                  //最大的Size
    CGSize  minSize;                  //最小的Size
    CGFloat maxScale;                 //最大放大倍数
    CGFloat imgviewInitMarginY;       //imgview初始化的Y轴Margin
    CGFloat imgviewmarginY;           //imgview的Y轴Margin
    CGFloat offsetPinchX;
    CGFloat xInScreen;
    CGSize  oldSize;
    CGSize  endSize;
    CGFloat oldLength;
    CGFloat newLength;
    CGPoint oldFirstPoint;
    CGPoint oldSecondPoint;
    CGPoint newFirstPoint ;
    CGPoint newSecondPoint ;
    CGSize  newSize;
    CGPoint centrePoint;              //捏合时的中心点
    BOOL    isBigger;                 //是否已经放大
    CGFloat biggerScale;              //放大的倍数
}
-(void)viewDidAppear:(BOOL)animated
{
    
}

-(id)initWithImgUrlArr:(NSArray*)array CurPage:(NSInteger)curpage
{
    mImgUrlArr = array;
    mcurpage = curpage;
    self = [super init];
    self.view.frame = [UIScreen mainScreen].bounds;
    if (self) {
        [self setWholeScoll];
        [self setButtons];
        [self setImagesUrlAlbum];
//        [self setPage];
        [self setPageLabel];
        [self setMemer];
    }
    return self;
}
-(id)initWithImgULocationArr:(NSArray*)array CurPage:(NSInteger)curpage
{
    mImgLocationArr = array;
    mcurpage = curpage;
    self = [super init];
    self.view.frame = [UIScreen mainScreen].bounds;
    if (self) {
        [self setWholeScoll];
        [self setImagesLocationAlbum];
        [self setPage];
        [self setMemer];
    }
    return self;
}

- (void)setButtons {
    // 添加按钮 下载、关闭
    downButton = [[UIButton alloc] initWithFrame:CGRectMake(myScreenWidth - 100, 30, 36, 36)];
    [downButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];

    [self.view addSubview:downButton];
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(myScreenWidth - 50, 30, 36, 36)];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];

    [self.view addSubview:closeButton];
    
    // 按钮点击事件
    [downButton addTarget:self action:@selector(downButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setMemer
{
    isBigger = NO;
    maxScale = 3.0;
    maxSize = CGSizeMake(myScreenWidth*3.0, myScreenHeight*3.0);
    minSize = CGSizeMake(myScreenWidth, myScreenHeight);
}
-(void)setWholeScoll
{
    wholeScoll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, myScreenWidth, myScreenHeight)];
    wholeScoll.backgroundColor = [UIColor blackColor];
    wholeScoll.contentOffset = CGPointMake(wholeScoll.frame.size.width*mcurpage, 0);
    [self.view addSubview:wholeScoll];
    wholeScoll.pagingEnabled = YES;
    wholeScoll.showsHorizontalScrollIndicator = NO;
    wholeScoll.showsVerticalScrollIndicator = NO;
    wholeScoll.delegate = self;
}

#pragma mark 添加pageLabel
- (void)setPageLabel {
    pageLabel = [[UILabel alloc] init];
    pageLabel.bounds = CGRectMake(0, 0, myScreenWidth * 0.25, 44);
    pageLabel.center = CGPointMake(myScreenWidth * 0.5, myScreenHeight - 44);
    pageLabel.backgroundColor = [UIColor blackColor];
    pageLabel.alpha = 0.7f;
    pageLabel.layer.cornerRadius = 5.0f;
    pageLabel.layer.masksToBounds = YES;
    pageLabel.textColor = [UIColor whiteColor];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pagesCount = mImgLocationArr?mImgLocationArr.count:mImgUrlArr.count;
    if (pagesCount == 1) {
        pageLabel.hidden = YES;
    } else {
        pageLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)(mcurpage + 1), (unsigned long)pagesCount];
    }
    [self.view addSubview:pageLabel];
}

-(void)setPage
{
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = mImgLocationArr?mImgLocationArr.count:mImgUrlArr.count;
    pageControl.currentPage   = mcurpage;
    pageControl.frame = CGRectMake(0,myScreenHeight-40, myScreenWidth, 40);
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
}

-(void)setImagesLocationAlbum
{
    wholeScoll.contentSize = CGSizeMake(myScreenWidth*mImgLocationArr.count, myScreenHeight);
    for (int i = 0; i<mImgLocationArr.count; i++) {
        //设置 imageview
        UIImageView * imgview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, myScreenWidth, myScreenHeight)];
        imgview.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *img  = [UIImage imageNamed:[mImgLocationArr objectAtIndex:i]];
        imgview.image = img;
        imgview.frame = [self getRectfixMinImageView:imgview];
        //设置 scrollview
        UIScrollView * singleview = [[UIScrollView alloc]initWithFrame:CGRectMake(myScreenWidth*i,0,myScreenWidth, myScreenHeight)];
        [wholeScoll addSubview:singleview];
        [singleview addSubview:imgview];
        singleview.tag = 101+i;
        // 添加手势
        [self addGestureRecognizer];
    }
}
-(void)setImagesUrlAlbum
{
    wholeScoll.contentSize = CGSizeMake(myScreenWidth*mImgUrlArr.count, myScreenHeight);
    for (int i = 0; i<mImgUrlArr.count; i++) {
        // 转轮
        UIActivityIndicatorView * Indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        Indicator.center = CGPointMake(myScreenWidth/2+i*myScreenWidth,myScreenHeight/2);
        Indicator.tag = 201 + i;
        [wholeScoll addSubview:Indicator];
        [Indicator startAnimating];
        
        // 图片
        UIImageView * imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,myScreenWidth, myScreenHeight)];
        imgview.contentMode = UIViewContentModeScaleAspectFit;
        // 下载图片
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:[mImgUrlArr objectAtIndex:i]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            //设置image
            imgview.image = image;
            imgview.frame = [self getRectfixMinImageView:imgview];
            
            [Indicator stopAnimating];
        }];
        
        // 设置单页scrollView
        UIScrollView * singleview = [[UIScrollView alloc]initWithFrame:CGRectMake(myScreenWidth*i, 0, myScreenWidth, myScreenHeight)];
        [singleview setBackgroundColor:[UIColor blackColor]];
        singleview.contentSize = [self getScrollViewContentSize:imgview];
        singleview.tag = 101+i;
        [wholeScoll addSubview:singleview];
        [singleview addSubview:imgview];
        // 添加手势
//        [self addGestureRecognizer];
    }

}

#pragma mark 下载按钮点击
- (void)downButtonClick {
    // 判断相册权限
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        if (IOS8) {
            // 无权限，弹出对话框
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法保存" message:@"请进入设置允许冲浪快讯访问你的照片。" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // 跳转到权限设置页面
                NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if (appSettings) {
                    [[UIApplication sharedApplication] openURL:appSettings];
                }
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"以后" style:UIAlertActionStyleCancel handler:nil];
            
            [alertController addAction:settingAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法保存" message:@"请在iPhone的“设置-隐私-照片”选项中，允许冲浪快讯访问你的照片。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
            [alert show];
        }
        
        
        return;
    }
    
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[wholeScoll viewWithTag:201 + mcurpage];
    if (indicator.isAnimating) {
        [MBProgressHUD showMessage:@"正在加载图片，请稍后..." toView:nil afterDelay:1.2];
        return;
    }
    
    UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+mcurpage];
    
    UIImageView * imgview = singleScrollView.subviews[0];
    UIImage *img = imgview.image;

    
    // 保存图片到相册
    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

// 保存图片
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)info {
    
    if (error != nil) {
        DJLog(@"%@", error);
        [MBProgressHUD showError:@"保存失败"];
    } else {
        [MBProgressHUD showSuccess:@"保存成功"];
    }
}

#pragma mark 关闭按钮点击
- (void)closeButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 手势
-(void)addGestureRecognizer
{
    NSInteger count = mImgUrlArr?mImgUrlArr.count:mImgLocationArr.count;
    for (int i =0; i<count; i++) {
        UIScrollView *singleview = (UIScrollView*)[wholeScoll viewWithTag:101+i];
        //单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnScrollView)];
        [singleview addGestureRecognizer:singleTap];
        
        //双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapOnScrollView:)];
        [singleview addGestureRecognizer:doubleTap];
        [doubleTap setNumberOfTapsRequired:2];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        //捏合手势
        UIPinchGestureRecognizer * pinchGes = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchOnScrollView:)];
        [singleview addGestureRecognizer:pinchGes];
    }
}
#pragma mark 单击
-(void)singleTapOnScrollView
{
    UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+mcurpage];
    UIImageView * imgview = singleScrollView.subviews[0];
    [_myDelegate getCurPage:mcurpage];
    if (isBigger) {
        [UIView animateWithDuration:0.5 animations:^{
            imgview.frame = [self getRectfixMinImageView:imgview];
            singleScrollView.contentSize = [self getScrollViewContentSize:imgview];
            singleScrollView.contentOffset = CGPointMake(0, 0);
        }completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
        
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}
#pragma mark 双击
-(void)doubleTapOnScrollView:(UITapGestureRecognizer*)doubletap
{
    // 放大  获取到点击的位置
    UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+pageControl.currentPage];
    UIImageView * imgview = singleScrollView.subviews[0];
    
    CGFloat imgHeight = imgview.frame.size.height;
    CGFloat imgY = imgview.frame.origin.y;
    CGFloat imgX = imgview.frame.origin.x;
    CGPoint tapPoint = [doubletap locationInView:doubletap.view];
    CGFloat tapX = tapPoint.x;
    CGFloat tapY = tapPoint.y;
    BOOL isOutImgView = NO;
    SNThreadImageBrowserControllerOutImgViewPointType pointType = 0;
    
    if (tapY<imgY) {
        //上面
        pointType = SNThreadImageBrowserControllerOutImgViewPointLeftUp;
        if (tapX>myScreenWidth/2) {
            pointType = SNThreadImageBrowserControllerOutImgViewPointRightUp;
        }
        isOutImgView = YES;
    }
    else if(tapY>imgY+imgHeight)
    {
        //下面
        pointType = SNThreadImageBrowserControllerOutImgViewPointLeftDown;
        if (tapX>myScreenWidth/2) {
            pointType = SNThreadImageBrowserControllerOutImgViewPointRightDown;
        }
        isOutImgView = YES;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        if (isBigger) {
            //缩小
            singleScrollView.contentOffset = CGPointMake(0.0f, 0.0f);
            imgview.frame = [self getRectfixMinImageView:imgview];
            singleScrollView.contentSize = [self getScrollViewContentSize:imgview];
            isBigger = NO;
        }
        else
        {
            //放大
            //如果点击的是在图片外面
            imgview.frame = CGRectMake(0, 0,imgview.frame.size.width * maxScale, imgview.frame.size.height * maxScale);
            singleScrollView.contentSize = CGSizeMake(imgview.frame.size.width,imgview.frame.size.height);
            if (isOutImgView) {
                NSLog(@"isout");
                
                switch (pointType) {
                    case SNThreadImageBrowserControllerOutImgViewPointLeftUp:
                    {
                        singleScrollView.contentOffset = CGPointMake(0, 0);
                    }
                        break;
                    case SNThreadImageBrowserControllerOutImgViewPointLeftDown:
                    {
                        singleScrollView.contentOffset = CGPointMake(0, imgview.frame.size.height - myScreenHeight);
                    }
                        break;
                    case SNThreadImageBrowserControllerOutImgViewPointRightDown:
                    {
                        singleScrollView.contentOffset = CGPointMake(imgview.frame.size.width - myScreenWidth, imgview.frame.size.height - myScreenHeight);
                    }
                        break;
                    case SNThreadImageBrowserControllerOutImgViewPointRightUp:
                    {
                        singleScrollView.contentOffset = CGPointMake(imgview.frame.size.width - myScreenWidth, 0);
                    }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                //将双击的点设置到屏幕的中心
                CGFloat offsetX = (tapX-imgX)*maxScale - myScreenWidth/2;
                CGFloat offsetY = (tapY-imgY)*maxScale - myScreenHeight/2;
                //如果超出最大范围，则设置边界值
                offsetY = offsetY<0?0:offsetY;
                offsetY = offsetY>imgview.frame.size.height-myScreenHeight?imgview.frame.size.height-myScreenHeight:offsetY;
                offsetX = offsetX<0?0:offsetX;
                offsetX = offsetX>imgview.frame.size.width - myScreenWidth?imgview.frame.size.width - myScreenWidth:offsetX;
                singleScrollView.contentOffset = CGPointMake(offsetX,offsetY);
            }
            isBigger = YES;
        }
    }];
}
#pragma mark 捏合
-(void)pinchOnScrollView:(UIPinchGestureRecognizer*)pinchGes
{
    // 捏合手势是  初始的中心点所在屏幕的位置不变
    UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+mcurpage];
    UIImageView * imgview = singleScrollView.subviews[0];
    
    if (!isBigger) {
        // 如果没有放大，初始值
        oldSize = imgview.frame.size;
        imgviewInitMarginY = imgview.frame.origin.y;
    }
    imgviewmarginY=imgviewInitMarginY;
    
    if (pinchGes.numberOfTouches==2) {
        
        if (pinchGes.state == UIGestureRecognizerStateBegan) {
            
            oldFirstPoint = [pinchGes locationOfTouch:0 inView:pinchGes.view];
            oldSecondPoint = [pinchGes locationOfTouch:1 inView:pinchGes.view];
            oldLength = [self caculateLengthBetweenP1:oldFirstPoint P2:oldSecondPoint];
            //计算出初始中心点
            centrePoint = CGPointMake((oldFirstPoint.x+oldSecondPoint.x)/2,(oldSecondPoint.y+oldFirstPoint.y)/2);
            xInScreen = centrePoint.x - offsetPinchX;
        }
        else if (pinchGes.state == UIGestureRecognizerStateChanged) {
            
            newFirstPoint = [pinchGes locationOfTouch:0 inView:pinchGes.view];
            newSecondPoint = [pinchGes locationOfTouch:1 inView:pinchGes.view];
            // 计算出两点之间的距离
            newLength = [self caculateLengthBetweenP1:newFirstPoint P2:newSecondPoint];
            // 计算出是放大或者是缩小
            biggerScale = newLength/oldLength;
            if (biggerScale>1) {
                //放大
                
            }
            else
            {
                //缩小
            }
            
            newSize = CGSizeMake(oldSize.width*biggerScale,oldSize.height*biggerScale);
            if (newSize.width>maxSize.width)
            {
                newSize = CGSizeMake(maxSize.width, [self getHeightInImageView:imgview imageWidth:maxSize.width]);
            }
            
            [self pinchBlewMinSize:singleScrollView imgView:imgview];
            
            isBigger = YES;
        }
        else
        {
            [self pinchBlewMinSize:singleScrollView imgView:imgview];
            oldSize = newSize;
        }
    }
    else
    {
        [self pinchBlewMinSize:singleScrollView imgView:imgview];
        oldSize = newSize;
    }
}
-(void)pinchBlewMinSize:(UIScrollView*)singleScrollView imgView:(UIImageView*)imgview
{
    if (newSize.width<minSize.width) {
        // 缩小
        newSize = CGSizeMake(minSize.width*0.965, [self getHeightInImageView:imgview imageWidth:minSize.width]*0.965);
        isBigger = NO;
        [self changeMethod:singleScrollView imgView:imgview];
        singleScrollView.contentOffset = CGPointMake(-minSize.width* 0.015, -minSize.width* 0.01);
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect imgRect = CGRectMake(0, imgviewmarginY, minSize.width, [self getHeightInImageView:imgview imageWidth:minSize.width]);
            imgview.frame = imgRect;
            singleScrollView.contentOffset = CGPointMake(0, 0);
        }];
    }
    else
    {
        [self changeMethod:singleScrollView imgView:imgview];
    }
}
- (void)changeMethod:(UIScrollView*)singleScroll imgView:(UIImageView*)imgView;
{
    // newSize
    imgviewmarginY = (myScreenHeight - newSize.height)/2;
    
    imgviewmarginY = imgviewmarginY<0?0:imgviewmarginY;
    
    imgviewmarginY = imgviewmarginY>imgviewInitMarginY?imgviewInitMarginY:imgviewmarginY;
    
    singleScroll.contentSize = newSize;
    
    CGRect imgRect = CGRectMake(0, imgviewmarginY, newSize.width, newSize.height);
    
    //    NSLog(@"%f---------%f---------%f",myScreenHeight-imgviewmarginY-newSize.height,imgviewmarginY,myScreenHeight);
    
    imgView.frame = imgRect;
    
    //难度在contentOffset
    //首先要知道初始中心点 x 的位置 centrePoint.x
    
    
    CGFloat newScale = newSize.width / minSize.width;
    
    // 算出 在屏幕的点
    
    if (newSize.width < maxSize.width && newScale>1) {
        offsetPinchX = xInScreen * (newScale - 1);
    }
    if (offsetPinchX<0) {
        offsetPinchX = 0;
    }
    if (offsetPinchX>(newSize.width - myScreenWidth)) {
        offsetPinchX = newSize.width - myScreenWidth;
    }
    NSLog(@"%f ------ %f ------%f",offsetPinchX,centrePoint.x,newScale);
    if (newSize.width == maxSize.width) {
        
    }
    else
    {
        singleScroll.contentOffset = CGPointMake(offsetPinchX, 0);
    }
}

#pragma mark 委托
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    UIScrollView *singleScrollView = (UIScrollView*)[wholeScoll viewWithTag:101+mcurpage];
    UIImageView *imgview = singleScrollView.subviews[0];
//    imgview.frame = [self getRectfixMinImageView:imgview];
    singleScrollView.contentSize = [self getScrollViewContentSize:imgview];
    singleScrollView.contentOffset = CGPointMake(0, 0);
    mcurpage = scrollView.contentOffset.x / myScreenWidth;
    pageControl.currentPage = mcurpage;
    [_myDelegate getCurPage:mcurpage];
    
    pageLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)(mcurpage + 1), (unsigned long)pagesCount];
}

//初始化的rect
#pragma mark 初始化布局
-(CGRect)getRectfixMinImageView:(UIImageView*)imgview
{
    CGFloat imgWidth = imgview.frame.size.width;
    CGFloat imgHeight = imgview.frame.size.height;
    imgWidth = myScreenWidth;
    CGFloat marginY;
    if (imgHeight < myScreenHeight) {
        marginY = (myScreenHeight - imgHeight)/2;
    } else {
        marginY = 0;
    }
    
    CGRect frame = CGRectMake(0, marginY, imgWidth, imgHeight);
    return frame;
}
// 获取imageview的高度
-(CGFloat)getHeightInImageView:(UIImageView*)imgview imageWidth:(CGFloat)imgWidth
{
    UIImage * img = imgview.image;
    CGFloat imgHeightWithWidthScale = img.size.height / img.size.width;
    CGFloat imgHeight = imgWidth * imgHeightWithWidthScale;
    return imgHeight;
}
// 获取Y轴的距离
-(CGFloat)getMarginfixMinImageView:(UIImageView*)imgview
{
    UIImage *img = imgview.image;
    CGFloat imgHeightWithWidthScale = img.size.height / img.size.width;
    CGFloat imgWidth = myScreenWidth;
    CGFloat imgHeight = imgWidth * imgHeightWithWidthScale;
    CGFloat marginY = (myScreenHeight - imgHeight)/2;
    return marginY;
}
-(CGSize)getScrollViewContentSize:(UIImageView*)imageview
{
    CGSize size = CGSizeMake(imageview.frame.size.width, imageview.frame.size.height);
    return size;
}
-(CGRect)getReSizeInImageView:(UIImageView*)imgview Size:(CGSize)size
{
    return CGRectMake(imgview.frame.origin.x, imgview.frame.origin.y, size.width, size.height);
}

#pragma mark -数学方法
- (CGFloat)caculateLengthBetweenP1:(CGPoint)p1 P2:(CGPoint)p2;
{
    CGFloat x = p1.x-p2.x;
    CGFloat y = p1.y-p2.y;
    return sqrtf(x*x+y*y);
}
-(CGPoint)caculateCentrePointP1:(CGPoint)p1 P2:(CGPoint)p2;
{
    return CGPointMake((p1.x+p2.x)/2,(p1.y+p2.y)/2);
}
#pragma mark 封装UI
@end
