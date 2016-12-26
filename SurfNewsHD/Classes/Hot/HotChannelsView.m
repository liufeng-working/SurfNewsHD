//
//  HotChannelsView.m
//  SurfNewsHD
//
//  Created by apple on 13-1-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotChannelsView.h"
#import "ThreadsManager.h"
#import "HotChannelsListResponse.h"
#import "SNLoadingMoreCell.h"
#import "PhoneHotRootcontroller.h"
#import "stockMarketInfoManager.h"
#import "RssSourceData.h"
#import "PhoneSelectCityController.h"
#import "AppSettings.h"
#import "PhoneBeautyChannelCell.h"
#import "SNNewsListUIHelper.h"
#import "SNSpecialHeaderTableCell.h"
#import "SubsChannelsManager.h"
#import "AddSubscribeController.h"
#import "SubsTableViewCell.h"
#import "SurfSubscribeViewController.h"
#import "SNNotificationUtils.h"


#ifdef ipad
    #define kMarginTop 8.f
    #define kMarginRight 8.f
    #define kMarginBottom 0.f
    #define kMarginLeft 8.f
#else
    #define kMarginTop 0.f
    #define kMarginRight 0.f
    #define kMarginBottom 0.f
    #define kMarginLeft 0.f
    #define kStockInfoHeight 88.0f
#endif



#pragma mark- 本地城市频道Cell
@interface LocalCityNewsCell : SurfTableViewCell {
    UIImage *_bgImg;
    UIImage *_icon;
    NSString *_title;
    UIFont *_tF;
    CGSize _tSize;
    UIColor *_cityNColor;
    NSString *_desStr;
    CGSize _desSize;
    UIImage *_arrowImg;
}

@end

@implementation LocalCityNewsCell

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    
    _icon = [UIImage imageNamed:@"localIcon"];
    
    _title = @"当前城市：";
    _desStr = @"点击选择其他城市";
    _tF = [UIFont systemFontOfSize:13.f];
    NSDictionary *attributes = @{NSFontAttributeName:_tF};
    _tSize = [_title sizeWithAttributes:attributes];
    _desSize = [_desStr sizeWithAttributes:attributes];
 
    
    
    _arrowImg = [UIImage imageNamed:@"localArrow"];
    [self viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
    
    return self;
}


-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight) {
        _bgImg = [UIImage imageNamed:@"localCityNews_N"];
        _cityNColor = [UIColor whiteColor];
    }
    else{
        _bgImg = [UIImage imageNamed:@"localCityNews"];
        _cityNColor = [UIColor blackColor];
    }
    [self setNeedsDisplay];
}


-(void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    float w = CGRectGetWidth(self.bounds);
    float h = CGRectGetHeight(self.bounds);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    
    
    // 背景
    if (highlighted) {
        if ([ThemeMgr sharedInstance].isNightmode) {
            [[UIColor colorWithHexValue:kTableCellSelectedColor_N] setFill];
        }
        else{
            [[UIColor colorWithHexValue:kTableCellSelectedColor] setFill];
        }
        CGContextAddRect(context, rect);
    }
    else
        [_bgImg drawInRect:rect];
    
    
    // icon
    float iconX = 10.f;
    float iconW = _icon.size.width;
    float iconH = _icon.size.height;
    float iconY = (CGRectGetHeight(rect)- _icon.size.height)/2;
    [_icon drawInRect:CGRectMake(iconX, iconY, iconW, iconH)];
    
    
    // 标题
    float tY = (h - _tSize.height)/2;
    UIColor *tc = [UIColor colorWithHexValue:0xFFcc0000];
    CGRect tR = CGRectMake(iconX+iconW+8, tY, _tSize.width, _tSize.height);
    [_title surfDrawString:tR withFont:_tF
                 withColor:tc
             lineBreakMode:NSLineBreakByWordWrapping
                 alignment:NSTextAlignmentLeft];
    
    // 城市名
    CGRect cityR = CGRectOffset(tR, _tSize.width, 0);
    NSString *cityName = [AppSettings stringForKey:StringKey_LocalCity];
    if (!cityName || [cityName isEmptyOrBlank]) {
        cityName = [[[WeatherManager sharedInstance] weatherInfo] cityName];
    }
    [cityName surfDrawString:cityR withFont:_tF
                    withColor:_cityNColor
                lineBreakMode:NSLineBreakByWordWrapping
                    alignment:NSTextAlignmentLeft];
    
    
    
    // “点击选择其他省市” + 箭头
    float arrowW = _arrowImg.size.width;
    CGRect desR = {CGPointMake(w-8-arrowW-5-_desSize.width, tY),_desSize};
    [_desStr surfDrawString:desR withFont:_tF
                  withColor:tc
              lineBreakMode:0
                  alignment:NSTextAlignmentRight];
    // 箭头
    float ah = _arrowImg.size.height;
    float ax = desR.origin.x + desR.size.width;
    float ay = (h-ah)/2;
    CGRect aR = {CGPointMake(ax, ay),_arrowImg.size};
    [_arrowImg drawInRect:aR];
    
    
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}

