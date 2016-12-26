//
//  SurfJsonRequestBase.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SurfJsonRequestBase : NSObject

@property(nonatomic,strong) NSString* os;     //ipad or ios
@property(nonatomic,strong) NSString* did;    //device id
@property(nonatomic,strong) NSString* pm;     //设备型号 :(
@property(nonatomic,strong) NSString* cid;    //channel id
@property(nonatomic,strong) NSString* sdkv;   //sdk version  :(
@property(nonatomic,strong) NSString* cityId;   //
@property(nonatomic,strong) NSString* uid;    //用户ID
@property int vercode;      //designed for Android  :(

////服务端以vername作为版本号统计操作
@property(nonatomic,strong) NSString* vername;

@end
