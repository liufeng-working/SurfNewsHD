//
//  SNSearchListView.h
//  SurfNewsHD
//
//  Created by XuXg on 15/9/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadSummary.h"

/**
 *  选择搜索新闻
 */
@protocol SelectSearchNewDeleate <NSObject>

-(void)selectSearchNew:(ThreadSummary*)ts;

@end


@interface SNSearchListView : UIView

@property(nonatomic,weak)id<SelectSearchNewDeleate> deleate;


-(void)searchWithKeyword:(NSString*)keyword;
@end
