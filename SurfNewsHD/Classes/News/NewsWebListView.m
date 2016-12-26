//
//  NewsWebListView.m
//  SurfNewsHD
//
//  Created by apple on 13-1-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NewsWebListView.h"
#import "ThreadsManager.h"
#import "NewsWebListCell.h"

#define kPROffsetY 50.0f
@implementation NewsWebListView
@synthesize delegate;
@synthesize headerView;
@synthesize footerView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        tableview = [[UITableView alloc] initWithFrame:self.bounds];
        tableview.backgroundColor = [UIColor clearColor];
        tableview.dataSource = self;
        tableview.delegate = self;
        UIImage *line = [UIImage imageNamed:@"dottedTableview"];
        [tableview setSeparatorColor:[UIColor colorWithPatternImage:line]];
        [self addSubview:tableview];

        float width = CGRectGetWidth(frame);
        float height = kPROffsetY;
        headerView = [[LoadingView alloc] initWithFrame:
                       CGRectMake(0.0f,-height, width, height) atTop:YES];
        headerView.style = StateDescriptionWebStyleTop;
        [tableview addSubview:headerView];
        
        hotChannels = [NSMutableArray new];
        
        footerView = [[LoadingView alloc] initWithFrame:
                       CGRectMake(0.0f,self.frame.size.height, width, height) atTop:NO];
        footerView.style = StateDescriptionWebStyleBottom;
        [tableview addSubview:footerView];
        
        [tableview addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)dealloc
{
    [tableview removeObserver:self forKeyPath:@"contentSize"];
}
#pragma mark -
-(void)reloadChannels:(NSArray *)channels
{
    if ([channels count]<=0) {
        return;
    }
    [self cancelLoading];
    [hotChannels removeAllObjects];
    [hotChannels addObjectsFromArray:channels];
    currentIndex = [self.delegate getCurrentIndex];
    if (currentIndex ==NSNotFound) {
        currentIndex = 0;
    }
    [tableview  reloadData];
    
    [headerView updateRefreshDate:[NSDate date]];
    [footerView updateRefreshDate:[NSDate date]];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [hotChannels count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hotChannels_Cell";
    
    NewsWebListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[NewsWebListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
     
        UIView *bgView = [UIView new];
        bgView.frame = cell.frame;
        bgView.backgroundColor = [UIColor colorWithHexString:@"d5d0c8"];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cell.selectedBackgroundView = bgView;
     
    }
    if (indexPath.row <[hotChannels count])
    {
        NSObject *channel = [hotChannels objectAtIndex:indexPath.row];
        if ([channel isKindOfClass:[ThreadSummary class]])
        {
            ThreadSummary *threadSummary = (ThreadSummary *)channel;
            bool isRead = [[ThreadsManager sharedInstance] isThreadRead:threadSummary];
            if (currentIndex == indexPath.row) {
                [cell setSummary:threadSummary withState:NewsWebListCellCurrent];
            }else if (isRead)
            {
                [cell setSummary:threadSummary withState:NewsWebListCellReaded];
            }
            else
            {
                [cell setSummary:threadSummary withState:NewsWebListCellNoReading];
            }
        }
        else if ([channel isKindOfClass:[PhoneNewsData class]])
        {
            PhoneNewsData *item = (PhoneNewsData *)channel;
            if (currentIndex == indexPath.row) {
                [cell setNewsData:item withState:NewsWebListCellCurrent];
            }else
            {
                [cell setNewsData:item withState:NewsWebListCellReaded];
            }        
        }

    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    NSInteger row=[indexPath row];
    ThreadSummary *channel = [hotChannels objectAtIndex:row];
    [self.delegate tableView:channel didSelectStyle:WebViewLoadHtmlAnimateWhiteStyle];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

// 改变offset 都会回调这个函数，
// 这里改变headerView和FooterView状态
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // offset改变都会产生该回调
    // 改变headerView和footerView状态
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (headerView.state == kPRStateLoading || footerView.state == kPRStateLoading) {
        return;
    }
    
    CGPoint offset = scrollView.contentOffset;
    CGSize size = scrollView.frame.size;
    CGSize contentSize = scrollView.contentSize;
    
    float yMargin = offset.y + size.height - contentSize.height;
    if (offset.y < -kPROffsetY) {   //header totally appeard
        headerView.state = kPRStatePulling;
    } else if (offset.y > -kPROffsetY && offset.y < 0){ //header part appeared
        headerView.state = kPRStateLocalDisplay;
        
    } else if ( yMargin > kPROffsetY){  //footer totally appeared
        if (footerView.state != kPRStateHitTheEnd) {
            footerView.state = kPRStatePulling;
        }
    } else if ( yMargin < kPROffsetY && yMargin > 0) {//footer part appeared
        if (footerView.state != kPRStateHitTheEnd) {
            footerView.state = kPRStateLocalDisplay;
        }
    }
}

// 拖拽结束，回调此函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (headerView.state == kPRStateLoading
        || footerView.state == kPRStateLoading) {
        return;
    }
    
    // headerView 状态是拉伸状态
    if (headerView.state == kPRStatePulling) {
        headerView.state = kPRStateLoading;
        [UIView animateWithDuration:1.0f animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(kPROffsetY, 0, 0, 0);
        } completion:^(BOOL finished) {
            [self.delegate refreshChannels];
        }];
    } else if(headerView.state == kPRStateLocalDisplay){
        //        _headerView.state = kPRStateNormal;
        [UIView animateWithDuration:.18f animations:^{
        } completion:^(BOOL finished) {
            headerView.state = kPRStateNormal;
        }];
    } else if (footerView.state == kPRStatePulling) {
        footerView.state = kPRStateLoading;
        [UIView animateWithDuration:1.0f animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, kPROffsetY, 0);
        } completion:^(BOOL finished) {
            [self.delegate downloadMoreChannels];
        }];
    } else if(footerView.state == kPRStateLocalDisplay){
        [UIView animateWithDuration:.18f animations:^{} completion:^(BOOL finished) {
            footerView.state = kPRStateNormal;
        }];
    }
}
- (void)cancelLoading
{
    if (headerView.loading) {
        headerView.loading = NO;
        [headerView setState:kPRStateNormal animated:NO];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            tableview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            
        } completion:^(BOOL bl){

        }];
    }
    else if (footerView.loading) {
        footerView.loading = NO;
        [footerView setState:kPRStateNormal animated:NO];
        [UIView animateWithDuration:0.5 animations:^{
            tableview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL bl){
            
        }];
    }

}
-(void)refreshCell
{
    
    
    [tableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
                             animated:NO];
    
    
    currentIndex = [self.delegate getCurrentIndex];
    NewsWebListCell *cell2 = (NewsWebListCell *)[tableview cellForRowAtIndexPath:
                              [NSIndexPath indexPathForRow:currentIndex inSection:0]];
    
    NSObject *object = [hotChannels  objectAtIndex:currentIndex];
    
    
    if ([object isKindOfClass:[ThreadSummary class]])
    {
        ThreadSummary *item = (ThreadSummary *)object;
        [cell2 setSummary:item
                withState:NewsWebListCellCurrent];

    }
    else if ([object isKindOfClass:[PhoneNewsData class]])
    {
        PhoneNewsData *item = (PhoneNewsData *)object;
        [cell2 setNewsData:item withState:NewsWebListCellCurrent];
    }
    [tableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
                           animated:YES
                     scrollPosition:UITableViewScrollPositionMiddle];

}
#pragma mark - observe
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    //把FooterView设置为ContentSize的最下边
    CGRect frame = footerView.frame;
    CGSize contentSize = tableview.contentSize;
    frame.origin.y = contentSize.height < self.frame.size.height ? self.frame.size.height : contentSize.height;
    footerView.frame = frame;
}
@end