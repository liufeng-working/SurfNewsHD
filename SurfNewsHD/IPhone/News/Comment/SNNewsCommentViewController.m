//
//  SNNewsCommentViewController.m
//  SurfNewsHD
//
//  Created by XuXg on 15/5/29.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNNewsCommentViewController.h"
#import "SurfHtmlGenerator.h"
#import <CoreText/CoreText.h>
#import "LoadingView.h"
#import "NewsCommentManager.h"
#import "NewsCommentCell.h"
#import "SNLoadingMoreCell.h"
#import "SNNewCommentEditViewController.h"
#import "NewsCommentView.h"


#define kTitleFontSize 15.f                 // 标题字体大小
#define kSectionHeight 30.f                 // section 高度

@interface SNNewsCommentViewController () <UITableViewDelegate,UITableViewDataSource,NewsCommentManagerDelegate,UITextViewDelegate,NewsCommentViewDelegate>{
    
    
    __weak UILabel* _titleLabel;
    __weak UITableView* _commentTableView;
    __weak LoadingView* _topLoadView; //
    
    NewsCommentView * _comView;
    
    UIColor *_textColor;
    CGFloat _scale;
    
    // tools
    __weak UIControl *_editCtrl;
    
    // tableView data
    NewsCommentResponse *_commentDataSource;
    
    // 没有数据提示信息
    __weak UILabel *_noDataTips;
    
    // 在已经界面，增加一个风火轮
    __weak UIActivityIndicatorView *_activityView;
}

@end

@implementation SNNewsCommentViewController

-(id)init
{
    self = [super init];
    if (self) {
        self.titleState = (SNState_TopBar |
                           SNState_GestureGoBack |
                           SNState_TopBar_GoBack_Gray);
    }
    return self;
}
-(void)dealloc
{
    [[NewsCommentManager sharedInstance] clearCommentData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    _scale = [[UIScreen mainScreen] scale];
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    _textColor = [UIColor colorWithHexValue:0xFFCE0000];
    BOOL isNight = [[ThemeMgr sharedInstance] isNightmode];


    CGRect visibleFrame = CGRectOffset(self.view.bounds, 0, [self StateBarHeight]);
    

    
    // 标题
    CGFloat titleAreaH = 60.f;
    CGFloat titleW = w-20;
    UIColor *c = isNight?_textColor:[UIColor blackColor];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:kTitleFontSize];
    CGSize probablySize = [_thread.title surfSizeWithFont:titleFont constrainedToSize:CGSizeMake(titleW, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect titleR = CGRectMake(0, 0, probablySize.width, probablySize.height);
    UILabel *title = [[UILabel alloc] initWithFrame:titleR];
    _titleLabel = title;
    title.text = _thread.title;
    title.textColor = c;
    title.font = titleFont;
    title.numberOfLines = 2;
    title.textAlignment = NSTextAlignmentLeft;
    title.backgroundColor = [UIColor clearColor];
    title.center = CGPointMake(w/2, visibleFrame.origin.y+titleAreaH/2);
    [self.view addSubview:title];
    
    
    // 绘制一条红线
    CGFloat lineY = visibleFrame.origin.y + titleAreaH;
    CALayer *line = [CALayer layer];
    line.backgroundColor = _textColor.CGColor;  // 字体的颜色
    line.contentsScale = _scale;
    line.frame = CGRectMake(0, lineY, w, 0.5);
    [self.view.layer addSublayer:line];
    
    // 评论
    CGFloat commentY = lineY + 0.5;
    CGFloat commentH = h-[self getBottomToolsBar].bounds.size.height-commentY - 44.f;//减去底部评论输入框的高度
    CGRect commentR = CGRectMake(0, commentY, w, commentH);
    [self buildCommentTableView:commentR];
    
    // 设置TopLoadingView 加载状态
    [self topLoadViewLoadingState:YES];
    
    // 添加一个加载风火轮
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
    if (isNight) {
        style = UIActivityIndicatorViewStyleWhite;
    }
    UIActivityIndicatorView *activity =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    _activityView = activity;
    [activity startAnimating];
    activity.center = self.view.center;
    [self.view addSubview:activity];
    
    // 请求评论数据
    [self requestCommentData];
    
    
    // 注册一个通知事件，用户写新闻评论的添加事件
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewsComment:) name:kNotiication_AddNewsComment object:nil];
    
    // 添加编辑框
    [self addEditView];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [NewsCommentManager sharedInstance].commentDelegate = self;
}


