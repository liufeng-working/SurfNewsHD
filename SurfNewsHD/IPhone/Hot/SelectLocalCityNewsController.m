//
//  SelectLocalCityNews.m
//  SurfNewsHD
//
//  Created by XuXg on 14/12/22.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SelectLocalCityNewsController.h"
#import "PhoneNotification.h"
#import "NSString+Extensions.h"
#import "UIColor+extend.h"
#import "AppSettings.h"
#import "WeatherView.h"
#import "CitySearchResultView.h"
#import "CMIndexBar.h"
#import "NetworkStatusDetector.h"

#define HeadHeight 27.f //区头高度
#define CellHeight 40.f //每个cell的高度
#define SearchBarWidth 292.f //搜索框宽度
#define SearchBarHeight 32.f //搜索框高度
#define SearchBarAndTopDis 7.f //搜索框距离上下的间距
#define LeftDistance 27.5f //城市名距离左边的间距
#define RightLetterWidth 40.f //右侧字母区域的宽度
#define RightLetterAndTop 5.f //右侧字母区域与上下的间隔
#define LetterFontSize 16 //右边字母字体大小
#define delayhidden 2 //隐藏字母提示框的时间
#define SearchBarFont [UIFont systemFontOfSize:19]; //搜索框占位符字体
#define HeadTitleFont [UIFont systemFontOfSize:18]; //区头字母字体大小
#define CityNameFont [UIFont systemFontOfSize:20]; //城市cell字体大小
#define tipLetterFont [UIFont boldSystemFontOfSize:40]; //提示字母的字体大小

@interface SelectLocalCityNewsController ()<UITableViewDelegate,UITableViewDataSource,CMIndexBarDelegate,UITextFieldDelegate,CitySearchResultViewDelegate>

@end

@implementation SelectLocalCityNewsController {
    UITableView *_tableView;
    WeatherInfo *_locationCityInfo;      //定位的城市信息
    NSMutableArray * _allCityArray;      //所有城市
    NSMutableArray * _cityArray;         //按字母分组的所有城市
    NSMutableArray * _firstLetterArray;  //首字母
    UIImageView * _letterBg;             //提示框字母的背景
    NSTimer * _timer;                    //定时器
    UITextField * _textField;            //输入框
    UIView * _placeHoldView;             //搜索框，占位视图
    CitySearchResultView * _resultView;  //展示搜索到的城市
}

-(id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.titleState = PhoneSurfControllerStateTop;
    _allCityArray = [[NSMutableArray alloc]initWithCapacity:0];
    _cityArray = [[NSMutableArray alloc]initWithCapacity:0];
    _firstLetterArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //页面标题
    [self setTitle:[NSString stringWithFormat:@"当前位置-%@",[self getCurCityName]]];

    //创建表
    [self creatTableView];
    
    //搜索框
    [self creatSearchBar];

    //定位城市
    [self getLocaltionCityInfo];
    
    //获取城市列表(提前获取，否则进入这个页面会很慢)
    [self initCityListCtrl];
}

//创建表
-(void)creatTableView
{
    CGFloat sY = [self StateBarHeight] + SearchBarHeight + SearchBarAndTopDis * 2;
    CGFloat sH = kContentHeight - sY;
    CGRect sr = CGRectMake(.0f,sY, kContentWidth,sH);
    _tableView = [[UITableView alloc] initWithFrame:sr style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
}

//创建搜索框
-(void)creatSearchBar
{
    UIFont * font = SearchBarFont
    CGFloat searchW = SearchBarWidth, searchH = SearchBarHeight;
    CGFloat searchX = (kContentWidth - searchW) / 2.0, searchY = [self StateBarHeight] + SearchBarAndTopDis;
    CGRect searchR = CGRectMake(searchX, searchY, searchW, searchH);
    
    UITextField * tF = [[UITextField alloc]initWithFrame:searchR];
    _textField = tF;
    tF.delegate = self;
    tF.clearButtonMode = UITextFieldViewModeWhileEditing;
    tF.backgroundColor = [UIColor whiteColor];
    tF.borderStyle = UITextBorderStyleRoundedRect;
    tF.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:tF];
    //给输入框添加方法
    [tF addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    _placeHoldView=[[UIView alloc]initWithFrame:tF.bounds];
    _placeHoldView.userInteractionEnabled = NO;
    _placeHoldView.backgroundColor = [UIColor clearColor];
    [tF addSubview:_placeHoldView];
    
    
    CGFloat lW = 100.f,lH = font.lineHeight;
    CGFloat lY = (searchH - lH) / 2.0;
    UILabel * placeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, lY, lW, lH)];
    CGPoint center = _placeHoldView.center;
    center.x += 20;
    placeLabel.center = center;
    placeLabel.text = @"搜索城市";
    placeLabel.font = font;
    placeLabel.textColor = [UIColor colorWithHexString:@"eeeeee"];
    placeLabel.backgroundColor = [UIColor clearColor];
    [placeLabel sizeToFit];
    [_placeHoldView addSubview:placeLabel];
    
    CGFloat imgW = 20.f, imgH = 20.f;
    CGFloat ImgX = CGRectGetMinX(placeLabel.frame) - imgW - 5.f,imgY = (searchH - imgH) / 2.0;
    UIImageView * searchImageview = [[UIImageView alloc] initWithFrame:CGRectMake(ImgX, imgY, imgW, imgH)];
    [searchImageview setImage:[UIImage imageNamed:@"searchImageView"]];
    [_placeHoldView addSubview:searchImageview];
}

