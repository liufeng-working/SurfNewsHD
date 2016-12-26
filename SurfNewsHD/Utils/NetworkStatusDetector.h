//
//  NetworkStatusDetector.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-8-20.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

//@desc:利用私有API快速检测当前网络状况

typedef enum
{
    NSTUnknown = -1,
    NSTNoWifiOrCellular = 0,
    NST2G = 1,
    NST3G = 2,
    NST4G = 3,
    NSTLTE = 4,
    NSTWifi = 5
    
} NetworkStatusType;


@interface NetworkStatusDetector : NSObject

+(NetworkStatusType) currentStatus;

@end
