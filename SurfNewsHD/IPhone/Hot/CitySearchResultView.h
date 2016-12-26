//
//  CitySearchResultView.h
//  SurfNewsHD
//
//  Created by NJWC on 16/1/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectLocalCityNewsController.h"

@protocol CitySearchResultViewDelegate <NSObject>

@required
//选择城市后调用
-(void)didSelectCityAtCityInfo:(CityRssListData *)info;

//滑动屏幕时调用
-(void)scrollViewBeginDragging;

@end

@interface CitySearchResultView : UIView

@property(nonatomic,strong)NSArray * cityListArray;  //用于装搜索到的城市
@property(nonatomic,weak)id<CitySearchResultViewDelegate> delegate;

@end