//定位用户当前所在城市的信息
-(void)getLocaltionCityInfo
{
    // 查看App 是否支持定位服务
    if ([[WeatherManager sharedInstance] isSuportLocationServices]) {
        // 请求GPS定位
        
        [[WeatherManager sharedInstance] locationCityWeather:^(WeatherInfo *newWeather)
         {
             if (newWeather) {
                 _locationCityInfo = newWeather;
                 
                 //定位到城市再去添加表头
                 [self setHeadView];
             }
         }];
    }
    else{
        _locationCityInfo = nil;
        [PhoneNotification autoHideWithText:@"请打开定位，让我们更好的为您服务"];
    }
}

//添加表头
-(void)setHeadView
{
    //如果定位城市和用户当前选择城市相同，或者定位失败，则不显示
    NSString * localtionCityName = [self getLocaltionCityName];
    if ([localtionCityName isEqualToString:[self getCurCityName]] || !localtionCityName) {
        return;
    }
    
    //标识符
    UIImage * iconImg = [UIImage imageNamed:@"localcity_noExpand_icon"];
    CGFloat headImgH = iconImg.size.height;
    
    CGFloat hH = headImgH + 13.f * 2;
    UIControl * headView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, kContentWidth, hH)];
    headView.backgroundColor = [UIColor whiteColor];
    [headView addTarget:self action:@selector(localtionCityClick) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat headImgW = iconImg.size.width;
    CGFloat headImgX = LeftDistance; CGFloat headImgY = (hH - headImgH)/2.0;
    UIImageView * headImg = [[UIImageView alloc]initWithFrame:CGRectMake(headImgX, headImgY, headImgW, headImgH)];
    headImg.image = [UIImage imageNamed:@"localcity_noExpand_icon"];
    [headView addSubview:headImg];
    
    //位置信息
    UIFont * font = CityNameFont
    CGFloat titleX = headImgX + headImgW + 12.5f;
    CGFloat titleH = font.lineHeight;
    CGFloat titleY = (hH - titleH)/2.0;
    CGFloat titleW = 100.f;//先给个宽度，后面自适应大小
    CGRect titleRect = CGRectMake(titleX, titleY, titleW, titleH);
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:titleRect];
    NSString * titleName = [NSString stringWithFormat:@"您可能在: %@",localtionCityName];
    titleLabel.text = titleName;
    titleLabel.textColor = [UIColor colorWithHexString:@"333333"];
    titleLabel.font = font;
    [headView addSubview:titleLabel];
    [titleLabel sizeToFit]; //根据文字大小，自适应
    
    //添加区头
    _tableView.tableHeaderView = headView;
}

//获取当前选中的城市名
-(NSString *)getCurCityName
{
    //获取当前城市名
    NSString * curCityName = [AppSettings stringForKey:StringKey_LocalCity];
    
    //用户未选择，显示默认城市；用户从天气页面选择，显示选择的对应城市
    if (!curCityName || [curCityName isEmptyOrBlank]) {
        curCityName = [[[WeatherManager sharedInstance] weatherInfo] cityName];
    }
    
    //如果经过前面，还没有对应城市，则直接设置为无选中城市
    if(!curCityName || [curCityName isEmptyOrBlank]){
        curCityName = @"无";
    }

    return curCityName;
}

//获取用户所在的城市名
-(NSString *)getLocaltionCityName
{
    return _locationCityInfo.cityName;
}

//定位的城市，被点击了
-(void)localtionCityClick
{
    [self goCityNewsWithCityName:_locationCityInfo.cityName withCityId:_locationCityInfo.cityId];
}

