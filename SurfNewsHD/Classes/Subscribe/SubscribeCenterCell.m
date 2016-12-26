//
//  SubscribeCenterCell.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubscribeCenterCell.h"
#import "SurfJsonResponseBase.h"



#define CateNameWidth  80       // 宽度
#define CateNameFontSize 24.f   // 字体

// 展开Button 数据
#define ExpBtFontSize 15.f      // 按钮字体大小
#define ExpBtTitleColor 0xFF9d9696    // 按钮字体颜色
#define ExpBtWidth 150.f
#define ExpBtHeight 20.f





@implementation SubscribeCenterCell
@synthesize delegate=_delegate;

static UIFont *ExpFont = nil;
+ (CGFloat)cellHeight{
    // 35 + 36 + 35 + 36 + 35 // 2排
    return 177.f; // 高度是美工计算好的，要不就出行排版问题
}
+ (CGFloat)cellExtHeight{
    // 35 + 36 + 35 + 36 +35 + 36 + 35 + 36 +35 + 36 + 35 + 36 +35 + 36 + 35 // 7排
    return 534.f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                kContentWidth, [SubscribeCenterCell cellHeight]);
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setDelegate:self];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [[self contentView] addSubview:_scrollView];       
        

        // 标题横框
        CGRect imgRect = CGRectMake(8.f, 20.f, 72.f, 14.f);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgRect];
        [imgView setImage:[UIImage imageNamed:@"category"]];
        [[self contentView] addSubview:imgView];
        
        
        // 分类名
        CGRect cateRect = CGRectMake(imgRect.origin.x + imgRect.size.width-50.f
                                     , 25.f+14.f+10.f,
                                     CateNameFontSize+CateNameFontSize, 100.f);
        _categoryName = [[UILabel alloc] initWithFrame:cateRect];
        [_categoryName setFont:[UIFont boldSystemFontOfSize:CateNameFontSize]];
        [_categoryName setTextColor:[UIColor blackColor]];
        [_categoryName setTextAlignment:NSTextAlignmentRight];
        [_categoryName setNumberOfLines:3];
        [_categoryName setBackgroundColor:[UIColor clearColor]];
        [[self contentView] addSubview:_categoryName];
        
        
        _pageCtrl = [UIPageControl new];
        _pageCtrl.backgroundColor = [UIColor clearColor];
        _pageCtrl.hidesForSinglePage = YES;
        _pageCtrl.userInteractionEnabled = NO;
        [[self contentView] addSubview:_pageCtrl];      
        [self setClearsContextBeforeDrawing:NO];
    
        if (ExpFont == nil) {
            ExpFont = [UIFont systemFontOfSize:20.0f];
        }
        
        // 扩展Button
        _expButton = [UIButton buttonWithType:UIButtonTypeCustom];       
        [[_expButton titleLabel] setContentMode:UIViewContentModeCenter];
        [_expButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 45.f)];
        [[_expButton titleLabel] setFont:[UIFont boldSystemFontOfSize:ExpBtFontSize]];
        [[_expButton imageView]setContentMode:UIViewContentModeCenter];
        [_expButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, ExpBtWidth - 45.f, 0.f, 10.f)];
        [_expButton setTitleColor:[UIColor colorWithHexValue:ExpBtTitleColor] forState:UIControlStateNormal];
        [_expButton addTarget:self action:@selector(handleExpButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [[self contentView] addSubview:_expButton];
//        [_expButton setBackgroundColor:[UIColor greenColor]];
        
 
        // 分割线
        _sepaView = [UIView new];
        [_sepaView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dottedLine"]]];
        [[self contentView] addSubview:_sepaView];
        
        
        // 展开后Top图片
        _expTopLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topLine"]];
        [_expTopLine setHidden:YES];
        [[self contentView] addSubview:_expTopLine];
        
        // 展开后Bottom图片
        _expBottomLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomLine"]];
        [_expBottomLine setHidden:YES];
        [[self contentView] addSubview:_expBottomLine];

    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 更新展开Button的区域
    CGRect rt = [self bounds];
    CGRect btRect = CGRectMake(rt.size.width - ExpBtWidth - 20.f,
                               rt.size.height-ExpBtHeight,
                               ExpBtWidth, ExpBtHeight);
    [_expButton setFrame:btRect];
    
    
    // 分割线    
    CGRect sepaRect = [self bounds];    
    sepaRect.origin.y = sepaRect.size.height - 2.f;
    sepaRect.size.height = 2.f;
    if (!_expButton.isHidden) {
        sepaRect.origin.y -= CGRectGetHeight([_expButton bounds])*0.5f;
        sepaRect.size.width -= ExpBtWidth+28.f;
    }
    sepaRect.size.width -= 2;
    [_sepaView setFrame:sepaRect];

    // 展开特效线
    if (_isExpansion) {       
        CGRect topRect = [self bounds];
        topRect.size.height = 11.f;
        [_expTopLine setFrame:topRect];
        
        CGRect bottomRect = [self bounds];
        bottomRect.origin.y = [SubscribeCenterCell cellExtHeight]- ExpBtHeight -15.f;
        bottomRect.size.height = 11.f;
        [_expBottomLine setFrame:bottomRect];
        [_expTopLine setHidden:NO];
        [_expBottomLine setHidden:NO];
    }
    else{
        [_expTopLine setHidden:YES];
        [_expBottomLine setHidden:YES];
    }
}





// 加载数据
- (void)loadData:(NSIndexPath *)indexPath
        cateItem:(CategoryItem *)cateItem
     isExpansion:(bool)isExp
{
    _indexPath = indexPath;
    _cateItem = cateItem;
    _isExpansion = isExp;    
    _channelsCount = 0;
    _expRect = CGRectZero;
    _pageCtrl.currentPage = 0;
    _pageCtrl.numberOfPages = 1;   //不能设置为0
    _isVisibleExpansionStr = NO;
  
    [_categoryName setText:nil];
    [_expButton setHidden:YES];  // 展开Button    

    
    // 隐藏之前的窗口
    [self hideSubItemsOnScrollview:YES];
    
    
 
    
    if (_cateItem != nil)
    {
        if (_cateItem.channels != nil && _cateItem.channels.count > 0)
        {            
            [self setCategoryName:_cateItem.name];
            
            NSMutableArray* channels = [NSMutableArray arrayWithCapacity:20];
            // 过滤订阅频道
            for (SubsChannel *subsChannel in _cateItem.channels) {
                if ([subsChannel isKindOfClass:[subsChannel class]]) {
                    if ([subsChannel.isVisible isEqualToString:@"1"]) {
                        [channels addObject:subsChannel];
                    }
                }            
            }
            
            _channelsCount = channels.count;
            if (_channelsCount > 0)
            {
                int channelsCount = _channelsCount;
                if (!_isExpansion) {
                    _isVisibleExpansionStr = channels.count > 18 ? YES : NO;
                    channelsCount = channelsCount > 18 ? 18 : channelsCount;
                    
                    if (_isVisibleExpansionStr) {
                        [self setExpButtonState:NO];
                        [_expButton setHidden:NO];      // 不隐藏
                        
                 
                    }
                }
                else{
                    _isVisibleExpansionStr = YES;
                    [self setExpButtonState:YES];
                    [_expButton setHidden:NO];      // 不隐藏                    
                }
  
               
                
                
                //在ScrollView中创建Subitem
                [self BuildSubitemsOnScrollview:channelsCount];
                
                [self setScrollViewFrame:isExp showExpStr:_isVisibleExpansionStr]; // 设置大小
                CGSize itemSize = [SubscribeCenterCellSubitem suitableSize];
                CGSize scrollSize = _scrollView.frame.size;
//                int row = scrollSize.height / itemSize.height;
                int row = isExp ? 7 : 2;
                
                
                int column = scrollSize.width / itemSize.width;
                int pageCount = ceil((double)channelsCount / (double)(row * column));
                
                
                _pageCtrl.numberOfPages = pageCount;
                if (!_isExpansion){
                    _pageCtrl.currentPage = _cateItem.channelCurrentPage;
                }
                             
                _scrollView.contentSize = CGSizeMake(scrollSize.width * pageCount, scrollSize.height);                
                _scrollView.contentOffset = CGPointMake(_pageCtrl.currentPage * scrollSize.width, .0f);

                
                // 初始化Item
                NSMutableArray *subItemsView = [self getSubitemsArray];
                CGRect itemRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
                float itemGapLR = (scrollSize.width - column * itemSize.width)/(column+1);
                float itemGapTB = (scrollSize.height - row * itemSize.height)/(float)(row+1);
                for (int i = 0; i < channelsCount; ++i) {                    
                    SubsChannel* sc = channels[i];
                    int curPage = i / column / row % pageCount;
                    int curRow = i / column  % row;
                    int curColumn = i % column;
                    
                    
                    itemRect.origin.y = curRow * (itemSize.height + itemGapTB) + itemGapTB;
                    itemRect.origin.x = curPage * scrollSize.width + curColumn * (itemSize.width + itemGapLR) + itemGapLR;
                    
                    
                    SubscribeCenterCellSubitem *subitem = [subItemsView objectAtIndex:i];
                    [subitem setFrame:itemRect];
                    [subitem reloadData:sc];                    
                                
                }
                [subItemsView removeAllObjects];
                [self hideSubItemsOnScrollview:NO];
                [self loadSubitemImage];
        
            }
        }        
    }
}




-(void)setCellWillExpansion{
    [self hideSubItemsOnScrollview:YES];    
    [_expButton setHidden:YES];    
    CGRect tempRect = [_sepaView frame];
    tempRect.origin.y = NSNotFound;
    [_sepaView setFrame:tempRect];
    [_pageCtrl setNumberOfPages:0];
}


- (void)setScrollViewFrame:(BOOL)isExp showExpStr:(BOOL)isExpStr{
    CGRect rect = CGRectZero;
    rect.size.width = CGRectGetWidth([self bounds]);
    
    if (isExp) {
        rect.size.height = [SubscribeCenterCell cellExtHeight];
    }
    else{
        rect.size.height = [SubscribeCenterCell cellHeight];        
    }
    rect.origin.x = CateNameWidth;
    rect.size.width -= CateNameWidth;
    if (isExpStr) {
        rect.size.height -= ExpFont.lineHeight *.5f ;
    }
    _scrollView.frame = rect;
    
    
    // 点点
    CGSize size = [_pageCtrl sizeForNumberOfPages:10];
    _pageCtrl.frame = CGRectMake((CGRectGetWidth([self bounds]) - size.width)/2.f,
                                 CGRectGetHeight(rect) - size.height,
                                 size.width, size.height);
    
}


// 需要下载图片的订阅频道
- (NSArray*)needDownloadImageChannels{
    SubscribeCenterCellSubitem *subItem = nil;
    NSMutableArray *itemArray = [self visibleSubitemOnScreen];
    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:6];
    NSEnumerator *itemEnume = [itemArray reverseObjectEnumerator];
    while (subItem = [itemEnume nextObject]) {
        if (![subItem isLoadedIcon]){
            [channels addObject:[subItem subsChannel]];
        }
    }    
    return channels;
}

// 屏幕范围内的订阅频道SubsChannel
- (NSArray*)visibleChannelsOnScreen{
    SubscribeCenterCellSubitem *tempitem = nil;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
    NSEnumerator *channels = [[self visibleSubitemOnScreen] objectEnumerator];
    while ((tempitem = channels.nextObject) != nil) {
        [array addObject:[tempitem subsChannel]];
    }
    return array;
}

// 屏幕范围内的SubscribeCenterCellSubitem
- (NSMutableArray*)visibleSubitemOnScreen{
    CGRect scrollRect =[_scrollView bounds];
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *subitem in [_scrollView subviews]) {
        if ([subitem isKindOfClass:[SubscribeCenterCellSubitem class]]) {
            CGPoint point = [subitem convertPoint:CGPointZero toView:_scrollView];
            if (CGRectContainsPoint(scrollRect, point)){
                [array addObject:subitem];
            }
        }
    }
    return array;
}

