//
//  CReachability.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum
{
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"


@interface CReachability : NSObject
{
    BOOL localWiFiRef;
    SCNetworkReachabilityRef reachabilityRef;
}

+ (CReachability *)sharedInstance;
- (CReachability*)reachabilityWithHostName:(NSString*) hostName;
- (NetworkStatus) currentReachabilityStatus;


@end