@end

#pragma mark- 自定义tableCell数据模型
typedef NS_ENUM(NSUInteger, SNNewsCellType)
{
    kCellType_LocalCity,       // 本地城市
    kCellType_Stock,           // 财经频道
    kCellType_More,            // 更多
    kCellType_BeautyChannel,   // 美女频道
    kCellType_ThreadSummer,    // 新闻帖子
    kCellType_JokeChannel,     // 段子频道
    
    // 专题
    kCellType_SpecialHeader,
    kCellType_SpecialFood,
    
    // 订阅
    kCellType_SubsChennel,
    kCellType_AddSubsChannels,
};


@interface SNCellDataModel : NSObject

@property(nonatomic)SNNewsCellType cellType;
@property(nonatomic,strong)id ts;


@end
@implementation SNCellDataModel

@end

// 热门频道视图
@implementation HotChannelsView
@synthesize delegate;
@synthesize refreshDelegate;
@synthesize hotChannel = _hotChannel;


-(void)dealloc
{
    // 删除通知
    [SNNotificationUtils removerAllNotify:self];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        // Initialization code
        UIEdgeInsets edge = UIEdgeInsetsMake(kMarginTop, kMarginLeft, kMarginBottom, kMarginRight);
        CGRect tableRect =
        UIEdgeInsetsInsetRect(self.bounds, edge);
        tableview =
        [[UITableView alloc] initWithFrame:tableRect
                                     style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
        [tableview setBackgroundColor:[UIColor clearColor]];
        tableview.showsHorizontalScrollIndicator = NO;
        [tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:tableview];
        
        // hotBanner，在reloadChannels函数中加入到tableView
        CGRect bannerRect = CGRectMake(kMarginLeft,
                                       0.f, CGRectGetWidth(frame)-kMarginLeft-kMarginRight,
                                       [HotBannerView hotBannerHeight]);
        hotBannerView = [[HotBannerView alloc] initWithFrame:bannerRect];
        
        // 创建headerView和footerView
        CGRect rect = CGRectMake(0, 0 - frame.size.height, frame.size.width, frame.size.height);
        _headerView = [[LoadingView alloc] initWithFrame:rect atTop:YES];
        _headerView.style = StateDescriptionTableStyleTop;
        [tableview addSubview:_headerView];
        
        _cellsModel = [NSMutableArray arrayWithCapacity:30];
        // 初始化layouts
        _layouts = [NSMutableArray array];
        
        
        // 2015.5.5 modify by xuxg 因移动反应图片遮住文字和其它图片。修改图片尺寸（原来：28*28）
        TPlusIcon = [[UIImageView alloc] initWithFrame:CGRectMake(kContentWidth - 20, 2, 18, 18)];
        [TPlusIcon setImage:[UIImage imageNamed:@"t+"]];
        
        
        
        // 添加通知
        [SNNotificationUtils addNotifyObserver:self
                                      selector:@selector(selBeautyListPointerChanged:)
                                    notifyType:kNotifyType_BeautyList_Pointer_Changed];
        
    }
    return self;
}

