//
//  HotInfomationInChannel.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-2-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotInfomationInChannelView.h"
#import "UIColor+extend.h"
#import "NSString+Extensions.h"


#define HeadHeight 53.f
// Cell
#define TitleTopGap 12.f
#define TitleFontSize 20.f
#define DetailTopGap 12.f       
#define DetailFontSize 12.f     // source和time公用一个字体
#define SourceTopGap 10.f

// TitleTopGap + TitleFontSize*2 + DetailTopGap + DetailFontSize*2 + SourceTopGap + DetailFontSize + TitleTopGap
#define CellHeight 136.f
#define CellWidth 224.f  // HotRootController 公用一个值


@interface UIHotInfomationCell : UITableViewCell{
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UILabel *_sourceLabel; //来源
    UILabel *_timeLabel;
    ThreadSummary *_threadSummary;
}

// 更新帖子状态 
- (void)updateThreadSummaryState;
- (void)reloadDataWithThreadSummany:(ThreadSummary*)ts;
@end



@implementation UIHotInfomationCell
static UIColor* unTitleReadColor = nil;
static UIColor* unDetailReadColor = nil;
static UIColor* readColor = nil;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        float cellW = CellWidth; // 避免和滚动条重叠
        UIFont *font = [UIFont boldSystemFontOfSize:DetailFontSize];
        UIFont *titleFont = [UIFont boldSystemFontOfSize:TitleFontSize];
        
        CGRect rect = CGRectMake(0.f, TitleTopGap, cellW,
                                 titleFont.lineHeight+titleFont.lineHeight);
        _titleLabel = [[UILabel alloc] initWithFrame:rect];
        
        rect.origin.y += rect.size.height + DetailTopGap;
        rect.size.height = font.lineHeight + font.lineHeight;
        _detailLabel = [[UILabel alloc] initWithFrame:rect];
        
        rect.origin.y += rect.size.height + SourceTopGap;
        rect.size.height = font.lineHeight;
        rect.size.width = 145.f;
        _sourceLabel = [[UILabel alloc] initWithFrame:rect];        
        
        rect.origin.x += rect.size.width;
        rect.size.width = cellW - rect.size.width;
        _timeLabel = [[UILabel alloc] initWithFrame:rect];
        

        [_titleLabel setFont:titleFont];
        [_detailLabel setFont:font];
        [_sourceLabel setFont:font];
        [_timeLabel setFont:font];        
        
        [_titleLabel setNumberOfLines:2];
        [_detailLabel setNumberOfLines:2];
        [_sourceLabel setTextAlignment:NSTextAlignmentRight];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        
        // 背景透明
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_detailLabel setBackgroundColor:[UIColor clearColor]];
        [_sourceLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        
        [[self contentView] addSubview:_titleLabel];
        [[self contentView] addSubview:_detailLabel];
        [[self contentView] addSubview:_sourceLabel];
        [[self contentView] addSubview:_timeLabel];
        
        
        if (unTitleReadColor == nil) {
            readColor = [UIColor colorWithHexValue:kReadTitleColor];
            unTitleReadColor = [UIColor colorWithHexValue:kUnreadTitleColor];
            unDetailReadColor = [UIColor colorWithHexValue:kUnreadContentColor];
        }
    }
    return self;
}

- (void)reloadDataWithThreadSummany:(ThreadSummary*)ts{
    [self clearAllLableText]; // 清除文字
    
    _threadSummary = ts;
    [_titleLabel setText:[ts title]];
    [_detailLabel setText:[ts desc]];
    [_sourceLabel setText:[ts source]];
    [_timeLabel setText:[ts timeStr]];
    
    [self updateThreadSummaryState];
 
}

- (void)updateThreadSummaryState{
    ThreadsManager *tm = [ThreadsManager sharedInstance];
    BOOL isRead = [tm isThreadRead:_threadSummary];
    if (isRead) {
        [_titleLabel setTextColor:readColor];
        [_detailLabel setTextColor:readColor];
        [_sourceLabel setTextColor:readColor];
        [_timeLabel setTextColor:readColor];
    }
    else{
        [_titleLabel setTextColor:unTitleReadColor];
        [_detailLabel setTextColor:unDetailReadColor];
        [_sourceLabel setTextColor:unDetailReadColor];
        [_timeLabel setTextColor:unDetailReadColor];
    }
}