// 退出界面处理
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NewsCommentManager *commentMgr =
    [NewsCommentManager sharedInstance];
    [commentMgr stopLoadingComment];
    [self topLoadViewLoadingState:NO]; // 设置TopLoadingView 加载状态
 
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //view将要消失，退出键盘
    [_comView exitKeyboard];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    
    // 标题文字的夜间模式
    if (night) {
        _titleLabel.textColor = [UIColor redColor];
    }
    else{
        _titleLabel.textColor = [UIColor blackColor];
    }

    [_topLoadView viewNightModeChanged:night];
    
    NSArray *cells =  [_commentTableView visibleCells];
    for (UITableViewCell *c in cells) {
        [c viewNightModeChanged:night];
    }
}


#pragma mark 私有函数区域


/**
 *  添加编辑框
 */
-(void)addEditView
{
    // 初始化编辑框
    CGFloat tX = 0.f;
    CGFloat tH = 34.f + 10.f;
    CGFloat tY = kContentHeight - tH;
    CGFloat tW = kContentWidth;
    CGRect tR = CGRectMake(tX, tY, tW, tH);
    _comView = [[NewsCommentView alloc]initWithFrame:tR];
    _comView.delegate = self;
    _comView.thread = _thread;
    [self.view addSubview:_comView];
    
/*    //这是右上角的编辑框
    UIView *topBar = [self topBarView];
    CGFloat width = CGRectGetWidth(topBar.bounds);
    CGFloat height = CGRectGetHeight(topBar.bounds);
    BOOL night = [ThemeMgr sharedInstance].isNightmode;
    UIImage *editBg = [UIImage imageNamed:night?@"editBar_n":@"editBar"];

    
    // 编辑输入框
    CGSize size = editBg.size;
    CGFloat eX = width-size.width - 10.f;
    CGFloat eY = (height-size.height)/2;
    CGRect editR = CGRectMake(eX, eY, size.width, size.height);
    UIControl *editCtrl = [[UIControl alloc] initWithFrame:editR];
    _editCtrl = editCtrl;
    editCtrl.center =
    CGPointMake(editCtrl.center.x, [self topGoBackView].center.y);
    [editCtrl addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 背景图片
    CALayer *bgLayer = [CALayer layer];
    bgLayer.contents = (id)(editBg.CGImage);
    bgLayer.frame = editCtrl.bounds;
    bgLayer.contentsScale = _scale;
    [editCtrl.layer addSublayer:bgLayer];
    
    
    // 提示文字：我来说两句
    CGFloat tipH = 15.f, tipW = 70.f;
    CGFloat tipY = (size.height - tipH)/2;
    CGFloat tipX = 8.f;
    CATextLayer *tipLayer = [CATextLayer layer];
    tipLayer.string = @"我来说两句";
    tipLayer.foregroundColor = _textColor.CGColor;
    tipLayer.contentsScale = _scale;
    tipLayer.fontSize = 13.f;
    tipLayer.alignmentMode = kCAAlignmentCenter;
    tipLayer.frame = CGRectMake(tipX,tipY ,tipW, tipH);
    [editCtrl.layer addSublayer:tipLayer];
    
    
    // 编辑标记图片
    UIImage *flagImg = [UIImage imageNamed:@"editFlag"];
    CGFloat fW = flagImg.size.width;
    CGFloat fH = flagImg.size.height;
    CGFloat fX = size.width - fW - 10.f, fY = (size.height - fH)/2;
    CALayer *editFlagLayer = [CALayer layer];
    editFlagLayer.contents = (id)(flagImg.CGImage);
    editFlagLayer.frame = CGRectMake(fX, fY, fW, fH);
    editFlagLayer.contentsScale = _scale;
    [editCtrl.layer addSublayer:editFlagLayer];
    
    
    [topBar addSubview:editCtrl];
*/
}

