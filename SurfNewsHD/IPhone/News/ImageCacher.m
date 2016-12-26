//
//  ImageCacher.m
//
//  Created by Reese on 13-4-3.
//  Copyright (c) All rights reserved.
//  单例类

#import "ImageCacher.h"

@implementation ImageCacher

static ImageCacher *defaultCacher=nil;
-(id)init
{
    if (defaultCacher) {
        return defaultCacher;
    }else
    {
        self =[super init];
        [self setFlip];
        return self;
    }
}

+(ImageCacher*)defaultCacher
{
    if (!defaultCacher) {

        defaultCacher=[[super allocWithZone:nil]init];
    }
    return defaultCacher;
    
}

+ (id)allocWithZone:(NSZone *)zone
{
    
    return [self defaultCacher];
}


-(void) setFade
{
    _type=kCATransitionFade;
    
}

-(void) setCube
{
   _type=@"cube";
}

-(void) setFlip
{
   _type= @"oglFlip";
}


-(void)cacheImage:(NSDictionary*)aDic
{
    NSString *path =[aDic objectForKey:@"path"];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSData *data=[NSData dataWithContentsOfFile:path] ;
    UIImage *image=[UIImage imageWithData:data];
    if (image==nil) {
        return;
    }
    CGSize origImageSize= [image size];
    
    CGRect newRect;
    newRect.origin= CGPointZero;
    //拉伸到多大
    newRect.size.width = 85;
    newRect.size.height = 85;
    
    
    //缩放倍数
    float ratio = MIN(newRect.size.width/origImageSize.width, newRect.size.height/origImageSize.height);
    
    

    UIGraphicsBeginImageContext(newRect.size);
    

    CGRect projectRect;
    projectRect.size.width =ratio * origImageSize.width;
    projectRect.size.height=ratio * origImageSize.height;
    projectRect.origin.x= (newRect.size.width -projectRect.size.width)/2.0;
    projectRect.origin.y= (newRect.size.height-projectRect.size.height)/2.0;
    
    
    //计算出按钮的位置
//    int disX = ratio * (0);
//    int disY = ratio * (20);
    
    [image drawInRect:projectRect];
    

    UIImage *small = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   
    //压缩比例
    
    NSData *smallData=UIImageJPEGRepresentation(small, 0.02);
    
    
    
    if (smallData) {
        [fileManager createFileAtPath:pathInDocumentDirectory(path) contents:smallData attributes:nil];
    }
    
    UIView *view=[aDic objectForKey:@"imageView"];
 
    //判断view是否还存在 如果对象已经移出屏幕会被回收 那么什么都不用做，下次滚到该对象 缓存已存在 不需要执行此方法
    if (view!=nil) {
        CATransition *transtion = [CATransition animation];
        transtion.duration = 0.5;
        [transtion setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [transtion setType:_type];
        [transtion setSubtype:kCATransitionFromRight];
        
        [view.layer addAnimation:transtion forKey:@"transtionKey"];
        [(UIImageView*)view setImage:small];
    }
    
    
    UIButton *btn = [aDic objectForKey:@"button"];
        
    
    if (btn != nil) {
        [(UIButton*)btn setFrame:CGRectMake(0, -10, btn.frame.size.width+12, btn.frame.size.height+12)];
    }
    
    [view addSubview:btn];
}

-(void)cachePic:(NSDictionary*)aDic
{
    UIImage *image = nil;
    image = [aDic objectForKey:@"path"];
    
    if (image==nil) {
        return;
    }
    CGSize origImageSize= [image size];
    
    CGRect newRect;
    newRect.origin= CGPointZero;
    //拉伸到多大
    newRect.size.width = 85;
    newRect.size.height = 85;
    
    
    //缩放倍数
    float ratio = MIN(newRect.size.width/origImageSize.width, newRect.size.height/origImageSize.height);
    
    
    
    UIGraphicsBeginImageContext(newRect.size);
    
    
    CGRect projectRect;
    projectRect.size.width =ratio * origImageSize.width;
    projectRect.size.height=ratio * origImageSize.height;
    projectRect.origin.x= (newRect.size.width -projectRect.size.width)/2.0;
    projectRect.origin.y= (newRect.size.height-projectRect.size.height)/2.0;
    
    
    //计算出按钮的位置
    //    int disX = ratio * (0);
    //    int disY = ratio * (20);
    
    [image drawInRect:projectRect];
    
    
    UIImage *small = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //压缩比例
        
    UIView *view=[aDic objectForKey:@"imageView"];
    
    //判断view是否还存在 如果对象已经移出屏幕会被回收 那么什么都不用做，下次滚到该对象 缓存已存在 不需要执行此方法
    if (view!=nil) {
        CATransition *transtion = [CATransition animation];
        transtion.duration = 0.5;
        [transtion setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [transtion setType:_type];
        [transtion setSubtype:kCATransitionFromRight];
        
        [view.layer addAnimation:transtion forKey:@"transtionKey"];
        [(UIImageView*)view setImage:small];
    }
    
    
    UIButton *btn = [aDic objectForKey:@"button"];
    
    
    if (btn != nil) {
        [(UIButton*)btn setFrame:CGRectMake(0, -10, btn.frame.size.width+12, btn.frame.size.height+12)];
    }
    
    [view addSubview:btn];
}

@end