// 美女新闻列表坐标发生改变
-(void)selBeautyListPointerChanged:(NSNotification *)noti
{
    if (![_hotChannel isBeautifulChannel] &&
        [noti.object isKindOfClass:[ThreadSummary class]]) {
        return;
    }
    
    
    // 验证数据源是否发生改变，改变从新加载数据
    NSInteger totalCoutn = [_cellsModel count];
    if ([[_cellsModel lastObject] cellType] == kCellType_More) {
        totalCoutn -= 1;
    }
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    NSArray *threads = [tm getLocalThreadsForHotChannel:_hotChannel];
    if ([threads count] > totalCoutn) {
        // 从新加载数据
        NSDate *refreshDate = [tm lastRefreshDateOfHotChannel:_hotChannel];
        [self reloadChannels:_hotChannel array:threads date:refreshDate];
    }
    
    
    // 开始定位图片位置
    ThreadSummary *showTs = noti.object;
    if(showTs && showTs.channelId == _hotChannel.channelId){
        // 让TableView滚动到可见区域
        //1 找到在资源中的下标
        NSInteger index = NSNotFound;
        for (NSInteger i=0; i < [_cellsModel count]; ++i) {
            SNCellDataModel *mode = _cellsModel[i];
            if (mode.cellType == kCellType_BeautyChannel &&
                [[mode ts] isKindOfClass:[ThreadSummary class]]) {
                if ([(ThreadSummary*)[mode ts] threadId] == showTs.threadId) {
                    index = i;
                    break;
                }
            }
        }
        
        if (index != NSNotFound) {
            // 说明我找到了这个美女频道
            NSIndexPath *indexPath =
            [NSIndexPath indexPathForRow:index inSection:0];
            [tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
        
    }
    
}

//T+新闻排序处理
- (NSArray *)sortTPlusThreadArrayFromChannelArray:(NSArray *)channelsArray
{
    NSMutableArray *sortArr = [NSMutableArray new];
    for (ThreadSummary *t in channelsArray) {
        if ([t isTPlusNews]) {
            [sortArr insertObject:t atIndex:0];
        }
        else{
            [sortArr addObject:t];
        }
    }
    return sortArr;
}

// 重新加载频道
-(void)reloadChannels:(HotChannel *)channel
                array:(NSArray *)channelsArray
                 date:(NSDate *)refreshDate
{
    // 恢复初始状态，清空
    [self recoverOriginalState];

    _hotChannel = channel;
    [self updateRefreshDate:refreshDate];   // 设置刷新时间
    
    NSMutableArray *tempThreads = nil;
    if ([channel isSubschannel]) {          // 是订阅频道
        
        tableview.tableHeaderView = [UIView new];
        
        // 订阅频道
        SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
        tempThreads = [scm visibleSubsChannels];
        if ([tempThreads count] == 0) {
            // 显示进入订阅频道
            [self showAddSubschannelView:YES];
        }
        else {
            [tableview setHidden:NO];
            [self showAddSubschannelView:NO];
            
            
            // 加载订阅频道数据
            for (NSInteger i=0; i<[tempThreads count]; ++i) {
                SNCellDataModel *cellData =
                [self createCellData:tempThreads[i]
                            cellType:kCellType_SubsChennel];
                [_cellsModel addObject:cellData];
            }
            
            // 进入添加订阅频道的cell
             [_cellsModel addObject:[self createCustomCellData:kCellType_AddSubsChannels]];
            
            [tableview reloadData];// 加载数据
        }
    }
    else {
        [self showAddSubschannelView:NO];
        [tableview setHidden:NO];
        
        if ([channel isHotChannel]) {   // 是热推频道
            tempThreads = [[self sortTPlusThreadArrayFromChannelArray:channelsArray] mutableCopy];
        }
        else {
            tempThreads = [channelsArray mutableCopy];
        }
        
    
        if (0 == [tempThreads count]) {
            return;
        }
    
    
        // 本地新闻需要添加一个切换城市的cell
        if ([channel isLocalChannel]) {         // 是本地频道
            [_cellsModel addObject:[self createCustomCellData:kCellType_LocalCity]];
        }
        else if ([channel isStockChannel]) {    // 是财经频道
            [_cellsModel addObject:[self createCustomCellData:kCellType_Stock]];
        }
    
    
        // 把bannel数据过滤出来
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isPicThread==true)"];
        NSArray *bannerArray =
        [tempThreads filteredArrayUsingPredicate:predicate];
        
        // 分离广告帖子和帖子（帖子分有图和无图）
        if ([bannerArray count] > 0) {
            [tempThreads removeObjectsInArray:bannerArray];
        }
        
        // 添加cell模型
        [_cellsModel addObjectsFromArray:
         [self buildCellsDataWithThreads:tempThreads]];
    
    
    
        // 添加更多cell项
        if ([tempThreads count] > 0) {
            [_cellsModel addObject:[self createCustomCellData:kCellType_More]];
        }
        
        [tableview reloadData];     // 重新刷新 tableView 加载数据
    
        // 设置tableHeaderView
        if(bannerArray.count > 0) {
            tableview.tableHeaderView = hotBannerView;
            [hotBannerView reloadData:bannerArray isVodel:channel.isVideoChannel];
            [tableview.tableHeaderView setHidden:NO];
        }
        else{
            tableview.tableHeaderView = [UIView new];
        }
        
        // 如果是加载状态，需要变成加载状态。
        if (_hotChannel.isRefresh){
            [self setLoadingState:NO];
        }
    }
}

// 恢复原始状态
-(void)recoverOriginalState
{
    _hotChannel = nil;
    [self cancelLoadingState:NO];
    tableview.tableHeaderView = [UIView new];
    tableview.contentOffset = CGPointZero;
    tableview.contentInset = UIEdgeInsetsZero;
    if([_cellsModel count] > 0){
        [_cellsModel removeAllObjects];
        [_layouts removeAllObjects];
        [tableview reloadData];
    }
}




- (void)updateRefreshDate:(NSDate*)date{
    [_headerView updateRefreshDate:date];// 设置刷新时间
}

// 添加更多帖子
- (void)moreChannels:(HotChannel *)channel
               array:(NSArray *)channelsArray
                date:(NSDate *)refreshDate
{
    if ([channelsArray count] <= 0 ||
        _hotChannel.channelId != channel.channelId) {
        return;
    }
    
    _hotChannel = channel;
    // 把bannel数据过滤出来
    NSArray *tempThreads = [self filteredBannelsData:channelsArray];
    if ([tempThreads count] == 0) {
        return;
    }
    
        
    // 删除加载更多对象
    SNCellDataModel *lastObj = [_cellsModel lastObject];
    if (lastObj.cellType == kCellType_More){
        [_cellsModel removeLastObject];
    }
    
    [_cellsModel addObjectsFromArray:
    [self buildCellsDataWithThreads:tempThreads]];
        
    
    // 更新时间
    if (tableview.contentOffset.y > 0) {
            // 添加加载更多对象
        [_cellsModel addObject:[self createCustomCellData:kCellType_More]];
            
        CGPoint offset = tableview.contentOffset;
        offset.y += 30.f;
        [tableview setContentOffset:offset animated:YES];
    }
    [tableview reloadData]; // 加载数据
    
}


// 注意：需要使用这个函数，必须在reloadChannels函数之后使用，要不然的话，tableview.contentOffset会重置回去。
// 设置为加载状态
- (void)setLoadingState:(BOOL)isAciton
{
    
    if (!_headerView.loading) {
        _headerView.loading = YES;
        _headerView.state = kPRStateLoading;
        tableview.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
        tableview.contentOffset = CGPointMake(0.f, -kUpDownUpdateOffsetY);
    }
    
    
    if (!_headerView.loading) {
        _isLoading = YES;
        _headerView.loading = YES;
        _headerView.state = kPRStateLoading;
        
        if (isAciton) {
            [UIView animateWithDuration:kUpDownUpdateDuration*2
                                  delay:kUpDownUpdateDelay
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
               tableview.contentOffset = CGPointMake(0.f, -kUpDownUpdateOffsetY);
                                 
            } completion:^(BOOL finished) {
                tableview.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
                tableview.contentOffset = CGPointMake(0.f, -kUpDownUpdateOffsetY);
            }];
        }
        else {
            tableview.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
            tableview.contentOffset = CGPointMake(0.f, -kUpDownUpdateOffsetY);
        }
    }
}