- (void)editButtonClick:(id)sender
{
    // TODO: 进入编辑入口
    SNNewCommentEditViewController *controller =
    [[SNNewCommentEditViewController alloc] initWithThreadSummery:_thread];
    [self presentController:controller
                   animated:PresentAnimatedStateFromRight];
}

// NSNotificationCenter 接受用户新增评论的通知接口(跳转页面进行评论时，用通知来实现)
-(void)addNewsComment:(NSNotification *)sender
{
    if ([sender.object isKindOfClass:[CommentBase class]] &&
        _commentDataSource) {
        if (!_commentDataSource.newsList ||
            _commentDataSource.newsList.count == 0) {
            _commentDataSource.newsList = [NSArray arrayWithObject:sender.object];
            [_commentTableView reloadData];
            
            // 删除提示信息
            [_noDataTips removeFromSuperview];
        }
        else {
            
            NSMutableArray *newList = [NSMutableArray arrayWithArray:_commentDataSource.newsList];
            [_commentTableView beginUpdates];
            [newList insertObject:sender.object atIndex:0];
            _commentDataSource.newsList = newList;
            NSUInteger section = [self numberOfSectionsInTableView:_commentTableView];
            NSIndexPath *idxP =
            [NSIndexPath indexPathForRow:0 inSection:section-1];
            NSArray *indexes = @[idxP];
            [_commentTableView insertRowsAtIndexPaths:indexes
                                     withRowAnimation:UITableViewRowAnimationBottom];
            [_commentTableView endUpdates];
            
        }
    }
    
}

/**
 *  构建评论TableView
 */
- (void)buildCommentTableView:(CGRect)commentR
{
    UITableView *commentTable =
    [[UITableView alloc] initWithFrame:commentR
                                 style:UITableViewStyleGrouped];
    _commentTableView = commentTable;
    commentTable.delegate = self;
    commentTable.dataSource = self;
    commentTable.showsHorizontalScrollIndicator = NO;
    commentTable.backgroundColor = [UIColor clearColor];
    [commentTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    commentTable.backgroundView.hidden = YES;
    [self.view addSubview:commentTable];
    
    
    // 创建headerView
    CGFloat tableH = CGRectGetHeight(commentTable.bounds);
    CGRect lR = CGRectOffset(commentTable.bounds, 0, -tableH);
    LoadingView* topLoad = [[LoadingView alloc] initWithFrame:lR atTop:YES];
    _topLoadView = topLoad;
    [topLoad updateRefreshDate:nil];
    topLoad.style = StateDescriptionTableStyleTop;
    [commentTable addSubview:topLoad];
}


/**
 *  私有函数，loadingView 的加载状态
 */
- (void)topLoadViewLoadingState:(BOOL)isLoading
{
    if (!_topLoadView) return;
    
    
    if (isLoading) {
        if (!_topLoadView.loading) {
            _topLoadView.loading = YES;
            _topLoadView.state = kPRStateLoading;
            _commentTableView.contentInset =
            UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
            _commentTableView.contentOffset =
            CGPointMake(0.f, -kUpDownUpdateOffsetY);
        }
    }
    else {
        if (_topLoadView.loading) {
            _topLoadView.loading = NO;
            [_topLoadView setState:kPRStateNormal animated:YES];
            

            [UIView animateWithDuration:kUpDownUpdateDuration*2 delay:kUpDownUpdateDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
                _commentTableView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);//top不留一个像素，最顶的分割线将看不到
            } completion:^(BOOL finished) {
                _commentTableView.contentOffset = CGPointZero;
                _commentTableView.contentInset = UIEdgeInsetsZero;
            }];
        }
    }
}

