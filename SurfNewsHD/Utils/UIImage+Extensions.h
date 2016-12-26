//
//  UIImage+Extensions.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(Extensitons)
+(UIImage*)imageNamedNewImpl:(NSString*)name;

// 获取合适的启动画面
// 因启动画面使用asset 就不能获取到启动图片
// 参考：http://www.cnblogs.com/ChenYilong/p/4020384.html
+(UIImage*)fitLaunchImage;
@end