// 注意：如何使用这个函数，必须在reloadChannels函数之后。
// 取消加载状态
- (void)cancelLoadingState:(BOOL)animated
{
    if (_headerView.loading) {
        _isLoading = NO;
        _headerView.loading = NO;
        [_headerView setState:kPRStateNormal animated:YES];
        
        if (animated) {
            [UIView animateWithDuration:kUpDownUpdateDuration*2 delay:kUpDownUpdateDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
                tableview.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);//top不留一个像素，最顶的分割线将看不到
            } completion:^(BOOL finished) {
                tableview.contentOffset = CGPointZero;
                tableview.contentInset = UIEdgeInsetsZero;
            }];
        }
        else{
            tableview.contentOffset = CGPointZero;
            tableview.contentInset = UIEdgeInsetsZero;
        }
    }
}

/**
 *  创建一个cell数据层
 *
 *  @param ts       新闻帖子数据
 *  @param cellType cell类型
 *
 *  @return 返回cell数据层
 */
-(SNCellDataModel*)createCellData:(ThreadSummary*)ts
                         cellType:(SNNewsCellType)cellType
{
    SNCellDataModel *model = [SNCellDataModel new];
    model.ts = ts;
    model.cellType = cellType;
    return model;
}
/**
 *  创建自定义数据模型
 *
 *  @return 返回cell数据层
 */
-(SNCellDataModel*)createCustomCellData:(SNNewsCellType)cellType
{
    SNCellDataModel *model = [SNCellDataModel new];
    model.cellType = cellType;
    return model;
}


/**
 *  过滤掉数组中的bannel数据，私有函数
 *
 *  @param threads 数据数组
 *
 *  @return 过滤过的数据数组
 */
-(NSArray*)filteredBannelsData:(NSArray*)threads
{
    NSMutableArray *tempThreads = [threads mutableCopy];
    // 把bannel数据过滤出来
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isPicThread==true)"];
    NSArray *bannerArray =
    [tempThreads filteredArrayUsingPredicate:predicate];
    if ([bannerArray count] >0) {
        [tempThreads removeObjectsInArray:bannerArray];
    }
    return tempThreads;
}

/**
 *  添加cell数据，通过新闻帖子数组，因私有函数，不验证数据有效性。
 *
 *  @param threads 新闻帖子数据源
 */
-(NSArray*)buildCellsDataWithThreads:(NSArray*)threads
{
    SNNewsCellType type = kCellType_ThreadSummer;
    
    // 判断是否是美女频道
    if ([self isBeautyChannel]) {
        type = kCellType_BeautyChannel;
    }
    
    // 判断是否是段子频道
    if ([self isJokeChannel]) {
        type = kCellType_JokeChannel;
    }
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for(ThreadSummary *t in threads){
        // 专题类型
        if (t.showType == TSShowType_Special_Image ||
            t.showType == TSShowType_Special_None) {
            if ([t.special_list count] > 0) {
                [tempArray addObject:[self createCellData:t cellType:kCellType_SpecialHeader]];
                [tempArray addObjectsFromArray:[self buildCellsDataWithThreads:t.special_list]];
                [tempArray addObject:[self createCellData:t cellType:kCellType_SpecialFood]];
            }
        }
        else {
            // 普通处理
             [tempArray addObject:[self createCellData:t cellType:type]];
        }
        
        // 段子频道创建layout数组
        if ([self isJokeChannel]) {
            SNJokeLayout *layout = [SNJokeLayout new];
            // 从数据库获取 赞 或 踩 状态
            int type = [[ThreadsManager sharedInstance] isJokeThreadUpedOrDowned:t];
            if (type == 1) {
                // 已赞
                t.uped = YES;
            } else if (type == 2) {
                // 已踩
                t.downed = YES;
            }
            layout.joke = t;
            
            [_layouts addObject:layout];
        }
    }
    return tempArray;
}


