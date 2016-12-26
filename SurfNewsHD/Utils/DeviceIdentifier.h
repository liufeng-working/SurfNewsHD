//
//  DeviceIdentifier.h
//  SurfNewsHD
//
//  Created by SYZ on 14-3-26.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface DeviceIdentifier : NSObject

//获得IMSI
+ (NSString *)getIMSI;
//获得运营商
+ (NSString *)getCarrier;
//运营商是否是中国移动
+ (BOOL)carrierIsChinaMobile;

+ (NSString*)getDeviceId;

@end
