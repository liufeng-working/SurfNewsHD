//
//  SurfSelectCityController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "EzJsonParser.h"
#import "CityInfo.h"
#import "CMIndexBar.h"

@interface SurfSelectCityController : SurfNewsViewController <NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, CMIndexBarDelegate>
{
    NSMutableArray *cityArray;
    NSMutableArray *groupCityArray;
    NSMutableArray *letterArray;
    UITableView *tableView;    
//    UILabel *currentCityLabel;
}

@end
