//
//  SearchViewController.m
//  SurfNewsHD
//
//  Created by 潘俊申 on 15/7/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//


#define TABLEVIEWFRMAE            CGRectMake(0, super.StateBarHeight+55, 320, super.view.bounds.size.height - super.StateBarHeight - self.tabBarController.tabBar.bounds.size.height)

#import "SearchViewController.h"
#import "DiscoverViewControlloer.h"
#import "RankingListViewController.h"
#import "SurfNewsHD-Prefix.pch"
#import "SurfNewsViewController.h"
#import "PhoneSurfController.h"
#import "PhoneNotification.h"
#import "PathUtil.h"
#import "SNSearchHistoryView.h"
#import "FileUtil.h"
#import "SNSearchListView.h"




@interface SearchViewController ()<SNSearchHistoryDelegate,SelectSearchNewDeleate> {

    
    // 历史搜索记录
    BOOL _isSaveSearchHistory;
    NSMutableArray *_historyRecore;
    __weak SNSearchHistoryView *_searchHistoryView;
    

    // 搜索
    __weak SNSearchListView *_searchListView;
    
    
    __weak UIImageView *_bgImageView;
}

@end

@implementation SearchViewController

-(id)init{
    self = [super init];
    if (self) {
        [self setTitleState:PhoneSurfControllerStateTop];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"搜索"];
   
    
    // 加载历史搜索结果数据
    [self readSearchHistoryFromFile];

    
    // 搜索框
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat sX = 15.f, sH = 33;
    CGFloat sW = width - sX - sX;
    CGFloat sY = self.StateBarHeight + 15.f;
    CGRect sR = CGRectMake(sX, sY, sW, sH);
    [self creatSearchWithFrame:sR]; //初始化搜索框
    
    
    // 添加一个默认背景
    UIImage *bgImg = [UIImage imageNamed:@"dis_search_bg"];
    CGFloat bgW = bgImg.size.width + 30;
    CGFloat bgH = bgImg.size.height + 10;
    CGFloat bgY = sY + sY + 100.f;
    CGFloat bgX = (width - bgW)/2.f;
    CGRect bgR = CGRectMake(bgX, bgY, bgW, bgH);
    UIImageView *bgImgV = [[UIImageView alloc] initWithFrame:bgR];
    [bgImgV setImage:bgImg];
    _bgImageView = bgImgV;
    [self.view addSubview:bgImgV];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserver:self
                     selector:@selector(keyboardWillShow:)
                         name:UIKeyboardWillShowNotification
                       object:nil];
    