//准备城市信息(数据源)
-(void)initCityListCtrl
{
    CityRssData *cities = [[CityManager sharedInstance] getCityRssData];
    NSMutableArray *cityList = (NSMutableArray *)[cities cityRssList];
    if (!cityList || [cityList count] <= 0) {
        return;
    }
    
    //给城市信息增加一个字段
    for (CityRssListData * d in cityList) {
        NSString * firstName = [d.enName getFitstLetter];
        if (firstName) {
            d.firstLetter = firstName;
            
            //搜索时，用_allCityArray这个数组
            [_allCityArray addObject:d];
        }
    }
    
    //从新按首字母分组
    [self groupCityArrayWithCityArray:_allCityArray];

    //应该是设置夜间模式
    [self nightModeChanged:[ThemeMgr sharedInstance].isNightmode];
}

//按拼音分组城市
- (void)groupCityArrayWithCityArray:(NSMutableArray *)cityArray
{
    //先清空信息
    [_cityArray removeAllObjects];
    [_firstLetterArray removeAllObjects];

    // 根据firstLetter字段来获取拼音队列
    NSString *groupPath = @"@distinctUnionOfObjects.firstLetter";
    [_firstLetterArray addObjectsFromArray:[cityArray valueForKeyPath:groupPath]];
    
    for (NSString *groupValue in _firstLetterArray) {
        NSString *format = [NSString stringWithFormat:@"(%@ == '%@')", @"firstLetter", groupValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
        NSArray *array = [cityArray filteredArrayUsingPredicate:predicate];
        
        //虽然服务器已经排序了，但这里我还是多此一举的进行了排序，防止服务器哪天不高兴不给我们排序了
        NSSortDescriptor* enDescriptor = [[NSSortDescriptor alloc]
                                          initWithKey:@"enName"
                                          ascending:YES];
        NSArray* sortDescriptors = [NSArray arrayWithObject:enDescriptor];
        array = [array sortedArrayUsingDescriptors:sortDescriptors];
        [_cityArray addObject:array];
    }
    
    //刷新表
    [_tableView reloadData];
}

//键盘隐藏
-(void)hiddenKerboard
{
    [_textField resignFirstResponder];
}

//点击空白处时，键盘消失
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self hiddenKerboard];
}

//
-(void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
}

#pragma mark - 点击了城市，跳转
-(void)goCityNewsWithCityName:(NSString *)cityName withCityId:(NSString *)cityId
{
    NetworkStatusType type = [NetworkStatusDetector currentStatus];
    if (type != NSTNoWifiOrCellular && type != NSTUnknown)
    {
        [AppSettings setString:cityName forKey:StringKey_LocalCity];
        [AppSettings setString:cityId forKey:StringKey_LocalCityID];
    }else{
        [PhoneNotification autoHideWithText:@"网络异常!"];
    }
    
    // 返回
    [self dismissBackController];
}

#pragma mark - UITextFile 绑定的方法
-(void)textFieldChanged:(UITextField *)textField
{
    //根据输入文字变化，动态改变展示内容
    if (textField.text.length > 0) {
        
        if (!_resultView) {
            _resultView = [[CitySearchResultView alloc]initWithFrame:_tableView.frame];
            _resultView.delegate = self;
            _resultView.backgroundColor = [UIColor colorWithHexValue:0xFFF8F8F8];
            [self.view addSubview:_resultView];
        }else{
            if (![self.view.subviews containsObject:_resultView]) {
                [self.view addSubview:_resultView];
            }
        }
        
        //从所有城市中，检索出符合要求的城市
        NSMutableArray * resultArray = [NSMutableArray array];
        for (CityRssListData * info in _allCityArray) {
            if([info.cityName containsCasInsensitive:textField.text])
                [resultArray addObject:info];
        }
        _resultView.cityListArray = resultArray;
        
    }else{
        //如果输入的字符长度变为0，则移除这个view
        if (_resultView) {
            [_resultView removeFromSuperview];
        }
    }
}

