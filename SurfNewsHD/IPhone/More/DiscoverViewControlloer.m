//
//  DiscoverViewControlloer.m
//  SurfNewsHD
//
//  Created by jsg on 14-10-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//
#define SEARCH_BTN_FRAME          CGRectMake(250, 0, 45, 40)


#import "DiscoverViewControlloer.h"
#import "RankingListViewController.h"
#import "DiscoverModel.h"
#import "NSDictionary+DictionaryWithString.h"
#import "SurfNewsHD-Prefix.pch"
#import "SearchViewController.h"


#define kNewsEnergy @"能量"


@interface DiscoverTableCell : UITableViewCell

@end

@implementation DiscoverTableCell


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // 70*70
    self.imageView.bounds = CGRectMake(0,0,35,35);
    CGPoint center = self.imageView.center;
    center.y = CGRectGetHeight(self.bounds)/2.f;
    self.imageView.center = center;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}
@end


@interface DiscoverViewControlloer ()
{
    UIButton *_exitBtn;
    NSString *_string;
    NSDictionary *_dictionary;
    NSIndexPath *_index;
    
    NSMutableArray *_items;
    MBProgressHUD *_progress;
    
    
    // error label
    __weak UIButton *_errorBtn;
}
@end

@implementation DiscoverViewControlloer

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        _items = [NSMutableArray array];
        self.titleState = PhoneSurfControllerStateRoot;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"发现"];
    
    
    // 初始化UI
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    CGFloat sX = 15.f, sY = self.StateBarHeight + 10.f;
    CGFloat sH = 40.f;
    CGFloat sW = w - sX - sX;
    [self initSearchViewWithRect:CGRectMake(sX, sY, sW, sH)];
    
    CGFloat disY = sY+sH+1;
    CGFloat disH = h-disY-kToolsBarHeight;
    CGRect disR = CGRectMake(0, sY+sH+1+10, w, disH);
    [self initDiscoverTableViewWithRect:disR];

    [self creatPost];
}

/**
 *  搜索框初始化
 *
 *  @param r 控件范围大小
 */
- (void)initSearchViewWithRect:(CGRect)r
{
    searchBtnField = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtnField.frame = r;
    [searchBtnField setTitle:@"搜索关键字" forState:UIControlStateNormal];
    [searchBtnField setTitleColor:[UIColor colorWithHexValue:0xff999292] forState:UIControlStateNormal];
    searchBtnField.backgroundColor = [UIColor whiteColor];
    searchBtnField.layer.cornerRadius = 5.0f;
    searchBtnField.layer.masksToBounds = YES;
    searchBtnField.layer.borderWidth = 0.2f;
    searchBtnField.layer.borderColor = [UIColor colorWithHexValue:0xff999292].CGColor;
    [searchBtnField addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    searchImageview = [[UIImageView alloc] initWithFrame:CGRectMake(70, 9, 20, 20)];
    [searchImageview setImage:[UIImage imageNamed:@"searchImageView"]];
    [searchBtnField addSubview:searchImageview];
    [self.view addSubview:searchBtnField];
    
}

/**
 *  搜索框点击事件
 */
- (void)searchBtnClick
{
    SearchViewController *searchVC = [SearchViewController new];
    [self presentController:searchVC animated:PresentAnimatedStateFromRight];
}

- (void)initDiscoverTableViewWithRect:(CGRect)r
{
    if (!discoverTableView)
    {
        discoverTableView =
        [[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
        [discoverTableView setDelegate:self];
        [discoverTableView setDataSource:self];
        [discoverTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        discoverTableView.separatorColor =
        [UIColor colorWithHexValue:0xffe3e2e2];
        [discoverTableView setTableFooterView:[UIView new]];
        discoverTableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:discoverTableView];
    }
}

-(void)showNotifiMark {
    if (!notifiMarkIamgeView) {
        notifiMarkIamgeView=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-20, 5, 6, 6)];
        [notifiMarkIamgeView setImage:[UIImage imageNamed:@"isnew"]];
    }
    if (![self.view.subviews containsObject:notifiMarkIamgeView]) {
        [self.view addSubview:notifiMarkIamgeView];
    }
}

- (void)isNightView:(UITableViewCell *)cell
{
    BOOL isNight = [[ThemeMgr sharedInstance] isNightmode];
    if (isNight) {
        [cell.selectedBackgroundView setBackgroundColor:[UIColor colorWithHexValue:kTableCellSelectedColor_N]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
        [cell.textLabel setTextColor:[UIColor blackColor]];
    }
}


- (void)loadDcitionaryData:(NSString*)content
{
    if (!content || [content isEmptyOrBlank]) {
        [self createErrorButton];
        return;
    }
    
    // 删除之前的所有的数据
    [_items removeAllObjects];
    
    
    // 初始化服务器返回数据
    NSDictionary *dic = [NSDictionary dictionaryWithJsonString:content];
    NSDictionary *dic2 = [NSDictionary dictionaryWithDictionary:dic];
    NSArray *arr = [dic2 objectForKey:@"item"];
    for (NSDictionary *dic in arr) {
        DiscoverModel *m = [DiscoverModel new];
        [m setValuesForKeysWithDictionary:dic];
        [_items addObject:m];
    }
    
    if ([_items count] == 0) {
        [self createErrorButton];
    }
    [discoverTableView  reloadData];
}


-(void)errorButtonClick:(id)sender
{
    [_errorBtn removeFromSuperview];
    [self creatPost];
}

#pragma mark discoverTableViewDelegate
//根据网络返回值
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscoverModel *m = [_items objectAtIndex:indexPath.row];
    NSString *cellid = [NSString stringWithFormat:@"cell%@", @(indexPath.row)];
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell)
    {
        cell = [[DiscoverTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
        cell.backgroundColor = [UIColor clearColor];
        
        
        UIColor *textColoe = [UIColor colorWithHexValue:0xFFAD2F2F];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        [cell.textLabel setTextColor:textColoe];
        [cell.textLabel setHighlightedTextColor:textColoe];
        cell.textLabel.text = m.title;
        
        // 显示正负能量标记
        if ([m.title rangeOfString:kNewsEnergy].location != NSNotFound) {
            UIImage* rankingImg = [UIImage imageNamed:@"rankingMark"];
            CGFloat vX = 195.0f;
            CGFloat vW = rankingImg.size.width;
            CGFloat vH = rankingImg.size.height;
            UIImageView *flagImg = [[UIImageView alloc] initWithFrame:CGRectMake(vX, 0, vW, vH)];      // 50*16
            [[cell contentView] addSubview:flagImg ];
        }
        
        // 箭头标记
        CGFloat width = CGRectGetWidth(tableView.bounds);
        CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        UIImageView *arrowView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"rightView"]];
        
        CGSize arrowSize = [arrowView sizeThatFits:CGSizeZero];
        CGFloat aX = width - arrowSize.width - 20;
        CGFloat aY = (height - arrowSize.height)/2.f;
        CGRect aFrame =
        CGRectMake(aX, aY, arrowSize.width, arrowSize.height);
        [arrowView setFrame:aFrame];
        [cell.contentView addSubview:arrowView];

        
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        
        //从端口加载图片 by Jack
        if(m.imagePath && ![m.imagePath isEmptyOrBlank]) {
            NSURL *url = [NSURL URLWithString:m.imagePath];
            NSData *data = [NSData dataWithContentsOfURL:url];
            cell.imageView.image = [UIImage imageWithData:data];
        }
        
       
        UIView *bg = [UIView new];
        bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell setSelectedBackgroundView:bg];
    }
    
    [self isNightView:cell];
    return cell;
}