//    [notifyCenter addObserver:self
//                     selector:@selector(keyboardWillHide:)
//                         name:UIKeyboardWillHideNotification
//                       object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    // 保存搜索记录数据
    [self saveSearchHistoryToFile];
    [self hidderKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)creatSearchWithFrame:(CGRect)frame
{
    CGFloat bgW = CGRectGetWidth(frame);
    CGFloat bgH = CGRectGetHeight(frame);
    UIImage *searchBtnImg = [UIImage imageNamed:@"dis_search"];
    bgView = [[UIView alloc] initWithFrame:frame];
    bgView.layer.cornerRadius = 2.0f;
    bgView.layer.masksToBounds = YES;
    [bgView setBackgroundColor:[UIColor whiteColor]];
    {
        CGFloat sW = bgW - searchBtnImg.size.width;
        CGRect searchR = CGRectMake(5, 0, sW, bgH);
        searchField = [[UITextField alloc] initWithFrame:searchR];
        [searchField setBorderStyle:UITextBorderStyleNone];
        [searchField setFont:[UIFont fontWithName:@"Arial" size:12.5f]];
        searchField.secureTextEntry = NO;
        [searchField setPlaceholder:@"请搜索关键字"];
        searchField.textColor = [UIColor colorWithHexString:@"999292"];
        searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        searchField.autocorrectionType = UITextAutocorrectionTypeNo;
        searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        searchField.returnKeyType = UIReturnKeySearch;  // 返回按钮类型
        searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchField.keyboardType = UIKeyboardTypeURL;
        searchField.delegate = self;
        searchField.backgroundColor = [UIColor clearColor];
        [bgView addSubview:searchField];
        
        // 隐藏软键盘按钮
        searchField.inputAccessoryView = [self customInputAccessoryView];
  
        // 搜索按钮
        CGFloat sBtnX = searchR.origin.x + sW;
        CGFloat sBtnW = searchBtnImg.size.width;
        CGFloat sBtnH = searchBtnImg.size.height;
        CGRect sBtnR = CGRectMake(sBtnX, 0, sBtnW, sBtnH);
        searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        searchBtn.frame = sBtnR;
        [searchBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [searchBtn setImage:searchBtnImg forState:UIControlStateNormal];
        [searchBtn addTarget:self action:@selector(searchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:searchBtn];
        
        [self.view addSubview:bgView];
        
    }
    
}

/**
 *  软键盘附属控件
 *
 *  @return 自定义附属窗口
 */
- (UIView *)customInputAccessoryView
{
    CGFloat accessoryHeight = 44.f;
    CGFloat accessoryWidth = kContentWidth;
    CGRect accessFrame = CGRectMake(0.0, 0.0, accessoryWidth, accessoryHeight);
    UIView *inputAccessoryView =
    [[UIView alloc] initWithFrame:accessFrame];
    inputAccessoryView.backgroundColor = self.view.backgroundColor;
    
    // 隐藏键盘按钮
    // keyBoard 中的自定义隐藏keyboard 按钮
    UIImage *btnImg = [UIImage imageNamed:@"minikeyborad"];
    CGFloat bW = btnImg.size.width;
    CGFloat bH = btnImg.size.height;
    CGFloat bX = accessoryWidth - bW - 5;
    CGFloat bY = (accessoryHeight - btnImg.size.height);
    UIButton *hidderKeybordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hidderKeybordBtn.frame = CGRectMake(bX, bY, bW, bH);
    [hidderKeybordBtn setImage:btnImg forState:UIControlStateNormal];
    [hidderKeybordBtn addTarget:self action:@selector(exitKeyboardButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:hidderKeybordBtn];
    return inputAccessoryView;
}

/**
 *  显示历史搜索窗口(显示5条历史记录)
 */
-(void)showSearchHistoryView
{
    if (!_searchHistoryView) {
        CGFloat shX = bgView.frame.origin.x;
        CGFloat shWidth = CGRectGetWidth(bgView.bounds);
        CGFloat shY = bgView.frame.origin.y + bgView.frame.size.height;
        CGFloat historyH = 35;
        CGRect historyR = CGRectMake(shX, shY, shWidth, historyH);
        SNSearchHistoryView *searchView =
        [[SNSearchHistoryView alloc] initWithFrame:historyR];
        _searchHistoryView = searchView;
        searchView.layer.cornerRadius = 2.f;
        searchView.delegate = self;
        searchView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:searchView];
    }
    
    [_searchHistoryView setHidden:NO];
    [_searchHistoryView loadDataWithHistoryArray:_historyRecore];
    [_searchHistoryView sizeToFit]; // 必须在加载数据之后，会从新计算大小
}

#pragma mark searchFieldDelegate 设置搜索的代理

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (searchField.text == nil || [searchField.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"请输入关键字"];
        return NO;
    }
    else {
        [self hidderKeyboard];
        [self showSearchRecoreView:searchField.text];
    }
    return YES;
}



#pragma mark Observer methods 观察者方法
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (keyboardShowing) {
        return;
    }
    keyboardShowing = YES;
    [searchField.inputAccessoryView setHidden:NO];
    [self showSearchHistoryView];// 显示搜索结果
}
-(void)hidderKeyboard
{
    if (keyboardShowing) {
         keyboardShowing = NO;
        [searchField resignFirstResponder];
    }
}

-(void)exitKeyboardButtonClick:(id)sender
{
    [self hidderKeyboard];
}


-(void)searchButtonClick:(UIButton*)sender
{
    if (searchField.text == nil || [searchField.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"请输入关键字"];
    }
    else {
        [self hidderKeyboard];
        [self showSearchRecoreView:searchField.text];
    }
}

