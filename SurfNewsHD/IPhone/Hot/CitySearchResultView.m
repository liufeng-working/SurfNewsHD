//
//  CitySearchResultView.m
//  SurfNewsHD
//
//  Created by NJWC on 16/1/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "CitySearchResultView.h"
#import "UIColor+extend.h"

@interface CitySearchResultView ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableView; //用于展示搜索到的城市
    UILabel * _tipLabel;    //用于提示用户有没有对应城市
}

@end

@implementation CitySearchResultView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc]initWithFrame:self.bounds];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        UIFont * font = [UIFont systemFontOfSize:15];
        CGFloat tW = kContentWidth;
        CGFloat tH = font.lineHeight;
        CGFloat tY = 18.f;
        UILabel * tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(0.f, tY, tW, tH)];
        _tipLabel = tipLabel;
        tipLabel.font = font;
        tipLabel.text = @"无对应城市";
        tipLabel.textColor = [UIColor colorWithHexString:@"333333"];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:tipLabel];
    }
    
    return self;
}

//重写set方法，每次有改变都会调用
-(void)setCityListArray:(NSArray *)cityListArray
{
    _cityListArray = cityListArray;
    
    //获取新的数据，刷新表
    [_tableView reloadData];
    
    //根据有没有搜索到城市，确定提示信息是否显示
    [_tipLabel setHidden:cityListArray.count > 0];
    [_tableView setHidden:cityListArray.count <= 0];
}

#pragma mark - ****UITableView 代理****
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cityListArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cityListCell";
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        UILabel * cityNameL = [[UILabel alloc]initWithFrame:CGRectMake(39.5f, 0, kContentWidth - 39.5f, 44.f)];
        cityNameL.tag = 1;
        cityNameL.font = [UIFont systemFontOfSize:20];
        cityNameL.textColor = [UIColor colorWithHexString:@"333333"];
        cityNameL.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:cityNameL];
    }
    
    //城市名称
    UILabel * cityName = (UILabel *)[cell.contentView viewWithTag:1];
    CityRssListData * info = _cityListArray[indexPath.row];
    cityName.text = info.cityName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityRssListData * info = _cityListArray[indexPath.row];
    if ([_delegate respondsToSelector:@selector(didSelectCityAtCityInfo:)]) {
        [_delegate didSelectCityAtCityInfo:info];
    }
}

#pragma mark - ****UIScrollView Delegate****
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(scrollViewBeginDragging)]){
        [_delegate scrollViewBeginDragging];
    }
}

@end