#pragma mark UITableViewDataSource
// 每个分区有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_cellsModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger rowIdx = indexPath.row;
    if (rowIdx >= [_cellsModel count]) {
        return [UITableViewCell new];
    }
    
    
    SNCellDataModel *cellData =
    [_cellsModel objectAtIndex:rowIdx];
    
    NSString *identifier =
    [NSString stringWithFormat:@"cell_%@", @(cellData.cellType)];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cellData.cellType == kCellType_ThreadSummer) {  // 新闻帖子
        
        // 图片新闻
        PictureThreadView *ptView = nil;
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            
            // cell 选择后的背景View
            UIView *bgView = [[UIView alloc] initWithFrame:[cell bounds]];
            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.selectedBackgroundView = bgView;
            
            CGSize size = [tableView rectForRowAtIndexPath:indexPath].size;
            CGRect rect = CGRectMake(0.f, 0.f, size.width, size.height);
            ptView = [[PictureThreadView alloc] initWithFrame:rect];
            [[cell contentView] addSubview:ptView];
        }
        
        // 修改背景颜色
        BOOL isN = [ThemeMgr sharedInstance].isNightmode;
        UIColor *bgColor = [UIColor colorWithHexValue:isN?kTableCellSelectedColor_N:kTableCellSelectedColor];
        cell.selectedBackgroundView.backgroundColor = bgColor;
   
        
        if(ptView == nil){
            for (PictureThreadView* tempView in [cell contentView].subviews) {
                if([tempView isKindOfClass:[PictureThreadView class]]){
                    ptView = tempView;
                    break;
                }
            }
        }
        

        ptView.hotchannel=self.hotChannel;
        ptView.isFirstCell = indexPath.row == 0 ? YES : NO;
        [ptView reloadThreadSummary:cellData.ts];
        
        //by Jerry
        //给T+帖子加上标记
        if ([cellData.ts isTPlusNews]){
            if (![cell.contentView.subviews containsObject:TPlusIcon]) {
                [cell.contentView addSubview:TPlusIcon];
            }
        }
        else {
            if ([cell.contentView.subviews containsObject:TPlusIcon]) {
                [TPlusIcon removeFromSuperview];
            }
        }
        
    }
    else if(cellData.cellType == kCellType_BeautyChannel) { // 美女频道
        if (!cell) {
            cell = [[PhoneBeautyChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [(PhoneBeautyChannelCell*)cell loadingDataWithThreadSummary:cellData.ts];
    }
    else if(cellData.cellType == kCellType_LocalCity) {     // 本地频道
        if (!cell) {
            cell = [[LocalCityNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        [cell setNeedsDisplay];
    }
    else if(cellData.cellType == kCellType_Stock) {         // 财经频道
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.backgroundColor = [UIColor clearColor];
            cell.userInteractionEnabled = YES;
            
            CGFloat vH = [self tableView:tableView heightForRowAtIndexPath:indexPath]-1;
            CGFloat vW = cell.bounds.size.width;
            CGRect vR = CGRectMake(0, 0, vW, vH);
            stockView = [[StockMarketThreadView alloc] initWithFrame:vR];
            stockView.delegate = self;
            [[cell contentView] addSubview:stockView];
            
//            stockView = [[StockMarketThreadView alloc] initWithFrame:CGRectZero];
//            stockView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
//            stockView.delegate = self;
//            [cell addSubview:stockView];
        }
    }
    else if(cellData.cellType == kCellType_SpecialHeader) {
        // 专题头
        if (!cell) {
            cell = [[SNSpecialHeaderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        [(SNSpecialHeaderTableCell*)cell setThread:cellData.ts];
     
    }
    else if(cellData.cellType == kCellType_SpecialFood) {
        // 专题脚
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
           
            
            // 分割线
            CGFloat cellH = [self tableView:tableView
                    heightForRowAtIndexPath:indexPath];
            CGFloat lineH = [SNNewsListUIHelper lineWidthForSpecial];
            CGFloat lineW = CGRectGetWidth(tableView.bounds);
            CGRect lineR = CGRectMake(0, cellH-lineH, lineW, lineH);
            UIView *lineV = [[UIView alloc] initWithFrame:lineR];
            [lineV setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
            [lineV setBackgroundColor:[SNTheme valueForKey:kColorKey_SeparatorLine]];
            [[cell contentView] addSubview:lineV];
            
            
            [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
        }
        
        [[cell textLabel] setText:@"进入专题 >"];
        [[cell textLabel] setTextColor:[UIColor colorWithHexValue:0xffd71919]];
        [[cell textLabel] setFont:[UIFont systemFontOfSize:13.f]];
        
    }
    else if(cellData.cellType == kCellType_More) {      // 更多
        if (!cell) {
            cell = [[SNLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.userInteractionEnabled = NO;
        }
        [(SNLoadingMoreCell*)cell hiddenActivityView:YES];
        [cell viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode]; // 需要每次检查。
    }
    else if (cellData.cellType == kCellType_SubsChennel) {  // 订阅
        
        if (!cell) {
            cell = [[SubsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        
        if ([cellData.ts isKindOfClass:[SubsChannel class]]) {
             [(SubsTableViewCell*)cell reloadSubsChannel:cellData.ts indexPath:indexPath onlySubs:NO];
            
        }
    }
    else if (cellData.cellType == kCellType_AddSubsChannels) {  // 添加订阅
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            
            [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
            [[cell textLabel] setText:@"订阅更多新闻资讯 >"];
            [[cell textLabel] setTextColor:[UIColor colorWithHexValue:0xffd71919]];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:13.f]];
        }
    }
    else if (cellData.cellType == kCellType_JokeChannel) {      // 段子频道
        if (!cell) {
            cell = [[SNJokeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            ((SNJokeCell *)cell).delegate = self;
        }

        ThreadSummary *ts = cellData.ts;
        ts.isBeauty = 5;    // 设置类型为段子频道
        SNJokeLayout *layout = _layouts[indexPath.row];
        [((SNJokeCell *)cell) setLayout:layout];
    }
    return cell;
}


#pragma mark UITableViewDelegate
// 行高
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.row;
    if (index >= [_cellsModel count]) {
        return 0.f;
    }
    
    CGFloat rowHeight = 0.f;
    SNCellDataModel *data = [_cellsModel objectAtIndex:index];
    
    if (data.cellType == kCellType_More) {
        rowHeight =  kMoreCellHeight;
    }
    else if(data.cellType == kCellType_BeautyChannel) {
        UIEdgeInsets imgEdgeInsets =
        [PhoneBeautyChannelCell imageEdgeInsets];
        CGFloat imgW = CGRectGetWidth(tableView.bounds);
        imgW -= (imgEdgeInsets.left + imgEdgeInsets.right);
        rowHeight = [data.ts getBeautyChannelImageHeight:imgW];
        rowHeight += (imgEdgeInsets.top + imgEdgeInsets.bottom);
    }
    else if(data.cellType == kCellType_LocalCity) {
        rowHeight = 35.f;
    }
    else if(data.cellType == kCellType_Stock) {
        rowHeight = kStockInfoHeight;
    }
    else if(data.cellType == kCellType_ThreadSummer) {
        rowHeight = [PictureThreadView viewHeight:data.ts];
    }
    else if(data.cellType == kCellType_SpecialHeader) {
        rowHeight = 35.f;
    }
    else if(data.cellType == kCellType_SpecialFood) {
        rowHeight = 35.f;
    }
    else if (data.cellType == kCellType_SubsChennel){
        rowHeight = [SubsTableViewCell CellHeight];
    }
    else if (data.cellType == kCellType_AddSubsChannels){
        rowHeight = 35.f;
    }
    else if (data.cellType == kCellType_JokeChannel) {
        SNJokeLayout *layout = _layouts[indexPath.row];
        rowHeight = layout.height;
    }
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger index = [indexPath row];
    if (index >= [_cellsModel count]) {
        return;
    }
    
    
    SNCellDataModel *data = [_cellsModel objectAtIndex:index];
    
    if (data.cellType == kCellType_LocalCity) {
        Class classType = [PhoneHotRootController class];
        PhoneHotRootController *controller = [self findUserObject:classType];
        if (controller && [controller isKindOfClass:classType]) {
            [controller enterSelectLocalNewsCities];
        }
    }
    else if (data.cellType == kCellType_ThreadSummer ||
             data.cellType == kCellType_BeautyChannel ){
        ThreadSummary *ts = data.ts;
        [[ThreadsManager sharedInstance] markThreadAsRead:ts];  // 标记为已读
        if ([delegate respondsToSelector:@selector(readThreadContent:threadSummary:)]) {
            [delegate readThreadContent:self threadSummary:ts];
        }
    }
    else if(data.cellType == kCellType_SpecialFood ||
            data.cellType == kCellType_SpecialHeader)
    {
        ThreadSummary *ts = data.ts;
        [[ThreadsManager sharedInstance] markThreadAsRead:ts];  // 标记为已读
        if ([delegate respondsToSelector:@selector(readThreadContent:threadSummary:)]) {
            [delegate readThreadContent:self threadSummary:ts];
        }
    }
    else if(data.cellType == kCellType_SubsChennel) {
        
        SubsChannel *sc = data.ts;
        // TODO: 进入订阅频道
        SubsChannelSummaryViewController *summaryController;
        summaryController = [[SubsChannelSummaryViewController alloc] initWithStyle:SubsChannelSummaryDownload];
        summaryController.title = sc.name;
        summaryController.subsChannel = sc;
        Class classType = [PhoneHotRootController class];
        PhoneHotRootController *controller = [self findUserObject:classType];
        if ([controller isKindOfClass:classType])
        {
            [controller presentController:summaryController animated:PresentAnimatedStateFromRight];
        }
    }
    else if(data.cellType == kCellType_AddSubsChannels) {
        [self enterAddSubschannelVC];
    }
    else if(data.cellType == kCellType_JokeChannel) {       // 新增段子频道
        ThreadSummary *ts = data.ts;
        [[ThreadsManager sharedInstance] markThreadAsRead:ts];  // 标记为已读
        if ([delegate respondsToSelector:@selector(readThreadContent:threadSummary:)]) {
            [delegate readThreadContent:self threadSummary:ts];
        }
    }
}


// 改变offset 都会回调这个函数，
// 这里改变headerView和FooterView状态
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > 0)
        _hotChannel.listScrollOffsetY = scrollView.contentOffset.y;

    
    // offset改变都会产生该回调
    // 改变headerView和footerView状态
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_headerView.state == kPRStateLoading) 
        return;
    
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < -kUpDownUpdateOffsetY) {   //header totally appeard
        _headerView.state = kPRStatePulling;
    } else if (offset.y > -kUpDownUpdateOffsetY && offset.y < 0){ //header part appeared
        _headerView.state = kPRStateLocalDisplay;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 滚动到底部，自动加载更多数据
    CGFloat scrollContentHeight = scrollView.contentSize.height;
    CGFloat scrollHeight = scrollView.bounds.size.height;
    if (scrollView.contentOffset.y >= scrollContentHeight - scrollHeight - kMoreCellHeight) {
        if([refreshDelegate respondsToSelector:@selector(loadMoreContent:)]){
                id moreCell = [[tableview visibleCells] lastObject];
            if ([moreCell isKindOfClass:[SNLoadingMoreCell class]]){
                    [(SNLoadingMoreCell*)moreCell hiddenActivityView:NO];
                // 加载更多新闻
                [refreshDelegate loadMoreContent:self];
            }
        }
    }
}


// 拖拽结束，回调此函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_headerView.state == kPRStateLoading)
        return;
    
    // headerView 状态是拉伸状态
    if (_headerView.state == kPRStatePulling) {
        _isLoading = YES;
        _headerView.state = kPRStateLoading;
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
        } completion:^(BOOL finished) {
            if([refreshDelegate respondsToSelector:@selector(refreshContent:)]){
                [refreshDelegate refreshContent:self];
            }
        }];
    }
    else if(_headerView.state == kPRStateLocalDisplay){
        [UIView animateWithDuration:.18f animations:^{
        } completion:^(BOOL finished) {
            _headerView.state = kPRStateNormal;
        }];
    }
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    if (isNight) {
        [tableview setSeparatorColor:[UIColor colorWithHexValue:0xff222223]];
        [stockView._SeparatorLine setBackgroundColor:[UIColor colorWithHexValue:0xff222223]];
    }
    else{
        [tableview setSeparatorColor:[UIColor colorWithHexValue:0xffdcdbdb]];
        [stockView._SeparatorLine setBackgroundColor:[UIColor colorWithHexValue:0xffdcdbdb]];
    }

    [_headerView viewNightModeChanged:isNight];
    
    
    NSArray *cells =  [tableview visibleCells];
    for (UITableViewCell *c in cells) {
        if ([c isKindOfClass:[SNLoadingMoreCell class]] ||
            [c isKindOfClass:[LocalCityNewsCell class]]) {
            [c viewNightModeChanged:isNight];
        }
        else{
            if(c.selectedBackgroundView){
                // 修改背景颜色
                c.selectedBackgroundView.backgroundColor = [UIColor colorWithHexValue:isNight ? kTableCellSelectedColor_N:kTableCellSelectedColor];
            }
            
            for (UIView *v in [c contentView].subviews) {
                [v viewNightModeChanged:isNight];
            }
        }
    }
}


-(void)setScrollOffsetY:(float)y
{
    if (!_headerView.loading && tableview.contentSize.height > y)
    {
        CGFloat tabHeight = CGRectGetHeight(tableview.bounds);
        if (tabHeight < tableview.contentSize.height) {
            float offY = tableview.contentSize.height - tabHeight;
            if (offY < y) {
                tableview.contentOffset = CGPointMake(0.f, offY);
            }
            else{
                tableview.contentOffset = CGPointMake(0.f, y);
            }
        }
    }
}
// 滚动到指定位置
-(void)setScrollOfThread:(ThreadSummary *)thread
{
    if ([_cellsModel count] <= 0 || !thread ||
        thread.channelId != self.hotChannel.channelId ||
        !thread.isPicThread) {
        return;
    }

    NSUInteger index = NSNotFound;
    for(int i=0; i<[_cellsModel count]; ++i) {
        SNCellDataModel *d = [_cellsModel objectAtIndex:i];
        if ([d.ts isKindOfClass:[ThreadSummary class]]) {
            if (((ThreadSummary*)d.ts).threadId == thread.threadId) {
                index = i;
                break;
            }
        }
    }
    

    if (index != NSNotFound)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        BOOL isVisible = [[tableview indexPathsForVisibleRows] containsObject:indexPath];
            
        // 不在显示屏幕
        if (!isVisible)
        {
            [tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }
    }
}
-(void)setScrollOfThreadY:(NSNumber *)y{
    [tableview setContentOffset: CGPointMake(0.f, [y floatValue]) animated:YES];
}


// 2015.1.6 新增美女频道，与之前的cell不一样
// 是否美女频道
-(BOOL)isBeautyChannel
{
    return _hotChannel.isBeauty;
}

// 判断是否是段子频道（新增段子频道，与之前的cell不一样）
- (BOOL)isJokeChannel {
    return _hotChannel.isJokeChannel;
}


#pragma mark 订阅模块
// 没有订阅频道默认View
-(void)showAddSubschannelView:(BOOL)isShow
{
    if (isShow) {
        if (_subschannelEmptyV) {
            return;
        }
        
        [tableview setHidden:YES];
        
        
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat height = CGRectGetHeight(self.bounds);
        UIView *containerV = [UIView new];
        _subschannelEmptyV = containerV;
        containerV.backgroundColor = [UIColor clearColor];
        

        
        UIImage *bgImg = [UIImage imageNamed:@"subs_empty"];
        UIImageView *emptyImgV =
        [[UIImageView alloc] initWithImage:bgImg];
        [containerV addSubview:emptyImgV];
        
        
        UIButton *emptyBtn = [UIButton new];
        [emptyBtn setTitle:@"订阅新闻资讯" forState:UIControlStateNormal];
        [emptyBtn setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
        [emptyBtn setBackgroundColor:[UIColor colorWithHexValue:0xffAD2F2F]];
        [emptyBtn addTarget:self action:@selector(addSubschannelClick:) forControlEvents:UIControlEventTouchUpInside];
        CGSize btnSize = [emptyBtn sizeThatFits:CGSizeZero];
        btnSize.width += 20;
        CGFloat btnX = (bgImg.size.width-btnSize.width)/2;
        CGFloat btnY = bgImg.size.height + 20.f;
        [emptyBtn setFrame:CGRectMake(btnX, btnY, btnSize.width, btnSize.height)];
        emptyBtn.layer.cornerRadius = 5.f;
        emptyBtn.layer.masksToBounds = YES;
        [containerV addSubview:emptyBtn];
        
        
        
        CGFloat cX = (width - bgImg.size.width)/2;
        CGFloat cY = (height-(btnY+btnSize.height))/2;
        [containerV setFrame:CGRectMake(cX, cY, bgImg.size.width, btnY+btnY)];
        [self addSubview:containerV];
        
    }
    else {
        [_subschannelEmptyV removeFromSuperview];
        _subschannelEmptyV = nil;
    }
}

-(void)addSubschannelClick:(UIButton*)btn
{
    [self enterAddSubschannelVC];
}
// 进入添加订阅频道
-(void)enterAddSubschannelVC
{
    Class classType = [PhoneHotRootController class];
    PhoneHotRootController *controller = [self findUserObject:classType];
    if (controller && [controller isKindOfClass:classType]) {
        AddSubscribeController *addController =
        [AddSubscribeController new];
        [controller presentController:addController
                       animated:PresentAnimatedStateFromRight];
    }
}

#pragma mark - ****StockMarketThreadViewDelegate****
-(void)addUrlWithTag:(stockTag)tag
{    
    if ([delegate respondsToSelector:@selector(addStockUrlWithTag:)]) {
        [delegate addStockUrlWithTag:tag];
    }
}

#pragma mark SNJokeCellDelegate

- (void)cellDidClickUp:(SNJokeCell *)cell {
    SNJokeLayout *layout = cell.layout;
    ThreadSummary *joke = layout.joke;
    if (!joke.uped) {
        joke.uped = YES;
        joke.upCount ++;
    }
    [cell.jokeView.inlineActionsView updateUpWithAnimation];
}

- (void)cellDidClickDown:(SNJokeCell *)cell {
    SNJokeLayout *layout = cell.layout;
    ThreadSummary *joke = layout.joke;
    if (!joke.downed) {
        joke.downed = YES;
        joke.downCount ++;
    }
    [cell.jokeView.inlineActionsView updateDownWithAnimation];
}

- (void)cellDidClickShare:(SNJokeCell *)cell {
    self.shared = YES;  // 点击了分享
    
    NSUInteger index = [tableview indexPathForCell:cell].row;
    SNCellDataModel *data = [_cellsModel objectAtIndex:index];
    
    ThreadSummary *ts = data.ts;
    [[ThreadsManager sharedInstance] markThreadAsRead:ts];  // 标记为已读
    if ([delegate respondsToSelector:@selector(readThreadContent:threadSummary:)]) {
        [delegate readThreadContent:self threadSummary:ts];
    }
}

- (void)cellDidClickComment:(SNJokeCell *)cell {
    self.commented = YES;   // 点击了评论
    
    NSUInteger index = [tableview indexPathForCell:cell].row;
    SNCellDataModel *data = [_cellsModel objectAtIndex:index];
    
    ThreadSummary *ts = data.ts;
    if ([delegate respondsToSelector:@selector(readThreadContent:threadSummary:)]) {
        [delegate readThreadContent:self threadSummary:ts];
    }
}

@end