//
//  PhoneSearchCityView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBoxView.h"
#import "PhoneSelectCityCell.h"

@class SelectCityCellData;
@class WeatherInfo;


@interface PhoneSearchCityView : UIView<SearchBoxViewDelegate,
UITableViewDelegate, UITableViewDataSource,SelectCityDelegate>{
    SearchBoxView *_searchBoxView;
    UITableView * _resultTableView;
    float _tableViewHeight;
    SelectCityCellData *_cellData;
    PhoneSelectCityCell *_selectCityCell;
    UIButton *_backButton;
    BOOL keyboardShowing;
    UIButton *miniButton;
    UIView *toolsBottomBar;
}
@property(nonatomic,strong) NSArray *dateSource;
@end
