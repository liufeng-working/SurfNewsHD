//
//  SearchChannelController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-6-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "SearchBoxView.h"
#import "AddSubscribeView.h"
#import "SubsChannelsListResponse.h"
#import "SubsChannelSummaryViewController.h"

/**
 SYZ -- 2014/08/11
 SearchChannelController实现搜索RSS源的功能
 输入框里文字的变化可实现即时搜索本地的
 当点击键盘右下角的搜索按键时执行联网搜索,具体请参考SearchBoxView类里的实现
 */

@interface SearchChannelController : PhoneSurfController <SearchBoxViewDelegate, AddSubscribeViewDelegate>
{
    AddSubscribeView *addSubscribeView;
    SearchBoxView *searchBoxView;
    UIButton *backButton;
    
    NSMutableArray *searchResultArray;
    
    BOOL isNightMode;
    BOOL isLoading;
    int page;
    NSString *searchText_;
    float searchBoxViewY;
    
    BOOL keyboardShowing;
}

@property(nonatomic, strong) NSMutableArray *allChannelsArray;

@end