/**
 *  请求评论数据
 */
- (void)requestCommentData
{
    if (!_thread) return;
    
    __block typeof(self) weakSelf = self;
    [[NewsCommentManager sharedInstance] refreshNewsCommentsList:_thread withCompletionHandler:^(NewsCommentResponse *resp) {
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
        [weakSelf topLoadViewLoadingState:NO];
        
        if(!resp) {
            [PhoneNotification autoHideWithText:@"刷新失败"];
        }
        else{
            [_topLoadView updateRefreshDate:[NSDate date]];// 设置刷新时间
            [weakSelf loadCommentData:resp];
        }
    }];
}



/**
 *  加载评论数据
 *
 *  @param resp 数据源
 */
- (void)loadCommentData:(NewsCommentResponse*)resp
{
     _commentDataSource = resp;
    if(([resp newsList].count ==0 && [[resp hotList] count] == 0)) {
        // 没有数据，添加提示信息
        if (!_noDataTips) {
            BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
            NSString *s = @"暂无评论，下拉刷新。";
            UIFont *f = [UIFont systemFontOfSize:12.f];
            CGSize size = SN_TEXTSIZE(s, f);
            CGRect tR = CGRectMake(0, 0, size.width, size.height);
            UILabel *t = [[UILabel alloc] initWithFrame:tR];
            _noDataTips = t;
            t.text = s;
            t.font = f;
            t.textColor = isN ? [UIColor whiteColor]:[UIColor blackColor];
            CGPoint center = _commentTableView.center;
            center.y += 30;
            t.center = center;
            t.textAlignment = NSTextAlignmentCenter;
            t.backgroundColor = [UIColor clearColor];
            [self.view addSubview:t];
        }
    }
    else {
        // 删除提示信息
        [_noDataTips removeFromSuperview];
    }
    
    // 加载数据
    [_commentTableView reloadData];
}


/**
 *  是否有热门评论
 *
 *  @return 是否是热门评论
 */
-(BOOL)isHotComment
{
    return [_commentDataSource.hotList count] > 0;
}

/**
 *  是否有新评论
 *
 *  @return 是否有新评论
 */
-(BOOL)isNewComment
{
    return [_commentDataSource.newsList count] > 0;
}

/**
 *  热门评论是否存在加载更多
 *
 *  @return 返回是和否
 */
-(BOOL)isHotCommentHasMoreCell:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section &&
        [self isHotComment] &&
        _commentDataSource.hasMore &&
        indexPath.row == _commentDataSource.hotList.count) {
        return YES;
    }
    return NO;
}

-(BOOL)isNewsCommentHasMoreCell:(NSIndexPath *)indexPath
{
    if ((0 == indexPath.section && ![self isHotComment]) ||
        (1 == indexPath.section)) {
        if ([self isNewComment] &&
            indexPath.row == _commentDataSource.newsList.count) {
            return YES;
        }
    }
    return NO;
}
/**
 *  工具函数，获取评论数据
 *
 *  @param indexPath UItableVied 的下标数据
 *
 *  @return 评论数据
 */
-(CommentBase*)getCommentData:(NSIndexPath *)indexPath
{
   
    if (0 == indexPath.section) {
        if ([self isHotComment]) {
            if (indexPath.row >= 0 &&
                indexPath.row < _commentDataSource.hotList.count) {
                return [_commentDataSource.hotList objectAtIndex:indexPath.row];
            }
        }
        else if([self isNewComment]){
            if (indexPath.row >= 0 &&
                indexPath.row < _commentDataSource.newsList.count) {
                return [_commentDataSource.newsList objectAtIndex:indexPath.row];
            }
        }
    }
    else if(1 == indexPath.section) {
        if (indexPath.row >= 0 &&
            indexPath.row < _commentDataSource.newsList.count) {
            return [_commentDataSource.newsList objectAtIndex:indexPath.row];
        }
    }
    
    return nil;
}

