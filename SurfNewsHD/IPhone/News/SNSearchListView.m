//
//  SNSearchListView.m
//  SurfNewsHD
//
//  Created by XuXg on 15/9/9.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNSearchListView.h"
#import "NSString+Extensions.h"
#import "GTMHTTPFetcher.h"
#import "DiscoverSearchNewsRequest.h"
#import "EzJsonParser.h"
#import "SNLoadingMoreCell.h"


@interface SNSearchListCell : UITableViewCell {
    __weak UILabel *_titleLabel;
    __weak UILabel *_sourceLabel;
    __weak UILabel *_timeLabel;
}

+(CGFloat)cellHeight;
@end


@implementation SNSearchListCell
+(CGFloat)cellHeight
{
    return 60.f;
}

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildUIView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setLablePoint];
}
-(void)buildUIView
{
    UILabel *title = [UILabel new];
    _titleLabel = title;
    title.numberOfLines = 2;
    title.font = [UIFont systemFontOfSize:14.];
    title.textAlignment = NSTextAlignmentLeft;
    [[self contentView] addSubview:title];
    

    UILabel *source = [UILabel new];
    _sourceLabel = source;
    source.font = [UIFont systemFontOfSize:10.];
    source.textAlignment = NSTextAlignmentLeft;
    [[self contentView] addSubview:source];
    

    UILabel *time = [UILabel new];
    _timeLabel = time;
    time.font = [UIFont systemFontOfSize:10.];
    time.textAlignment = NSTextAlignmentLeft;
    [[self contentView] addSubview:time];

    
    // 选择的背景图片
    UIView *bgView = [UIView new];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.selectedBackgroundView = bgView;
    
    
    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    [self viewNightModeChanged:isN];
}

-(void)loadDataWithThreadSummary:(ThreadSummary*)ts
{
    _titleLabel.text = nil;
    _sourceLabel.text = nil;
    _timeLabel.text = nil;
    
    _titleLabel.text = ts.title;
    _sourceLabel.text = ts.source;
    _timeLabel.text = ts.timeStr;
}



// 设置坐标
-(void)setLablePoint
{
    CGFloat l_edge = 10.f;
    CGFloat b_edge = 5.f;
    CGFloat widht = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    [_sourceLabel sizeToFit];
    CGFloat sourceH = CGRectGetHeight(_sourceLabel.bounds);
    CGFloat sourceW = CGRectGetWidth(_sourceLabel.bounds);
    CGFloat sourceY = height - sourceH - b_edge;
    [_sourceLabel setFrame:CGRectMake(l_edge, sourceY, sourceW, sourceH)];
    
    
    [_timeLabel sizeToFit];
    CGFloat timeH = CGRectGetHeight(_timeLabel.bounds);
    CGFloat timeW = CGRectGetWidth(_timeLabel.bounds);
    CGFloat timeX = widht - l_edge - timeW;
    CGFloat timeY = height - timeH - b_edge;
    [_timeLabel setFrame:CGRectMake(timeX, timeY, timeW, timeH)];
    
    
    CGFloat tW = widht - l_edge - l_edge;
    CGSize tSize = [_titleLabel sizeThatFits:CGSizeMake(tW, CGFLOAT_MAX)];
    CGFloat titleShowHeight = timeY- 5.f;
    CGFloat titleY = (titleShowHeight-tSize.height)/2.f;
    [_titleLabel setFrame:CGRectMake(l_edge, titleY, tSize.width, tSize.height)];
    
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    UIColor *color;
    if (isNight) {
        color = [UIColor whiteColor];
    }
    else {
        color = [UIColor colorWithHexValue:0xff333333];
    }
    _titleLabel.textColor = color;
    _sourceLabel.textColor = color;
    _timeLabel.textColor = color;
    
    
    // 修改背景颜色
    UIColor *bgColor = [UIColor colorWithHexValue:isNight?kTableCellSelectedColor_N:kTableCellSelectedColor];
    self.selectedBackgroundView.backgroundColor = bgColor;
}
@end



