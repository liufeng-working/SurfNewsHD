//
//  PhoneSelectCityController.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "EzJsonParser.h"
#import "CityInfo.h"
#import "CMIndexBar.h"
#import "PhoneSelectCityCell.h"
#import "SearchBoxView.h"

@class SearchBoxControl;
@class PhoneSearchCityView;


@interface PhoneSelectCityController : PhoneSurfController <NSXMLParserDelegate,
UITableViewDataSource, UITableViewDelegate, CMIndexBarDelegate, SelectCityDelegate>
{
    NSMutableArray *cityArray;
    NSMutableArray *groupCityArray;
    NSMutableArray *letterArray;
    UITableView *tableView;
    SearchBoxControl *_searchBoxControl;
    
    PhoneSearchCityView *_searchView;
}


// 隐藏搜索城市
- (void)hiderSearchCityView;

- (void)didBack;    // 推出Controller
@end
