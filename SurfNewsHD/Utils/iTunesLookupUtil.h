//
//  iTunesLookupUtil.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>


#define CALLBACK        @"callback"


@protocol iTunesLookupUtilDelegate;

@interface iTunesLookupUtil : NSObject<UIAlertViewDelegate>
{
    NSInteger  openTimes;
    

}
@property (nonatomic, assign) id<iTunesLookupUtilDelegate>    delegate;
@property (nonatomic, strong) NSString *updateUrl;
@property (nonatomic, assign) BOOL  isError;
@property (nonatomic, assign) BOOL  hasNewVersion;
@property (nonatomic, copy)   NSString    *upDateStr;
@property (nonatomic, readonly) BOOL  isLoading;
@property (nonatomic, assign) BOOL  isMT;
@property (nonatomic, copy)    NSString *enterpriseStr;

+ (iTunesLookupUtil *)sharedInstance;

- (void)checkUpdate;

@end


@protocol iTunesLookupUtilDelegate <NSObject>

- (void)didFinishiUpdate:(iTunesLookupUtil *)offR;

@end