@interface SNSearchListView() <UITableViewDelegate,
UITableViewDataSource> {
    __weak UITableView *_searchTable;
    NSMutableArray *_searchData;
    
    GTMHTTPFetcher *_searchFetcher;
    __weak UILabel *_notResultLabel;    // 没有结果的提示窗口
    
    
    NSString *_keyword;
    NSUInteger _curPage;
}

@end

@implementation SNSearchListView
-(void)dealloc{
    if ([_searchFetcher isFetching]) {
        [_searchFetcher stopFetching];
    }
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UITableView *table =
        [[UITableView alloc] initWithFrame:self.bounds
                                     style:UITableViewStylePlain];
        _searchTable = table;
        table.tableFooterView = [UIView new];
        table.delegate = self;
        table.dataSource = self;
        table.bounces = NO;
        table.backgroundColor = [UIColor clearColor];
        if ([table respondsToSelector:@selector(setSeparatorInset:)]) {
            [table setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([table respondsToSelector:@selector(setLayoutMargins:)]) {
            [table setLayoutMargins:UIEdgeInsetsZero];
        }
        [self addSubview:table];
    }
    return self;
}

-(void)searchWithKeyword:(NSString*)keyword
{
    _searchData = nil;
    [_searchTable reloadData];

    [self searchSelected:keyword];
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    [[_searchTable visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIView*)obj viewNightModeChanged:isNight];
    }];
    
}

// 搜索服务器
- (void)searchSelected:(NSString*)keyword
{
    if (!keyword || [keyword isEmptyOrBlank] ||
        [_searchFetcher isFetching]) {
        return;
    }
    
    _keyword = keyword;
    
    // 添加一个风火轮
    [PhoneNotification manuallyHideWithText:@"加载数据..." indicator:YES];
    
    
    id req = [SurfRequestGenerator disSearchNews:keyword page:_curPage = 1];
    _searchFetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    __block GTMHTTPFetcher *weakFecther = _searchFetcher;
    __block typeof(self) weakSelf = self;
    [_searchFetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         DiscoverSearchNewsResponse *resp;
         if(!error){
             NSStringEncoding encoding = [[[weakFecther response] textEncodingName] convertToStringEncoding];
             NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
             
             resp = [EzJsonParser deserializeFromJson:body AsType:[DiscoverSearchNewsResponse class]];
            
             if ([resp.item count] > 0) {
                 [weakSelf loadedDatas:resp.item];
             }
         }
         
         
         if ([resp.item count] == 0) {
             // 没有搜索结果
             [weakSelf showNotResultTipsView:keyword];
         }
         
         // 隐藏风火轮
         [PhoneNotification hideNotification];
     }];
}


// 请求更多搜索结果
-(void)sendMoreSearch
{
    if (!_keyword || [_keyword isEmptyOrBlank] ||
        [_searchFetcher isFetching]) {
        return;
    }
    
    id req = [SurfRequestGenerator disSearchNews:_keyword page:++_curPage];
    _searchFetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    __block GTMHTTPFetcher *weakFecther = _searchFetcher;
    __block typeof(self) weakSelf = self;
    [_searchFetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         DiscoverSearchNewsResponse *resp;
         if(!error){
             NSStringEncoding encoding = [[[weakFecther response] textEncodingName] convertToStringEncoding];
             NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
             
             resp = [EzJsonParser deserializeFromJson:body AsType:[DiscoverSearchNewsResponse class]];
             
             if ([resp.item count] > 0) {
                 [weakSelf addDatas:resp.item];
             }
         }
     }];
    
}
/**
 *  显示没有搜索结果的提示窗口
 *
 *  @param searchContent 搜索内容
 */
-(void)showNotResultTipsView:(NSString*)keyword
{
    if(!_notResultLabel)
    {
        CGFloat tipW = CGRectGetWidth(self.bounds);
        UIFont *tipF = [UIFont systemFontOfSize:15.f];
        
        CGRect tipR = CGRectMake(0, 20, tipW, tipF.lineHeight);
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:tipR];
        _notResultLabel = tipLabel;
        tipLabel.font = tipF;
        tipLabel.numberOfLines = 0;
        tipLabel.textColor = [UIColor colorWithHexValue:0xff999999];
        [tipLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:tipLabel];
    }
    
    NSString *tipStr = @"非常抱歉，没有找到与“%@”相关结果";
    _notResultLabel.text = [NSString stringWithFormat:tipStr,keyword];
    [_notResultLabel sizeToFit];
    
    CGPoint center = _notResultLabel.center;
    center.x = self.center.x;
    _notResultLabel.center = center;
}