- (void)creatPost
{
    [PhoneNotification manuallyHideWithText:@"正在载入，请稍候" indicator:YES];
    
    
    NSURL *url = [NSURL URLWithString:kDisciverChannel];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    id bodystr = [SurfJsonRequestBase new];
    NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:bodystr];
    NSString* post = [@"jsonRequest=" stringByAppendingString:[json urlEncodedString]];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    __block typeof(self) weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSString *str = [[NSString alloc] initWithData:data encoding:
                         [[response textEncodingName] convertToStringEncoding]];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            // 隐藏加载控件
            [PhoneNotification hideNotification];
            if (connectionError) {
                [weakSelf createErrorButton];
            }
            else {
                [weakSelf loadDcitionaryData:str];
            }
        });
    }];
}

/**
 *  创建异常显示button
 */
-(void)createErrorButton
{
    if(!_errorBtn) {
        BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
        UIColor *c = [UIColor whiteColor];
        if (!isN) {
            c = [UIColor colorWithHexValue:kReadTitleColor];
        }
        
        UIButton *errBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _errorBtn = errBtn;
        errBtn.frame = CGRectMake(0, 0, 200, 20);
        errBtn.center = self.view.center;
        [errBtn setTitle:@"加载失败，点击重新加载"
                   forState:UIControlStateNormal];
        [errBtn setTitleColor:c
                        forState:UIControlStateNormal];
        [errBtn addTarget:self action:@selector(errorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:errBtn];
    }
}


#pragma mark - UITableView选择cell的方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //对应行数来建模，每一个模型里包含所有网络上的数据
    if(indexPath.row >= 0 && indexPath.row < [_items count])
    {
        DiscoverModel *dm = [_items objectAtIndex:indexPath.row];
        // 这样的写法有点别扭，也只能这么搞了
        if ([dm.title rangeOfString:kNewsEnergy].location != NSNotFound) {
            
            RankingListViewController *RankinglistViewCrl = [[RankingListViewController alloc] init];
            RankinglistViewCrl.title = dm.title;
            [self presentController:RankinglistViewCrl animated:PresentAnimatedStateFromRight];
        }
        else {
            ThreadSummary* ts = [ThreadSummary new];
            ts.newsUrl = dm.contentUrl;
            ts.webView = 1; // 网页方式打开
            SNThreadViewerController * sn = [[SNThreadViewerController alloc] initWithThread:ts];
            [self presentController:sn animated:PresentAnimatedStateFromRight];
        }
    }
}


#pragma mark - NightModeChangedDelegate
-(void)nightModeChanged:(BOOL) night
{
    [super nightModeChanged:night];
    
    NSArray *cells = [discoverTableView visibleCells];
    for (UITableViewCell *c in cells) {
        [self isNightView:c];
    }
}
@end

