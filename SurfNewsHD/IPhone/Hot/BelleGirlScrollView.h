//
//  BelleGirlScrollView.h
//  SurfNewsHD
//
//  Created by XuXg on 15/11/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNPictureSummaryView.h"
#import "SNToolBar.h"



/**********************美女浏览页*****************************/
@protocol BelleGirlScrollViewDelegate <NSObject>
- (void)didBackBt;
- (void)didShareBt:(id)info;
- (void)snRequestMoreBeauties; // 请求更多美女频道
@end


@interface BelleGirlScrollView : UIView

@property(nonatomic,strong)SNPictureSummaryView *tipsView;
@property (nonatomic, weak)id<BelleGirlScrollViewDelegate>delegate;

-(void)loadBeauties:(NSArray *)beauties
           curIndex:(NSUInteger)index;


-(void)loadMoreBeauties:(NSArray*)beauties;
- (SNToolBar *)getSNToolBar;



@property (nonatomic, readonly)ThreadSummary *selectThread;




@end