-(void)nightModeChanged:(BOOL) night
{
    [super nightModeChanged:night];
    
    
    [_searchHistoryView viewNightModeChanged:night];
    [_searchListView viewNightModeChanged:night];
    
}

#pragma mark- SNSearchHistoryDelegate

// 搜索历史记录
-(void)searchHistory:(id)userInfo
{
    searchField.text = userInfo;
    
    // 去服务器搜索
    [self hidderKeyboard];
    [self showSearchRecoreView:userInfo];
}


-(void)addSearchHistory:(id)userInfo
{
    searchField.text = userInfo;
}

-(void)deleateSearchHistory:(id)userInfo
{
    if ([_historyRecore containsObject:userInfo]) {
        _isSaveSearchHistory = YES;
        [_historyRecore removeObject:userInfo];
    }
}
// 清除历史记录
-(void)clearSearchHistory
{
    [self deleteSearchHistoryFromFile];
    
    [_searchHistoryView setHidden:YES];
}


#pragma mark- 搜索历史记录
/**
 *  从文件中删除历史搜索数据
 */
-(void)deleteSearchHistoryFromFile
{
    if ([_historyRecore count] == 0) {
        return;
    }
    
    [_historyRecore removeAllObjects];
    NSString *hisPath = [PathUtil pathOfSearchHistory];
    if ([FileUtil fileExists:hisPath]) {
        [FileUtil deleteFileAtPath:hisPath];
    }
}

#import "NSString+Extensions.h"
-(void)addSearchKeywordToData:(NSString*)keyword
{
    keyword = [keyword trim];
    if (!keyword || [keyword isEmptyOrBlank]) {
        return;
    }
    
    if (![_historyRecore containsObject:keyword]) {
        _isSaveSearchHistory = YES;
        [_historyRecore insertObject:keyword atIndex:0];
        if ([_historyRecore count] > 5) {
            [_historyRecore removeObjectAtIndex:5];
        }
    }
}


/**
 *  保存搜索历史记录
 */
-(void)saveSearchHistoryToFile
{
    if (_isSaveSearchHistory) {
        _isSaveSearchHistory = NO;
        NSString *hisPath = [PathUtil pathOfSearchHistory];
        [_historyRecore writeToFile:hisPath atomically:YES];
    }
}
/**
 *  从文件中读取搜索记录
 */
-(void)readSearchHistoryFromFile
{
    [_historyRecore removeAllObjects];
    NSString *hisPath = [PathUtil pathOfSearchHistory];
    _historyRecore = [NSMutableArray arrayWithContentsOfFile:hisPath];
    if (!_historyRecore) {
        _historyRecore = [NSMutableArray arrayWithCapacity:5];
    }
}


#pragma mark- 搜索关键字
-(void)showSearchRecoreView:(NSString *)keyword
{
    if (!_searchListView) {
        CGFloat height = CGRectGetHeight(self.view.bounds);
        CGFloat width = CGRectGetWidth(self.view.bounds);
        CGFloat sX = 0.f;
        CGFloat sY = bgView.frame.origin.y+bgView.frame.size.height+5;
        CGFloat sHeight = height - sY;
        CGRect sRect = CGRectMake(sX, sY, width, sHeight);
        
        SNSearchListView *searchView =
        [[SNSearchListView alloc] initWithFrame:sRect];
        _searchListView = searchView;
        searchView.deleate = self;
        [_bgImageView removeFromSuperview];
        
        if(_searchHistoryView){
            [[self view] insertSubview:searchView belowSubview:_searchHistoryView];
        }
        else {
            [[self view] addSubview:searchView];
        }
    }
   
    [_searchHistoryView setHidden:YES];
    [self addSearchKeywordToData:keyword];
    [_searchListView searchWithKeyword:keyword];
    
}
#pragma mark- SelectSearchNewDeleate
/**
 *  代理函数，处理搜索到的新闻。
 *
 *  @param ts 新闻信息
 */
-(void)selectSearchNew:(ThreadSummary*)ts
{
    SNThreadViewerController *threadVC =
    [[SNThreadViewerController alloc] initWithThread:ts ];
    [self presentController:threadVC animated:PresentAnimatedStateFromRight];
}
@end
