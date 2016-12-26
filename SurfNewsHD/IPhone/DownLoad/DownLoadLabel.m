//
//  DownLoadLabel.m
//  SurfNewsHD
//
//  Created by yujiuyin on 13-8-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "DownLoadLabel.h"
#import "AppDelegate.h"



#define FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]

@implementation DownLoadLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)getWhiteViewFromWidth:(float)width
{
    float width2 = width - self.widthLength;//55;//self.frame.size.width;
//    if (width2 > self.frame.size.width) {
//        return;
//    }
    [self setTextColor:[UIColor whiteColor]];
    if (!leftImageView)
    {
        leftImageView = [[UIImageView alloc] init];
    }
    if (![self.subviews containsObject:leftImageView])
    {
        [self addSubview:leftImageView];
    }
    
    if (!currentImageView)
    {
        currentImageView = [[UIImageView alloc] initWithFrame:self.frame];
        [currentImageView setBackgroundColor:[UIColor clearColor]];
    }
    if ([self.subviews containsObject:currentImageView])
    {
        [currentImageView removeFromSuperview];
    }
    [self setBackgroundColor:[UIColor colorWithRed:169/255.0f green:49/255.0f blue:43/255.0f alpha:1]];
    [currentImageView setImage:[self getImageFromImage:[self getNormalImage] andWidth:width2]];
    [self setTextColor:[UIColor colorWithHexString:@"999292"]];
    [self setBackgroundColor:[UIColor clearColor]];

    if (width2 < self.frame.size.width) {
        [currentImageView setFrame:CGRectMake(0, 0, width2, self.frame.size.height)];
    }
    else
    {
        [currentImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }

//    if (![theApp.window.subviews containsObject:currentImageView])
//    {
//        [theApp.window addSubview:currentImageView];
//    }
    
    if (![self.subviews containsObject:currentImageView])
    {
        [self addSubview:currentImageView];
    }

//    NSLog(@"widthwidthwidthwidth: %f", width);
//     NSLog(@"width222222222222: %f", width2);
//    UIImage *leftImage = [self saveImage:width];
//    [leftImageView setFrame:CGRectMake(0, 50, width, self.frame.size.height)];
//    [leftImageView setImage:leftImage];
//    [leftImageView setBackgroundColor:[UIColor yellowColor]];
//    [self setTextColor:[UIColor blackColor]];
}

-(UIImage *)getImageFromImage:(UIImage*) superImage andWidth:(float)width
{
    CGSize subImageSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    //定义裁剪的区域相对于原图片的位置
    
    CGRect rect;
    if ([[UIScreen mainScreen] scale] == 2) {
        rect = CGRectMake(0, 0, width * 2, self.frame.size.height * 2);
    }
    else
    {
        rect = CGRectMake(0, 0, width, self.frame.size.height);
    }
    
    CGRect subImageRect = rect;
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

- (UIImage *)getNormalImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);//retina屏幕
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)saveImage:(float)width
{
    [self setTextColor:[UIColor whiteColor]];
    
    UIGraphicsBeginImageContext(CGSizeMake(width, self.bounds.size.height));
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

- (void)removeCurrentView
{
    if (currentImageView) {
        [currentImageView removeFromSuperview];
        currentImageView = nil;
    }
}

/*
- (void)drawRect:(CGRect)rect
{
    NSInteger linew = 0;
	NSInteger linehighe = 0;
	
	NSInteger line =  0;
	NSInteger linex = 0;
    if (text) {
        linew = rect.size.width;
        linehighe = hight/linenum;
        
        line =  len/linew;
        linex = len%linew;
    }

	
    //	NSLog(@"行数：%d 烈数：%d",line,linex);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	if (line>0)
	{
		CGContextSetRGBFillColor(context, 1, 1, 1, 1);
		CGContextFillRect(context, CGRectMake(0.0,0.0,linew,line*linehighe));
	}
    //	if (linex>0)
    //	{
    //		CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    //		CGContextFillRect(context, CGRectMake(0.0,line*linehighe,linex,linehighe));
    //	}
	
    //    CGContextSetRGBFillColor(context, 255, 255, 255, 1);
	CGContextSetRGBFillColor(context, 0.5, 0.1, 0.8, 1);
	CGContextFillRect(context, CGRectMake(linex,line*linehighe,linew - linex,linehighe));
	CGContextFillRect(context, CGRectMake(0.0,(line+1)*linehighe,linew,(linenum-1-line)*linehighe));
	
	CGImageRef alphaMask = CGBitmapContextCreateImage(context);
	CGContextRestoreGState(context);
    
    //背景色
//	CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1);
//  CGContextSetRGBFillColor(context, 255, 255, 255, 0);
    CGContextSetRGBFillColor(context, 255, 255, 255, 1);
//  CGContextSetRGBFillColor(context, 0, 0, 0, 0);
	CGContextFillRect(context, rect);
	
	
	CGContextClipToMask(context, rect, alphaMask);
	[[UIColor greenColor] setFill];
	[text drawInRect:rect withFont:FONT];
    
	CGImageRelease(alphaMask);
	CGContextRestoreGState(context);
    
    NSLog(@"lenlenlen len:%d", len);
}*/

-(void)settext:(NSString *)te
{
	if (text!=nil)
	{
//		[text release];
		text = nil;
	}
	text = [te copy];
	
//	CGSize size1 = [text sizeWithFont:FONT];
//	NSLog(@"sizesize11      :%f %f",size1.width,size1.height);
//	CGSize size = [text sizeWithFont:FONT constrainedToSize:self.frame.size lineBreakMode:UILineBreakModeWordWrap];
//	NSLog(@"sizesize        :%f %f",size.width,size.height);
	linenum = 1;//size.height/size1.height;
	hight = 20;//size.height;
	len = 0;
    
}

- (void)setTextProgressColor:(float)width
{
    len = width;
    
    [self setNeedsDisplay];
}

@end