#pragma mark 协议实现区域
//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if(0 == section && [self isHotComment]){
        if (_commentDataSource.hasMore) {
            return [_commentDataSource.hotList count] + 1;
        }
        return [_commentDataSource.hotList count];
    }
    else if([self isNewComment]){
        NSUInteger newsListCount =
        [_commentDataSource.newsList count];
        if (newsListCount < _commentDataSource.commentCount) {
            newsListCount += 1; // 展开更多评论cell
        }
        return newsListCount;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionNum = 0;
    if ([self isHotComment]) {
        ++sectionNum;
    }
    if ([self isNewComment]) {
        ++sectionNum;
    }
    return sectionNum;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 更多热门和更多最新评论cell
    BOOL isMoreHotComment =
    [self isHotCommentHasMoreCell:indexPath];
    BOOL isMoreNewsComment =
    [self isNewsCommentHasMoreCell:indexPath];
    if (isMoreHotComment || isMoreNewsComment) {
        NSString *moreIdentifier = @"moreComment";
        SNLoadingMoreCell *moreCell =
        [tableView dequeueReusableCellWithIdentifier:moreIdentifier];
        if (!moreCell) {
            moreCell = [[SNLoadingMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreIdentifier];
            [moreCell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            moreCell.titleColorForDay = [UIColor colorWithHexValue:0xff999292];
        }
        
        if (isMoreHotComment) {
            moreCell.title = @"展开更多热门评论";
        }
        else if (isMoreNewsComment) {
            moreCell.title = @"展开更多评论";
        }
        [moreCell hiddenActivityView:YES];
        return moreCell;
    }
    
    
    static NSString* identifier = @"commentCell";
    NewsCommentCell* cell =
    [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NewsCommentCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:identifier];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    CommentBase *comment = [self getCommentData:indexPath];
    [cell loadCommentData:comment isFirstComment:indexPath.row == 0];
    
    return cell;
}


// UITableViewDelegate 协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0 == indexPath.section && [self isHotComment]){
        if (indexPath.row == _commentDataSource.hotList.count) {
            return kMoreCellHeight;
        }
    }
    
    id commentInfo = [self getCommentData:indexPath];
    return [NewsCommentCell calcCellHeight:commentInfo];
}
// 自定义section高度
- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return kSectionHeight;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    // 如果设置section的header高度，不设置footer高度，footer默认等于header高度
    // 这个方法不写，或者return 0跟return kSectionHeight的效果一样
    //  return 0.01;//把高度设置很小，效果可以看成footer的高度等于0
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    // 自定义section
    UIImage *icon = nil;
    UILabel *title = [UILabel new];
    title.font = [UIFont boldSystemFontOfSize:15.0f];
    title.textColor = [UIColor colorWithHexValue:0xFFCE0000];
    title.backgroundColor = [UIColor clearColor];
    if (section == 0 && [self isHotComment]) {
        // 热门评论
        title.text = @"     热门评论";
        icon = [UIImage imageNamed:@"c_hot_icon"];
    }
    else {
        // 最新评论
        title.text = @"     最新评论";
        icon = [UIImage imageNamed:@"c_newest_icon"];
    }
    
    
    // 添加图片
    CGFloat iconX = 10.f;
    CGFloat iconH = icon.size.height;
    CGFloat iconW = icon.size.width;
    CGFloat iconY = (kSectionHeight-iconH)/2;
    CALayer *iconLayer = [CALayer layer];
    iconLayer.contents = (id)icon.CGImage;
    iconLayer.contentsScale = _scale;
    iconLayer.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [title.layer addSublayer:iconLayer];
    return title;
}