-(void)clearAllLableText{
    [_titleLabel setText:nil];
    [_detailLabel setText:nil];
    [_sourceLabel setText:nil];
    [_timeLabel setText:nil];    
}
@end



#pragma mark HotInfomationInChannelView


@implementation HotInfomationInChannelView

-(void)dealloc{
    [_tableView removeObserver:self forKeyPath:@"contentSize" ];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:NO];
        _dottedLine = [UIImage imageNamed:@"dottedLine"];
        
        // init weather
        CGPoint p = CGPointMake(90.f, (HeadHeight - [WeatherView suitableSize].height) * 0.5f);
        _weatherView = [[WeatherView alloc] initWithPoint:p];
        [self addSubview:_weatherView];
        
        
        // init tableView
        CGRect tableFrame = CGRectMake(.0f, HeadHeight,
                                       CGRectGetWidth(frame),
                                       CGRectGetHeight(frame)-HeadHeight);
        _tableView = [[UITableView alloc] initWithFrame:tableFrame];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setSeparatorColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dottedTableview"]]];
        [self addSubview:_tableView];
        

        _titleFont = [UIFont boldSystemFontOfSize:TitleFontSize];
        _detailFont = [UIFont boldSystemFontOfSize:DetailFontSize];
        
        _hotInfoArray = [NSMutableArray new];
        
        // 创建headerView和footerView
        CGRect headerRect = CGRectMake(0, 0 - frame.size.height, frame.size.width, frame.size.height);
        _headerView = [[LoadingView alloc] initWithFrame:headerRect atTop:YES];
        _headerView.style = StateDescriptionTableStyleTop;
        [_tableView addSubview:_headerView];
        
        CGRect footRect = CGRectMake(0, frame.size.height,
                          frame.size.width, frame.size.height);        
        _footerView = [[LoadingView alloc] initWithFrame:footRect atTop:NO];
        _footerView.style = StateDescriptionTableStyleBottom;
        [_tableView addSubview:_footerView];
        
        // 添加一个tableView观察者
        [_tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

    }
    return self;
}

// 加载热门资讯帖子详情
- (void)loadHotInfomationWithArray:(NSArray*)threadsSummary updateTime:(NSDate*)updateTime{
    [_headerView updateRefreshDate:updateTime];
    [_hotInfoArray removeAllObjects];
    [_hotInfoArray addObjectsFromArray:threadsSummary];

    // 对没有数据，就不显示分割线
    [_tableView setSeparatorStyle:[_hotInfoArray count] ? UITableViewCellSeparatorStyleSingleLine :UITableViewCellSeparatorStyleNone];
    [_tableView reloadData];
}

