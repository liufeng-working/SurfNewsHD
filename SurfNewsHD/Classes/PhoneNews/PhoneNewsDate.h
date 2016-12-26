//
//  PhoneNewsDate.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneNewsDate : NSObject

@property(nonatomic,strong)NSString *hashcode;  // 唯一识别标志
@property(nonatomic,strong)NSString *imgUrl;    // 首页图片下载地址
@property(nonatomic,strong)NSString *txt;       // 彩信手机报说明

@end