// tableviewcell 点击
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self isHotCommentHasMoreCell:indexPath])
    {
        // TODO:加载更多热门评论
        NewsCommentManager *commentMgr = [NewsCommentManager sharedInstance];
        [commentMgr getMoreHotCommentsList:_thread withCompletionHandler:^(HotCommentResponse *resp) {
            // TODO:如果还有更多热门评论，就不删除moreCell，否则就删除moreCell
            [tableView beginUpdates];
            if (!resp.hasMore) {
                _commentDataSource.hasMore = NO;
                
                // 删除moreCell
                NSArray *paths = [NSArray arrayWithObject:indexPath];
                [tableView deleteRowsAtIndexPaths:paths
                                 withRowAnimation:UITableViewRowAnimationTop];
            }
            
            // 插入新增加的数据
            NSArray *addHotList =
            [commentMgr removeSameCommentData:_commentDataSource.hotList addComment:resp.hotList];
            if (addHotList && [addHotList count] > 0) {
                
                // 添加数据源
                NSMutableArray *commentSource = [_commentDataSource.hotList mutableCopy];
                [commentSource addObjectsFromArray:addHotList];
                _commentDataSource.hotList = commentSource;
                
                NSMutableArray *paths = [NSMutableArray array];
                [addHotList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSIndexPath *p = [NSIndexPath indexPathForRow:indexPath.row+idx inSection:indexPath.section];
                    [paths addObject:p];
                    
                }];
                [tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
            }
            [tableView endUpdates];
        }];
    }
}


#pragma mark UITableView 中得ScrollView回调处理
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //屏幕滑动，键盘下去
    [_comView exitKeyboard];
}
// 这里改变loadingView状态
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // offset改变都会产生该回调
    // 改变headerView和footerView状态
    // 如果headerView和footerView状态是“加载”，就不需要更新状态了。
    if (_topLoadView.state == kPRStateLoading)
        return;
    
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < -kUpDownUpdateOffsetY) {   //header totally appeard
        _topLoadView.state = kPRStatePulling;
    } else if (offset.y > -kUpDownUpdateOffsetY && offset.y < 0){
        //header part appeared
        _topLoadView.state = kPRStateLocalDisplay;
    }
}


// 拖拽结束，回调此函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    // 如果_topLoadView状态是“加载”，就不需要更新状态了。
    if (_topLoadView.state == kPRStateLoading)
        return;
    
    // headerView 状态是拉伸状态
    if (_topLoadView.state == kPRStatePulling) {
        _topLoadView.state = kPRStateLoading;
        [UIView animateWithDuration:kUpDownUpdateDuration animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(kUpDownUpdateOffsetY, 0, 0, 0);
        } completion:^(BOOL finished) {
            // 进入刷新状态
            [self requestCommentData];
        }];
    }
    else if(_topLoadView.state == kPRStateLocalDisplay){
        [UIView animateWithDuration:.18f animations:^{
        } completion:^(BOOL finished) {
            _topLoadView.state = kPRStateNormal;
        }];
    }
}