// 加载数据
-(void)loadedDatas:(NSArray*)datas
{
    [_notResultLabel removeFromSuperview];
    [_searchData removeAllObjects];
    _searchData = [datas mutableCopy];
    
    if([_searchData count] >= 20){
        // 上啦加载更多
        [_searchData addObject:@"加载更多"];
    }
    [_searchTable reloadData];
}

-(void)addDatas:(NSArray*)datas
{
    if ([datas count] == 0) {
        return;
    }
    
    // 去重复操作
    [_searchData removeLastObject]; // 删除加载更多数据
    
    NSMutableArray *newsItems = [NSMutableArray arrayWithCapacity:20];
    for (NSUInteger i=0; i<[datas count]; ++i) {
        BOOL isSame = NO;
        ThreadSummary* newTs = datas[i];
        for (NSUInteger j=0; j<[_searchData count]; ++j) {
            ThreadSummary* oldTs = _searchData[j];
            if (newTs.threadId == oldTs.threadId) {
                isSame = YES;
            }
        }
        if (!isSame) {
            [newsItems addObject:newTs];
        }
    }
    
    [_searchData addObjectsFromArray:newsItems];
    // 上啦加载更多
    if([datas count] >= 20){
        [_searchData addObject:@"加载更多"];
    }
    [_searchTable reloadData];
}


#pragma mark- tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if (index == [_searchData count]-1) {
        if ([_searchData[index] isKindOfClass:[NSString class]]) {
            return kMoreCellHeight;
        }
    }
    
    return [SNSearchListCell cellHeight];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *ident = @"searchCell";
    NSUInteger index = indexPath.row;
    
    
    if (index == [_searchData count] -1 &&
        [[_searchData lastObject] isKindOfClass:[NSString class]]) {
        
        static NSString *identifier = @"moreCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[SNLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.userInteractionEnabled = NO;
        }
        
        [(SNLoadingMoreCell*)cell hiddenActivityView:YES];
        return cell;
    }
    
    
    
    // 搜索结果cell
    ThreadSummary *thread;
    if (index < [_searchData count]) {
        thread = [_searchData objectAtIndex:index];
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[SNSearchListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        cell.backgroundColor = [UIColor clearColor];
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    BOOL isN = [ThemeMgr sharedInstance].isNightmode;
    [cell viewNightModeChanged:isN];
    [(SNSearchListCell*) cell loadDataWithThreadSummary:thread];
    return cell;
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger index = indexPath.row;
    if (index < [_searchData count]) {
        ThreadSummary *ts = _searchData[index];
        if ([ts isKindOfClass:[ThreadSummary class]]) {
            if ([_deleate respondsToSelector:@selector(selectSearchNew:)]) {
                [_deleate selectSearchNew:ts];
            }
        }
    }
}

// 结束拖拽，进入滑动状态
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if(!decelerate) {
        [self handlerTableViewScrollToBottom];
    }
}


// 滚动到底部
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]]) {
        [self handlerTableViewScrollToBottom];
    }
}


-(void)handlerTableViewScrollToBottom
{
    // 滚动到底部，自动加载更多数据
    CGFloat sContentHeight = _searchTable.contentSize.height;
    CGFloat sHeight = CGRectGetHeight(_searchTable.bounds);
    if (_searchTable.contentOffset.y >= sContentHeight - sHeight - 20) {
        id moreCell = [[_searchTable visibleCells] lastObject];
        if ([moreCell isKindOfClass:[SNLoadingMoreCell class]]){
            [(SNLoadingMoreCell*)moreCell hiddenActivityView:NO];
            [self sendMoreSearch];
        }
    }
}

@end
