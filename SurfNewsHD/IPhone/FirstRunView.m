//
//  FirstRunView.m
//  SurfBrowser
//
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FirstRunView.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "DispatchUtil.h"

@implementation FirstRunView

- (id)initShowViewType:(NSString *)key
{
    CGRect frame = CGRectMake(0.0f, 20.0f, kContentWidth, kContentHeight);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
        imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        
        if ([key isEqualToString:StringLastSubsSlideGuideVersion])
        {
            //订阅页   key:StringLastOfflineGuideVersion
            UIImage *image = [UIImage imageNamed:@"tip_Subs.png"];
            imageView.image = image;
            imageView.frame = CGRectMake(0.0f, 50.0f, image.size.width, image.size.height);
        }
        /* 1.1+起已经废弃
        else if ([key isEqualToString:StringLastOfflineGuideVersion])
        {
            //离线页   key:StringLastOfflineGuideVersion
            imageView.image = [UIImage imageNamed:@"tip_Offline.png"];
            imageView.frame = CGRectMake(0.0f, 00.0f, kContentWidth, 100.0f);
        }
        */
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}
@end




@interface MainViewGuide () {
    
    UIImage * _img;
}

@end

@implementation MainViewGuide

-(id)initWithFrame:(CGRect)frame andWithType:(MainViewGuide_Type)mianType
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    mainViewGuideType = mianType;
    if (mainViewGuideType == MainApp_Type) {
        _img = [UIImage imageNamed:@"mainViewFristRun.png"];

    }
    else if (mainViewGuideType == MainBody_Type){
        _img = [UIImage imageNamed:@"energy_First_Logo"];

        if (!imagev) {
            imagev = [[UIImageView alloc] initWithFrame:CGRectMake(self.center.x - 72, self.center.y + 120, 145, 85)];

        }
        if (_img) {
            [imagev setImage:_img];
        }
        if (![self.subviews containsObject:imagev]) {
            [self addSubview:imagev];
        }
        
        [self performSelector:@selector(autoAnimation) withObject:nil afterDelay:2];
        
    }
    
    UITapGestureRecognizer *singleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBackClick:)];
    [self addGestureRecognizer:singleTap];
    
    return self;
}


- (void)autoAnimation{
    if (imagev) {
        [UIView beginAnimations:@"animationName" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:3]; //动画持续的秒数
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [imagev setAlpha:0];
        [UIView commitAnimations];

    }
}

- (void)drawRect:(CGRect)rect
{
    if (mainViewGuideType == MainApp_Type) {
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        
        //pickingFieldWidth:圆形框的直径
        CGFloat pickingFieldWidth = 60.f;
        
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(contextRef);
        CGContextSetRGBFillColor(contextRef, 0, 0, 0, 0.55);
        CGContextSetLineWidth(contextRef, 3);
        
        //计算圆形框的外切正方形的frame：
        CGRect pickingFieldRect = CGRectMake(90, height - pickingFieldWidth, pickingFieldWidth, pickingFieldWidth);
        //创建圆形框UIBezierPath1
        UIBezierPath *pickingFieldPath1 = [UIBezierPath bezierPathWithOvalInRect:pickingFieldRect];
        
        // 创建圆形框UIBezierPath2
        pickingFieldRect = CGRectOffset(pickingFieldRect, 80.f, 0.f);;
        UIBezierPath *pickingFieldPath2 = [UIBezierPath bezierPathWithOvalInRect:pickingFieldRect];
        //创建外围大方框UIBezierPath:
        UIBezierPath *bezierPathRect = [UIBezierPath bezierPathWithRect:rect];
        //将圆形框path添加到大方框path上去，以便下面用奇偶填充法则进行区域填充：
        [bezierPathRect appendPath:pickingFieldPath1];
        [bezierPathRect appendPath:pickingFieldPath2];
        
        //填充使用奇偶法则
        bezierPathRect.usesEvenOddFillRule = YES;
        [bezierPathRect fill];
        
        
        //    这里是绘制虚圆
        //    CGContextSetLineWidth(contextRef, 2);
        //    CGContextSetRGBStrokeColor(contextRef, 255, 255, 255, 1);
        //    CGFloat dash[2] = {4,4};
        //    [pickingFieldPath setLineDash:dash count:2 phase:0];
        //    [pickingFieldPath stroke];
        
        
        
        if (_img) {
            float imgW = [_img size].width;
            float imgH = [_img size].height;
            [_img drawAtPoint:CGPointMake((width-imgW)/2, height - pickingFieldWidth-imgH)];
        }
        
        CGContextRestoreGState(contextRef);
        self.layer.contentsGravity = kCAGravityCenter;
        
    }
 
}


-(void)goBackClick:(id)sender
{
    self.hidden = YES;
    [self removeFromSuperview];
}

@end
