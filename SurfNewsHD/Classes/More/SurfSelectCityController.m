//
//  SurfSelectCityController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfSelectCityController.h"
#import "WeatherManager.h"

@interface SurfSelectCityController ()

@end

@implementation SurfSelectCityController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = ViewTitleStateNone;
        cityArray = [NSMutableArray new];
        groupCityArray = [NSMutableArray new];
        letterArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#ifdef ipad
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0f, 20.0f, 178.0f, 30.0f)];
    titleImageView.image = [UIImage imageNamed:@"city_select"];
    [self.view addSubview:titleImageView];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(2.0f, 130.0f, 186.0f, 575.0f)
                                             style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor hexChangeFloat:@"535353"];
    [self.view addSubview:tableView];
    
//    currentCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 60.0f, 166.0f, 30.0f)];
//    [currentCityLabel setBackgroundColor:[UIColor clearColor]];
//    [currentCityLabel setFont:[UIFont systemFontOfSize:18.0f]];
//    [currentCityLabel setTextColor:[UIColor blackColor]];
//    [currentCityLabel setText:[NSString stringWithFormat:@"当前:%@",[[WeatherManager sharedInstance] weatherInfo].cityName]];
//    [self.view addSubview:currentCityLabel];
    
    UILabel *selectCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 100.0f, 166.0f, 30.0f)];
    [selectCityLabel setBackgroundColor:[UIColor clearColor]];
    [selectCityLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [selectCityLabel setTextColor:[UIColor hexChangeFloat:@"9B9696"]];
    [selectCityLabel setText:@"天气城市选择:"];
    [self.view addSubview:selectCityLabel];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(11.0f, 713.0f, 164.0f, 25.0f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"setting_back"]
                          forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(didBack)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    [self parseCityXml];
#else
    
    // 城市天气Label
    UIFont *font = [UIFont boldSystemFontOfSize:30.f];    
    CGRect weatherTabRect = CGRectMake(0.0f, .0f, kContentWidth, font.lineHeight+20.f);
    UIView *labelBG = [[UIView alloc] initWithFrame:weatherTabRect];
    [labelBG setBackgroundColor:[UIColor grayColor]];
    {
        // 城市天气Label
        weatherTabRect.origin.x = 10.f;
        weatherTabRect.size.width -= weatherTabRect.origin.x;    
        UILabel *weatherLabel = [[UILabel alloc] initWithFrame:weatherTabRect];
        [weatherLabel setText:@"城市天气"];
        [weatherLabel setTextAlignment:NSTextAlignmentLeft];
        [weatherLabel setTextColor:[UIColor blackColor]];
        [weatherLabel setFont:font];
        [weatherLabel setBackgroundColor:[labelBG backgroundColor]];
        [labelBG addSubview:weatherLabel];
        
        
        // 返回按钮
        float btnWidth = 50.0f, btnHeight = 30.0f;
        CGRect btnRect = CGRectMake(kContentWidth-btnWidth - 10.f,
                                    (weatherTabRect.size.height - btnHeight)*0.5,
                                    btnWidth,
                                    btnHeight);
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [backButton setFrame:btnRect];
//        [backButton setBackgroundImage:[UIImage imageNamed:@"setting_back"]
//                              forState:UIControlStateNormal];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton addTarget:self
                       action:@selector(didBack)
             forControlEvents:UIControlEventTouchUpInside];
        [labelBG addSubview:backButton];
    }
    [self.view addSubview:labelBG];
    

    
    
    
    // 当前城市
    UIFont *curCityFont = [UIFont systemFontOfSize:18.0f];
    CGRect curCityRect = CGRectMake(10.0f,
                                    weatherTabRect.origin.y + weatherTabRect.size.height,
                                    kContentWidth,
                                    curCityFont.lineHeight + 10.f);
    currentCityLabel = [[UILabel alloc] initWithFrame:curCityRect];
    [currentCityLabel setBackgroundColor:[UIColor clearColor]];
    [currentCityLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [currentCityLabel setTextColor:[UIColor blackColor]];
    [currentCityLabel setText:[NSString stringWithFormat:@"当前:%@",[[WeatherManager sharedInstance] curCity]]];
    [self.view addSubview:currentCityLabel];
    
    
    
    // 初始化天气列表
    CGRect tableRect = CGRectMake(2.0f,
                                  curCityRect.origin.y + curCityRect.size.height,
                                  kContentWidth,
                                  kContentHeight-weatherTabRect.size.height);
    tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor colorWithHexValue:0xFF535353];
    [self.view addSubview:tableView];
    

    // 解析城市XML文件
    [self parseCityXml];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//解析xml
- (void)parseCityXml
{
    [cityArray removeAllObjects];
    NSString * cityPath =[[NSBundle mainBundle] pathForResource:@"Citys" ofType:@"xml"];
    NSData *citysData = [NSData dataWithContentsOfFile:cityPath];
    
    // 解析xml文件内容
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:citysData];
    [parser setDelegate:self];
    [parser parse];
}

