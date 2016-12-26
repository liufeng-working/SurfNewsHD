//
//  SurfUserInfo.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

//冲浪用户信息
@interface SurfUserInfo : NSObject

@property(nonatomic) long userId;
@property(nonatomic) NSString* userName;
@property(nonatomic) NSString* password;
@property(nonatomic) NSString* phoneNumber;
@property(nonatomic) NSString* phoneLocation;   //号码归属地

@end
