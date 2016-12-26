//
//  DeviceIdentifier.m
//  SurfNewsHD
//
//  Created by SYZ on 14-3-26.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "DeviceIdentifier.h"
#import "NSString+Extensions.h"
#import "AppSettings.h"
#import "OpenUDID.h"
#include <dlfcn.h>

#define PRIVATE_PATH  "/System/Library/PrivateFrameworks/CoreTelephony.framework/CoreTelephony"


@implementation DeviceIdentifier

+ (NSString *)getIMSI
{
    NSString *imsi = nil;
#ifdef JAILBREAK
    #if !TARGET_IPHONE_SIMULATOR
        void *kit = dlopen(PRIVATE_PATH, RTLD_LAZY);
        NSString * (*CTSIMSupportCopyMobileSubscriberIdentity)() = dlsym(kit, "CTSIMSupportCopyMobileSubscriberIdentity");
        imsi = CTSIMSupportCopyMobileSubscriberIdentity(nil);
        dlclose(kit);
    #endif
#else
    if (!IOS7) {
        #if !TARGET_IPHONE_SIMULATOR
            void *kit = dlopen(PRIVATE_PATH, RTLD_LAZY);
            NSString * (*CTSIMSupportCopyMobileSubscriberIdentity)() = dlsym(kit, "CTSIMSupportCopyMobileSubscriberIdentity");
            imsi = CTSIMSupportCopyMobileSubscriberIdentity(nil);
            dlclose(kit);
        #endif
    }
#endif
    return imsi;
}

+ (NSString *)getCarrier
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    return [carrier carrierName];
}

+ (BOOL)carrierIsChinaMobile
{
    if ([[DeviceIdentifier getCarrier] isEqualToString:@"中国移动"]) {
        return YES;
    }
    return NO;
}

+ (NSString*)getDeviceId
{
    NSString* didSaved = [AppSettings stringForKey:STRINGKEY_DEVICE_ID];
    if(didSaved && [didSaved length]) {
        return didSaved;
    } else {
        NSString* UID = nil;
            
        //狗日的ios7+，OpenUDID已经被搞死了
        if([[[UIDevice currentDevice] systemVersion] isVersionHigherThanOrEqualsTo:@"7.0"]) {
            
            //使用IDFA
            NSMutableString* s = [NSMutableString stringWithString:@"/System/Library/Priv"];
            [s appendString:@"ateFrameworks/A"];
            [s appendString:@"dSupport.framework/A"];
            [s appendString:@"dSupport"];
            void *addll = dlopen([s UTF8String], RTLD_LAZY);
            
            Class kls = NSClassFromString([NSString stringWithFormat:@"%@dentifierM%@", @"ASI", @"anager"]);
            StartSuppressPerformSelectorLeakWarning
            UID = [[[kls performSelector:NSSelectorFromString(@"sharedManager")] performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@isingId%@", @"advert", @"entifier"])] performSelector:NSSelectorFromString(@"UUIDString")];
            EndSuppressPerformSelectorLeakWarning
            dlclose(addll);
    
            //实在获取不到，使用UUID
            if(!UID || [UID length] == 0) {
                UID = [[NSUUID UUID] UUIDString];
            }
        }
        else {
            UID = [OpenUDID value];
        }
        
        [AppSettings setString:UID forKey:STRINGKEY_DEVICE_ID];
        
        return UID;
    }
}

@end
