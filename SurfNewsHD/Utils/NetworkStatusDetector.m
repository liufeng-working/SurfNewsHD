//
//  NetworkStatusDetector.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-8-20.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NetworkStatusDetector.h"

@implementation NetworkStatusDetector

+(NetworkStatusType) currentStatus
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"]    subviews];
    NSNumber *dataNetworkItemView = nil;
    //UIStatusBarDataNetworkItemView
    NSString *str = [NSString stringWithFormat:@"%@StatusBar%@Network%@View", @"UI",@"Data",@"Item"];
    Class cls = [NSClassFromString(str) class];
    
    for (id subview in subviews)
    {
        if([subview isKindOfClass:cls])
        {
            dataNetworkItemView = subview;
            break;
        }
    }
    if(dataNetworkItemView)
        return [[dataNetworkItemView valueForKey:@"dataNetworkType"] intValue];
    else
        return NSTUnknown;
}

@end
