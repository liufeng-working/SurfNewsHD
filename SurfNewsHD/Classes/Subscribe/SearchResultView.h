//
//  SearchResultView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-15.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubscribeCenterCell.h"
#import "SubscribeCenterCellSubitem.h"

@interface SearchResultView : UIView<SubsCellSubitemClickObserver>{
    UIScrollView *_scrollView;
    NSMutableArray *_searchArray;
}
@property(nonatomic,weak)id<SubscribeCenterCellDelegate> delegate;
- (void)showSearchResutlWithSearchText:(NSString *)text subscribeArray:(NSArray *)array;
- (void)checkSubsChannelState; // 检查订阅状态
@end