/**
 *  UITableView 滚动到底部,自动加载更多最新评论
 *
 *  @param scrollView 回调函数对象
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 滚动到底部，自动加载更多数据
    NewsCommentManager *commentMgr = [NewsCommentManager sharedInstance];
    CGFloat scrollContentHeight = scrollView.contentSize.height;
    CGFloat scrollHeight = CGRectGetHeight(scrollView.bounds);
    BOOL isScrollBottom = scrollView.contentOffset.y >= scrollContentHeight - scrollHeight - kMoreCellHeight;
    if (!isScrollBottom || [commentMgr isLoadingComment]) {
        return;
    }
    
    // 获取最后的cell，确实是更多类型的cell
    NSIndexPath *moreIndex;
    NSInteger sectionNum =
    [self numberOfSectionsInTableView:_commentTableView];
    if (![self isNewComment] || sectionNum <= 0) {
        return;
    }
    
    sectionNum -= 1;
    NSInteger rowNum =
    [self tableView:_commentTableView numberOfRowsInSection:sectionNum];
    if(rowNum <= 0){
        return;
    }
    
    
    rowNum -= 1;
    moreIndex =
    [NSIndexPath indexPathForRow:rowNum inSection:sectionNum];
    
    
    id moreCell =
    [_commentTableView cellForRowAtIndexPath:moreIndex];
    
    if ([moreCell isKindOfClass:[SNLoadingMoreCell class]]) {
        // 设置加载状态
        [(SNLoadingMoreCell*)moreCell hiddenActivityView:NO];
        
        // TODO:加载更多最新评论
        NewsCommentManager *commentMgr =
        [NewsCommentManager sharedInstance];
        
        [commentMgr getMoreNewCommentList:_thread
                    withCompletionHandler:^(NewsCommentResponse *resp) {
                        
            // 设置加载状态
            [(SNLoadingMoreCell*)moreCell hiddenActivityView:YES];
             
            // 检查最新评论是否有数据
            if (resp && resp.newsList.count > 0) {
                _commentDataSource.commentCount = resp.commentCount;
                
                //
                NSArray *addComment =
                [commentMgr removeSameCommentData:_commentDataSource.newsList addComment:resp.newsList];
                NSMutableArray *commentSource = [_commentDataSource.newsList mutableCopy];
                [commentSource addObjectsFromArray:addComment];
                
                [_commentTableView beginUpdates];
                if (commentSource.count >= _commentDataSource.commentCount) {
                    // 表示没有更多数据，删除moreCell
                    [_commentTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:moreIndex] withRowAnimation:UITableViewRowAnimationTop];
                }
                
                // 添加新增的评论
                _commentDataSource.newsList = commentSource;
                NSMutableArray *paths = [NSMutableArray array];
                [addComment enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                   
                    NSIndexPath *p = [NSIndexPath indexPathForRow:moreIndex.row+idx inSection:moreIndex.section];
                    [paths addObject:p];
                }];
                [_commentTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
                [_commentTableView endUpdates];
            }
        }];
    }
}


#pragma mark NewsCommentManagerDelegate
-(void)commentPraiseChanged:(NSUInteger)commentId
                praiseCount:(NSUInteger)praise
{
    if (!_commentDataSource || commentId <= 0) {
        return;
    }
    
    
    __block CommentBase *hotComment = nil;
    __block CommentBase *newComment = nil;
    [_commentDataSource.newsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([(CommentBase*)obj commentId] == commentId) {
            *stop = YES;
            hotComment = (CommentBase*)obj;
            [obj setValue:@(praise) forKey:@"up"];
            [obj setValue:@(1) forKey:@"attitude"];
        }
    }];
    [_commentDataSource.hotList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([(CommentBase*)obj commentId] == commentId) {
            *stop = YES;
            newComment = (CommentBase*)obj;
            [obj setValue:@(praise) forKey:@"up"];
            [obj setValue:@(1) forKey:@"attitude"];
        }
    }];
    
    
    // 把NewsCommentCell过滤出来identifier = @"commentCell"
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(reuseIdentifier == 'commentCell')"];
    NSArray *cells = [[_commentTableView visibleCells] filteredArrayUsingPredicate:predicate];
    [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger commentId = [(NewsCommentCell*)obj commentData].commentId;
        
        if (commentId == [hotComment commentId] ||
            commentId == [newComment commentId]) {
            [(NewsCommentCell*)obj refreshPraiseControl];
        }
    }];
}

#pragma mark - ****NewsComementViewDelegate****
//添加新的评论
-(void)insertNewsComment:(id)object
{
    if (![object isKindOfClass:[CommentBase class]] ||
        !_commentDataSource) {
        return;
    }
    
    

    if (!_commentDataSource.newsList ||
        _commentDataSource.newsList.count == 0) {
        _commentDataSource.newsList = [NSArray arrayWithObject:object];
        [_commentTableView reloadData];
        
        // 删除提示信息
        [_noDataTips removeFromSuperview];
    }
    else {
        NSMutableArray *newList = [_commentDataSource.newsList mutableCopy];
        [newList insertObject:object atIndex:0];
        _commentDataSource.newsList = newList;
        [_commentTableView reloadData];
    }
}

//用户点击屏幕，键盘下去
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_comView exitKeyboard];
}
@end