- (void)updateImage:(SubsChannel*)channel image:(UIImage *)img{
    NSArray *array = [self visibleSubitemOnScreen];
    if ([array count] > 0) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SubscribeCenterCellSubitem *subitem = obj;
            if ([[subitem subsChannel] isEqual:channel]) {
                *stop = YES;
                [subitem setIcon:img];
            }
        }];
    }
}

//  检查订阅状态
- (BOOL)checkSubscribeState{
    for (UIView *view in [_scrollView subviews]) {
        if ([view isKindOfClass:[SubscribeCenterCellSubitem class]]) {
            if ([(SubscribeCenterCellSubitem*)view checkSubsButtonState]) {
                return YES;
            }
        }
    }
    return NO;
}
// 加载子项图片
- (void)loadSubitemImage{    
    NSMutableArray* array = (NSMutableArray*)[self visibleSubitemOnScreen];
    NSEnumerator *enume = [array reverseObjectEnumerator];    
    SubscribeCenterCellSubitem* subitem = nil;
    while (subitem = [enume nextObject]) {        
        UIImage *image = [[self imgPool] getImage:_indexPath
                                    subsChannel:[subitem subsChannel]];
        if (image != nil) {
            [subitem setIcon:image];
        }
    }    
}




#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_sView{    
   
    CGFloat width = _sView.frame.size.width;
    _pageCtrl.currentPage = floor((_sView.contentOffset.x - width / 2) / width) + 1;
     if (!_isExpansion){
        _cateItem.channelCurrentPage = _pageCtrl.currentPage;
    }
    
    // 加载图片
    NSArray* array = [self needDownloadImageChannels];
    if ([array count] > 0) {
        for (SubsChannel* subsChannel in array) {
            [[self imgPool] loadImage:_indexPath subChannel:subsChannel];
        }
    }
}


