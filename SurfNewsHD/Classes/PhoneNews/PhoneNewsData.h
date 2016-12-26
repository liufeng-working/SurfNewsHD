//
//  PhoneNewsDate.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneNewsData : NSObject

@property(nonatomic,strong)NSString *hashcode;  // 唯一识别标志
@property(nonatomic,strong)NSString *imgurl;    // 首页图片下载地址
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *cat;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *keycode;
@property(nonatomic)double datetime;
@end