#pragma mark- UITableView 代理
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    CGRect rect = tableView.frame;
    
    CGFloat barW = RightLetterWidth;
    CGFloat barX = rect.size.width - barW - RightLetterAndTop;
    CGFloat barY = rect.origin.y + RightLetterAndTop;
    CGFloat barH = kContentHeight - barY - RightLetterAndTop;
    CGRect barR = CGRectMake(barX, barY, barW, barH);
    CMIndexBar *customIndex = [[CMIndexBar alloc] initWithFrame:barR];
    customIndex.textFontSize = LetterFontSize;
    [customIndex setIndexes:_firstLetterArray];
    customIndex.delegate = self;
    [self.view addSubview:customIndex];
    
    if ([ThemeMgr sharedInstance].isNightmode) {
        customIndex.textColor = [UIColor whiteColor];
        customIndex.backgroundColor = [UIColor colorWithHexValue:0x222223];
    }
    else{
        customIndex.textColor = [UIColor colorWithHexString:@"666666"];
        customIndex.backgroundColor = [UIColor clearColor];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _cityArray.count;
    
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSArray * arr = _cityArray[section];
    return arr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identCity = @"city_cell";
    CityRssListData * info = _cityArray[indexPath.section][indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identCity];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identCity];
        UILabel * cityNameL = [[UILabel alloc]initWithFrame:CGRectMake(LeftDistance, 0, kContentWidth - LeftDistance, CellHeight)];
        cityNameL.tag = 2;
        cityNameL.font = CityNameFont;
        cityNameL.textColor = [UIColor colorWithHexString:@"333333"];
        cityNameL.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:cityNameL];
    }
    
    //城市名称
    UILabel * cityName = (UILabel *)[cell.contentView viewWithTag:2];
    cityName.text = info.cityName;
    return cell;
}

//区头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HeadHeight;
}

//返回区头视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString * idetiHead = @"identiHead";
    UITableViewHeaderFooterView * headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:idetiHead];
    if (!headView) {
        headView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:idetiHead];
        headView.frame = CGRectMake(0, 0, kContentWidth, HeadHeight);
        CGRect rect = headView.bounds;
        rect.origin.x += LeftDistance;
        UILabel * headLabel = [[UILabel alloc]initWithFrame:rect];
        headLabel.backgroundColor = [UIColor clearColor];
        headLabel.textColor = [UIColor colorWithHexString:@"666666"];
        headLabel.font = HeadTitleFont
        headLabel.tag = 1;
        [headView addSubview:headLabel];
    }
    
    UILabel * headLabel = (UILabel *)[headView viewWithTag:1];
    headLabel.text = _firstLetterArray[section];//每个区头的标题
    return headView;
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CityRssListData * info = _cityArray[indexPath.section][indexPath.row];
    
    [self goCityNewsWithCityName:info.cityName withCityId:info.cityId];
}

#pragma mark - ****UIScrollView 代理****
//滑动屏幕时，键盘下去
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hiddenKerboard];
}

#pragma mark - ****UITextFile 代理****
//开始编辑
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _placeHoldView.hidden = YES;
    return YES;
}

//结束编辑
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //根据有无文字，判断占位符是否显示
    [_placeHoldView setHidden:textField.text.length != 0];
}

//点击了搜索按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //点击搜索按钮，键盘下去
    [self hiddenKerboard];
    
    if (textField.text.length == 0) {
        [PhoneNotification autoHideWithText:@"请输入关键字"];
        return NO;
    }

    return YES;
}

#pragma mark - ****CitySearchResultViewDelegate****
- (void)didSelectCityAtCityInfo:(CityRssListData *)info
{
    [self goCityNewsWithCityName:info.cityName withCityId:info.cityId];
}

-(void)scrollViewBeginDragging
{
    [self hiddenKerboard];
}

#pragma mark - ****CMIndexBar 代理****
- (void)indexSelectionDidChange:(CMIndexBar *)IndexBar :(NSInteger)index :(NSString*)title
{
    if (!_letterBg) {
        UIImage * letterImg = [UIImage imageNamed:@"letterBgImg"];
        CGFloat bW = letterImg.size.width;
        CGFloat bH = letterImg.size.height;
        _letterBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, bW, bH)];
        _letterBg.center = self.view.center;
        _letterBg.image = letterImg;
        [self.view addSubview:_letterBg];
        
        UILabel * letterLabel=[[UILabel alloc]initWithFrame:_letterBg.bounds];
        letterLabel.tag = 3;
        letterLabel.backgroundColor = [UIColor clearColor];
        letterLabel.textColor = [UIColor whiteColor];
        letterLabel.textAlignment = NSTextAlignmentCenter;
        letterLabel.font = tipLetterFont
        [_letterBg addSubview:letterLabel];
    }else{
        if (![self.view.subviews containsObject:_letterBg]) {
            [self.view addSubview:_letterBg];
        }
    }
    //根据滑动，改变提示字母
    UILabel * letterLabel = (UILabel *)[_letterBg viewWithTag:3];
    letterLabel.text = _firstLetterArray[index - 1];
    
    //滑动到指定位置
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:index-1];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

//触摸结束，调用的方法
-(void)touchEnd
{
    //重新开启定时器
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:delayhidden target:self selector:@selector(hiddenLetterTip) userInfo:nil repeats:YES];
}

//隐藏字母提示框
-(void)hiddenLetterTip
{
    [_letterBg removeFromSuperview];
}

@end