#pragma mark touch
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];
//
//    if (touches.count == 1) {
//        UITouch *touch = [[touches allObjects] objectAtIndex:0];
//        _beganPoint = [touch locationInView:self];        
//    }
//    
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//
//    if (touch.tapCount == 1) {
//        
//        if (CGRectContainsPoint(_expRect, [touch locationInView:self]) &&
//            CGRectContainsPoint(_expRect, _beganPoint))
//        {
//            if([_delegate respondsToSelector:@selector(handleExpansionCell:expCell:)]){
//                [_delegate handleExpansionCell:self.frame.origin.y expCell:self];
//            }
//        }
//    }
//}


#pragma mark SubItem
// 显示所有的Subitem
- (void)hideSubItemsOnScrollview:(BOOL)hide{
    for (UIView *view in [_scrollView subviews]) {
        if ([view isKindOfClass:[SubscribeCenterCellSubitem class]]) {
            [view setHidden:hide];
        }
    }
}

// 创建Subitems， 更具Array，创建
- (void)BuildSubitemsOnScrollview:(NSInteger)count{
    NSInteger viewIdx = 0;
    for (UIView *view in [_scrollView subviews]) {
        if ([view isKindOfClass:[SubscribeCenterCellSubitem class]]) {
            if (viewIdx >= count) {
                // 删除多余的subItem                
                [view removeFromSuperview];
            }
            else{
                ++viewIdx;
            }
        }
    }
    
    // 创建缺少的Subitem
    CGRect subitemRect = {{.0f,.0f}, [SubscribeCenterCellSubitem suitableSize]};
    while (viewIdx < count) {
         ++viewIdx;
        id subitem = [[SubscribeCenterCellSubitem alloc] initWithFrame:subitemRect];
        [subitem setHidden:YES];
        [subitem setSubsCellSubitemClickDelegate:self];
        [_scrollView addSubview:subitem];
    }
    
}

