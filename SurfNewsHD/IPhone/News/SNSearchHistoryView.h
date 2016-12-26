//
//  SNSearchHistoryView.h
//  SurfNewsHD
//
//  Created by XuXg on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SNSearchHistoryDelegate <NSObject>

// 搜索历史记录
-(void)searchHistory:(id)userInfo;


-(void)addSearchHistory:(id)userInfo;

// 删除历史记录
-(void)deleateSearchHistory:(id)userInfo;
// 清除历史记录
-(void)clearSearchHistory;
@end



@interface SNSearchHistoryView : UIView


@property(nonatomic,weak)id<SNSearchHistoryDelegate>delegate;

-(void)loadDataWithHistoryArray:(NSArray*)historyList;
@end
