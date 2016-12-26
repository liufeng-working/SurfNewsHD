//
//  PhoneNewsListResponst.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//



@interface PhoneNewsListResponst : NSObject

@property int resCode;
@property NSString* msg;
@property int page;
@property NSArray* res;

@end


@interface PhoneNewsCancelFavsResponst : NSObject
@property int resCode; // 成功（0）、超时（1）、缺失必要参数（2）、失败（3）
@property NSString* msg;
@property NSString* hashCode;
@end