-(NSMutableArray *)getSubitemsArray{
    NSMutableArray *subitems = [NSMutableArray arrayWithCapacity:18];
    for (UIView *view in [_scrollView subviews]) {
        if ([view isKindOfClass:[SubscribeCenterCellSubitem class]]) {
            [subitems addObject:view];
        }
    }   
    return subitems;
}

- (void)setCategoryName:(NSString*)name{
    float w = CGRectGetWidth([_categoryName bounds]);
    CGSize size = [name sizeWithFont:_categoryName.font
                   constrainedToSize:CGSizeMake(w, NSIntegerMax)];
    CGRect cateFrame = [_categoryName frame];
    cateFrame.size.height = size.height;
    [_categoryName setFrame:cateFrame];
    [_categoryName setText:name];    
}


#pragma mark expButton
-(void)setExpButtonState:(BOOL)isExp{
    NSString *expStr = [NSString stringWithFormat:isExp ? @"收起，共%d" : @"展开，共%d", _channelsCount];
    [_expButton setTitle:expStr forState:UIControlStateNormal];
    UIImage *img = [UIImage imageNamed:isExp ? @"arrowUp" : @"arrowDown"];
    [_expButton setImage:img forState:UIControlStateNormal];
}

- (void)handleExpButtonEvent:(UIButton*)button{
    if([_delegate respondsToSelector:@selector(handleExpansionCell:expCell:)]){
        [_delegate handleExpansionCell:self.frame.origin.y expCell:self];
    }
}


-(void)cellSubitemClick:(SubsChannel *)subsChannel{
    [_delegate openSubsChannelView:subsChannel];
}
@end
