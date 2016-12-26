//
//  SubscribeViewController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "SubsChannelsListResponse.h"
#import "ThreadsManager.h"
#import "NewsWebController.h"
#import "HotInfomationInChannelView.h"

@interface SubscribeViewController : SurfNewsViewController <MultiDragDelegate,
ReadThreadContentDelegate, LoadContentDelegate,UIGestureRecognizerDelegate>
{
    HotChannelsView *_hotChannelsView;
    NSMutableArray *subsArray;    
    UIButton *subsButton;
    UIActivityIndicatorView *subsBtnLoading;
    BOOL _isSubs;               // 订阅按钮的订阅状态
}

@property (nonatomic,readonly) NSString *subscribeID;
@property (nonatomic,strong) SubsChannel *subsChannel;
@property (nonatomic)BOOL showSubscribeButton;  // 默认不显示订阅按钮
@property (nonatomic)BOOL showBackButton;       // 默认不显示返回按钮

@end