- (void)loadMoreThreadsSummary:(NSArray*)threadsSummary updateTime:(NSDate*)updateTime
{
    [_footerView updateRefreshDate:updateTime];
    [_hotInfoArray addObjectsFromArray:threadsSummary];
    if ([_hotInfoArray count] > 0) {
        [_tableView reloadData];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code   
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    [self drawTitleString:context drawRect:rect];
    UIGraphicsPopContext();
}

- (void)drawTitleString:(CGContextRef)context drawRect:(CGRect)rect{
    NSInteger strTopGap = 15.f;
    float height = 4.f; // 横线高度
    UIColor *color = [UIColor colorWithHexValue:0xFFa43942];
    UIFont *font = [UIFont boldSystemFontOfSize:20.f];
    
    // 热门资讯横线
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextMoveToPoint(context, .0f, .0f);
    CGContextAddLineToPoint(context, 80.f, 0.f);
    CGContextAddLineToPoint(context, 80.f, height);
    CGContextAddLineToPoint(context, 0.f, height);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    
    // 热门资讯文字
    NSString *hotStr = @"热门资讯";
    [hotStr surfDrawAtPoint:CGPointMake(0.f, strTopGap) withFont:font];
    
    // 绘制虚线
    [_dottedLine drawAsPatternInRect:CGRectMake(0.f, HeadHeight-2.f,
                                                self.frame.size.width, 2.f)];
}


#pragma mark private Tool




#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CellHeight;
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_hotInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"hotInformation_cell";
    UIHotInfomationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {        
        cell = [[UIHotInfomationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        UIView *selectBG = [UIView new];
        [selectBG setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [selectBG setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor]];
        [cell setSelectedBackgroundView:selectBG];
    }
    
    ThreadSummary* tempTS = [_hotInfoArray objectAtIndex:indexPath.row];
    [cell reloadDataWithThreadSummany:tempTS];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // offset改变都会产生该回调
    // 改变headerView和footerView状态
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_headerView.state == kPRStateLoading || _footerView.state == kPRStateLoading) {
        return;
    }
    
    CGPoint offset = scrollView.contentOffset;
    CGSize size = scrollView.frame.size;
    CGSize contentSize = scrollView.contentSize;
    
    float yMargin = offset.y + size.height - contentSize.height;
    if (offset.y < -kUpDownUpdateOffsetY) {   //header totally appeard
        _headerView.state = kPRStatePulling;
    } else if (offset.y > -kUpDownUpdateOffsetY && offset.y < 0){ //header part appeared
        _headerView.state = kPRStateLocalDisplay;
        
    } else if ( yMargin > kUpDownUpdateOffsetY){  //footer totally appeared
        if (_footerView.state != kPRStateHitTheEnd) {
            _footerView.state = kPRStatePulling;
        }
    } else if ( yMargin < kUpDownUpdateOffsetY && yMargin > 0) {//footer part appeared
        if (_footerView.state != kPRStateHitTheEnd) {
            _footerView.state = kPRStateLocalDisplay;
        }
    }
}

// 拖拽结束，回调此函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_headerView.state == kPRStateLoading
        || _footerView.state == kPRStateLoading) {
        return;
    }
    
    // headerView 状态是拉伸状态
    if (_headerView.state == kPRStatePulling) {
        _headerView.state = kPRStateLoading;
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
        } completion:^(BOOL finished) {
            if ([[self refreshDelegate] respondsToSelector:@selector(refreshContent:)]) {
                [[self refreshDelegate] refreshContent:self];
            }            
        }];
    }
    else if(_headerView.state == kPRStateLocalDisplay){
        //        _headerView.state = kPRStateNormal;
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
        } completion:^(BOOL finished) {
            _headerView.state = kPRStateNormal;
        }];
    }
    else if (_footerView.state == kPRStatePulling) {
        _footerView.state = kPRStateLoading;
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, kUpDownUpdateOffsetY, 0);
        } completion:^(BOOL finished) {
            if ([[self refreshDelegate] respondsToSelector:@selector(loadMoreContent:)]) {
                [[self refreshDelegate] loadMoreContent:self];
            }
        }];
    }
    else if(_footerView.state == kPRStateLocalDisplay){
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{} completion:^(BOOL finished) {
            _footerView.state = kPRStateNormal;
        }];
    }
}

-(void)cancelLoading{
    if (_headerView.loading) {
        _headerView.loading = NO;
        [_headerView setState:kPRStateNormal animated:NO];
        [UIView animateWithDuration:kUpDownUpdateDuration*2 delay:kUpDownUpdateDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_tableView setContentInset:UIEdgeInsetsZero];
            
        } completion:nil];
    }
    else if (_footerView.loading) {
        _footerView.loading = NO;
        [_footerView setState:kPRStateNormal animated:NO];
        [UIView animateWithDuration:kUpDownUpdateDuration*2 delay:kUpDownUpdateDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            _tableView.contentInset = UIEdgeInsetsZero;
        } completion:nil];
    }
}


// cell 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if ([_hotInfoArray count] > 0 && row < [_hotInfoArray count]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];       
         ThreadSummary *ts = [_hotInfoArray objectAtIndex:[indexPath row]];
        [[ThreadsManager sharedInstance] markThreadAsRead:ts];  // 标记为已读
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[UIHotInfomationCell class]]) {            
            [(UIHotInfomationCell*)cell updateThreadSummaryState];
        }
        
        if ([_readThreadDelegate respondsToSelector:@selector(readThreadContent:threadSummary:)]) {
            [_readThreadDelegate readThreadContent:self threadSummary:ts];
        }
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // 把Footer View设置为ContentSize的最下边
    CGRect frame = _footerView.frame;
    CGSize contentSize = _tableView.contentSize;
    frame.origin.y = contentSize.height < self.frame.size.height ? self.frame.size.height : contentSize.height;
    _footerView.frame = frame;
    
}

- (void)updateRefreshDate:(NSDate*)date{
    [_headerView updateRefreshDate:date];// 设置刷新时间
}
- (void)updateMoreDate:(NSDate*)date{
    [_footerView updateRefreshDate:date];
}

@end