//按拼音分组城市
- (void)groupCityArray
{
    [groupCityArray removeAllObjects];
    [letterArray removeAllObjects];
    
#ifdef ipad
    
    NSString *groupPath = [NSString stringWithFormat:@"@distinctUnionOfObjects.%@", @"firstLetter"];
    letterArray = [cityArray valueForKeyPath:groupPath];
    
    for (NSString *groupValue in letterArray) {
        NSString *format = [NSString stringWithFormat:@"(%@ == '%@')", @"firstLetter", groupValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
        NSArray *array = [cityArray filteredArrayUsingPredicate:predicate];
        NSSortDescriptor* enDescriptor = [[NSSortDescriptor alloc]
                                                  initWithKey:@"en"
                                                  ascending:YES];
        NSArray* sortDescriptors = [NSArray arrayWithObject:enDescriptor];
        array = [array sortedArrayUsingDescriptors:sortDescriptors];
        [groupCityArray addObject:array];
    }
    
#else
    // 获取热门城市
    NSString *hotCityFormat = @"(isHot == '1')";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:hotCityFormat];
    NSArray *hotCityArray = [cityArray filteredArrayUsingPredicate:predicate];    
    NSSortDescriptor* enDescriptor = [[NSSortDescriptor alloc] initWithKey:@"en" ascending:YES];// 数组排序描述符号，根据en字段做升序
    NSArray* sortDescriptors = [NSArray arrayWithObject:enDescriptor];
    hotCityArray = [hotCityArray sortedArrayUsingDescriptors:sortDescriptors];  // 排序好的热门城市
    [groupCityArray addObject:hotCityArray];

    // 根据firstLetter字段来获取拼音队列
    NSString *groupPath = @"@distinctUnionOfObjects.firstLetter";
    [letterArray addObjectsFromArray:[cityArray valueForKeyPath:groupPath]];
    
    
    for (NSString *groupValue in letterArray) {
        NSString *format = [NSString stringWithFormat:@"(%@ == '%@')", @"firstLetter", groupValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
        NSArray *array = [cityArray filteredArrayUsingPredicate:predicate];
        NSSortDescriptor* enDescriptor = [[NSSortDescriptor alloc]
                                          initWithKey:@"en"
                                          ascending:YES];
        NSArray* sortDescriptors = [NSArray arrayWithObject:enDescriptor];
        array = [array sortedArrayUsingDescriptors:sortDescriptors];
        [groupCityArray addObject:array];
    }
    [letterArray insertObject:@"#" atIndex:0];
#endif
}




#pragma mark NSXMLParserDelegate method
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:@"city"]) {
        NSString *string = [attributeDict JSONString];
        CityInfo *city = [EzJsonParser deserializeFromJson:string AsType:[CityInfo class]];
        city.firstLetter = [city.en substringToIndex:1];
        [cityArray addObject:city];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    //解析错误
}

// xml解析完成
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self groupCityArray];  //按拼音分组城市
    [tableView reloadData];
}

#pragma mark -  UITableViewDataSource
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tView
{
    CMIndexBar *customIndex = [[CMIndexBar alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 30.0f, 130.0, 28.0, tableView.frame.size.height)];
    [customIndex setIndexes:letterArray];
    customIndex.textColor = [UIColor hexChangeFloat:@"9D9696"];
    [self.view addSubview:customIndex];
    customIndex.delegate = self;
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [groupCityArray count];
}

- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
#ifdef ipad
    NSArray *array = [groupCityArray objectAtIndex:section];
    return [array count];
#else
    return 1;
#endif
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
#ifndef ipad
    if (section == 0) {
         return @"热门城市";
    }
#endif
    
    NSArray *array = [groupCityArray objectAtIndex:section];
    CityInfo *city = [array objectAtIndex:0];                    //第一个肯定不会为空的
    return city.firstLetter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef ipad
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor hexChangeFloat:@"7B7777"];
        cell.textLabel.textColor = [UIColor hexChangeFloat:@"DED9D1"];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.contentView.backgroundColor = [UIColor hexChangeFloat:@"7B7777"];
        cell.contentView.layer.cornerRadius = 6.0f;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    NSArray *array = [groupCityArray objectAtIndex:indexPath.section];
    CityInfo *city = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = city.name;
    return cell;
#else
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor hexChangeFloat:@"7B7777"];
        cell.textLabel.textColor = [UIColor hexChangeFloat:@"DED9D1"];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.contentView.backgroundColor = [UIColor hexChangeFloat:@"7B7777"];
        cell.contentView.layer.cornerRadius = 6.0f;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    
    
    NSArray *array = [groupCityArray objectAtIndex:indexPath.section];
    CityInfo *city = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = city.name;
    return cell;

#endif
}

#pragma mark -  UITableViewDelegate methods
- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [groupCityArray objectAtIndex:indexPath.section];
    CityInfo *city = [array objectAtIndex:indexPath.row];
//    [currentCityLabel setText:[NSString stringWithFormat:@"当前: %@", city.name]];    
    WeatherManager *weatherMgr = [WeatherManager sharedInstance];
    if (![city.name isEqual:([weatherMgr weatherInfo].cityName)]) {
        [weatherMgr setCurCity:city.name cityId:city.cityId];
        [weatherMgr updateWeatherInfo];
    }
    [tView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)tableView:(UITableView *)tView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 166.0f, 30.0f)];
    sectionTitle.text = [self tableView:tableView titleForHeaderInSection:section];
    sectionTitle.font = [UIFont systemFontOfSize:18.0f];
    sectionTitle.backgroundColor = [UIColor clearColor];
    sectionTitle.textColor = [UIColor hexChangeFloat:@"9D9696"];
    [view addSubview:sectionTitle];
    return view;
}

- (void)indexSelectionDidChange:(CMIndexBar *)IndexBar
                               :(NSInteger)index
                               :(NSString*)title
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index - 1];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end
