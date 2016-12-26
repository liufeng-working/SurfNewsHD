 //
//  PhoneSearchCityView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSearchCityView.h"
#import "PhoneSelectCityController.h"
#import "PhoneSelectCityCell.h"



@implementation PhoneSearchCityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 搜索框
        float backBtnW = 67.0f;
        float searchHeight = 30.f;
        float searchY = IOS7 ? 20.f :10.f;
        float searchWidth = frame.size.width - backBtnW - 10;
        CGRect searchRect = CGRectMake(0.f, searchY, searchWidth, searchHeight);
        _searchBoxView = [SearchBoxView new];
        [_searchBoxView setFrame:searchRect];
        _searchBoxView.delegate = self;
        [_searchBoxView searchBoxPlaceholder:@"输入拼音首字母"];
        [_searchBoxView popupKeyboard];
        [_searchBoxView applyTheme:[ThemeMgr sharedInstance].isNightmode];
        [_searchBoxView setKeyboardType:UIKeyboardTypeURL];
        [self addSubview:_searchBoxView];
        
        // 返回按钮
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setFrame:CGRectMake(CGRectGetWidth(frame) - backBtnW - 10, IOS7 ? 23 : 13, backBtnW, 39.0f)];
        [_backButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"cancel_search_channel"] forState:UIControlStateNormal];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_backButton addTarget:self action:@selector(didBack:)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        // 显示搜索的结果
        float tableViewY = searchHeight + searchY + 20;
        _tableViewHeight = CGRectGetHeight(frame)-tableViewY-10;
        CGRect scrollRect = CGRectMake(10, tableViewY, CGRectGetWidth(frame)-10-10, _tableViewHeight);
        _resultTableView = [[UITableView alloc] initWithFrame:scrollRect style:UITableViewStylePlain];
        _resultTableView.delegate = self;
        _resultTableView.dataSource = self;
        _resultTableView.userInteractionEnabled = YES;
        _resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _resultTableView.backgroundColor = [UIColor clearColor];
        [self addSubview:_resultTableView];
        
        [self addKeyboardObserver];
        
        [self viewNightModeChanged:[ThemeMgr sharedInstance].isNightmode];
        
        [self addToolsBar];
    }
    return self;
}

// 添加键盘事件观察者
- (void)addKeyboardObserver
{
    
    // 添加键盘事件
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    
    [notifyCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [notifyCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [notifyCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

// 删除键盘事件观察者
- (void)removeKeyboardObserver
{
    [_searchBoxView hideKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addToolsBar{
    if (toolsBottomBar) {
        return;
    }
    
    CGRect barR = CGRectMake(0.0f, CGRectGetHeight(self.frame) - kToolsBarHeight,
                             self.frame.size.width, kToolsBarHeight);
    toolsBottomBar = [[UIView alloc] initWithFrame:barR];
    toolsBottomBar.backgroundColor = self.backgroundColor;
    
    // 这个东西是一个状态栏顶部的阴影
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:(id)[[UIColor colorWithWhite:1.0f alpha:0.0] CGColor]];
    [colors addObject:(id)[[UIColor colorWithWhite:0.0f alpha:0.2] CGColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:CGRectMake(0,-2.0f,toolsBottomBar.frame.size.width,2.0f)];
    gradient.colors = colors;
    [toolsBottomBar.layer insertSublayer:gradient atIndex:0];
    [self addSubview:toolsBottomBar];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0f, 0.0f, 64.0f, 49.0f);
    [backButton setBackgroundImage:[UIImage imageNamed:@"backBar.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(KeyboardReturn) forControlEvents:UIControlEventTouchUpInside];
    [toolsBottomBar addSubview:backButton];
}


-(void)searchCityName:(NSString*)searchText
{
    if (_dateSource.count > 0) {
        CGFloat maxWidth = _resultTableView.bounds.size.width;
        
        
        if([searchText isContainsEmoji]){
            [PhoneNotification autoHideWithText:@"内容包含表情符号，暂不支持"];
            return;
        }
        
        
        NSArray *hotCityArray;
        NSString *regex = @"[a-z]|[A-Z]";
        NSPredicate *emailFormat = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([emailFormat evaluateWithObject:searchText]){
            // 用拼音首字母查找
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(pyshort beginswith[c] %@)", searchText];
            hotCityArray = [_dateSource filteredArrayUsingPredicate:predicate];
            _cellData = [[SelectCityCellData alloc] initWithCities:hotCityArray showWidth:maxWidth];
        }
        else{
            // 中文字
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", searchText];
            hotCityArray = [_dateSource filteredArrayUsingPredicate:predicate];
            _cellData = [[SelectCityCellData alloc] initWithCities:hotCityArray showWidth:maxWidth];
        }
        
        if (_selectCityCell) {
            [_resultTableView reloadData];
        }
    }
}

- (void)keyboardWillShow:(NSNotification*)notification{

    if (keyboardShowing) {
        return;
    }
    
    [self addMiniKeyBoard];
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    if (!keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             CGRect toolsBottomBarFrame = toolsBottomBar.frame;
                             toolsBottomBarFrame.origin.y -= height;
                             toolsBottomBar.frame = toolsBottomBarFrame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = YES;
    
    CGRect keyboardFrame;
    [[[(notification) userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    float keybordHeight = CGRectGetHeight(keyboardFrame);
    
    // 设置tableView 的显示区域
    if (CGRectGetHeight(_resultTableView.bounds) == _tableViewHeight) {
        CGRect tempFrame = _resultTableView.frame;
        tempFrame.size.height = _tableViewHeight - keybordHeight - 10;
        _resultTableView.frame = tempFrame;
        [_resultTableView reloadData];
    }
}
- (void)keyboardWillHide:(NSNotification*)notification{
    
    if (!keyboardShowing){
        return;
    }

    [self dismissMiniKeyBoard];
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    if (keyboardShowing) {
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             CGRect toolsBottomBarFrame = toolsBottomBar.frame;
                             toolsBottomBarFrame.origin.y += height;
                             toolsBottomBar.frame = toolsBottomBarFrame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = NO;
    
    if (CGRectGetHeight(_resultTableView.bounds) != _tableViewHeight) {
        CGRect tempFrame = _resultTableView.frame;
        tempFrame.size.height = _tableViewHeight;
        _resultTableView.frame = tempFrame;
        [_resultTableView reloadData];
    }
}

-(void)keyboardWillChangeFrame:(NSNotification*)notification
{
    if (!keyboardShowing) {
        return;
    }
    
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float btnW = CGRectGetWidth(toolsBottomBar.bounds);
    float btnH = CGRectGetHeight(toolsBottomBar.bounds);
    float btnY = kContentHeight - endRect.size.height - btnH;
    float btnX = endRect.origin.x + CGRectGetWidth(endRect) - btnW;
    toolsBottomBar.frame = CGRectMake(btnX, btnY, btnW, btnH);
}

- (void)addMiniKeyBoard{
    
    miniButton = [UIButton buttonWithType:UIButtonTypeCustom];
    miniButton.frame = CGRectMake(320.0f - 50.0f, 7.0f, 34.0f, 34.0f);
    [miniButton setBackgroundImage:[UIImage imageNamed:@"minikeyborad.png"] forState:UIControlStateNormal];
    [miniButton addTarget:self action:@selector(KeyboardHide) forControlEvents:UIControlEventTouchUpInside];
    [toolsBottomBar addSubview:miniButton];
}

- (void)dismissMiniKeyBoard{
    [miniButton removeFromSuperview];
}

- (void)KeyboardHide{
    [_searchBoxView hideKeyboard];
}

- (IBAction)KeyboardReturn{
    [self removeKeyboardObserver];
    Class classType = [PhoneSelectCityController class];
    PhoneSelectCityController *controller = [self findUserObject:classType];
    if ([controller isKindOfClass:classType]) {
        [controller hiderSearchCityView];
    }
}

#pragma mark dateSource
- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_cellData) {
        if (CGRectGetHeight(tableView.bounds) > [_cellData CellHeight]) {
            return CGRectGetHeight(tableView.bounds);
        }
        return [_cellData CellHeight];
    }
    else{
        return CGRectGetHeight(tableView.bounds);
    }
}
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_selectCityCell) {
        _selectCityCell = [[PhoneSelectCityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        _selectCityCell.selectCityDelegate = self;
        _selectCityCell.backgroundColor = [UIColor clearColor];
        _selectCityCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [_selectCityCell reloadCities:_cellData];

    return _selectCityCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_searchBoxView hideKeyboard];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_selectCityCell recoverCellState];
    
}
#pragma mark SelectCityDelegate
-(void)selectCity:(CityInfo*)cityInfo{
    // 删除键盘观察者
    [self removeKeyboardObserver];    
    
    Class classType = [PhoneSelectCityController class];
    PhoneSelectCityController *controller = [self findUserObject:classType];
    if ([controller isKindOfClass:classType]) {
        [controller selectCity:cityInfo];
    }
}

#pragma mark SearchBoxViewDelegate
- (void)doSearchAction:(NSString*)searchText
      showNotification:(BOOL)show
{
    [self searchCityName:searchText];
}

-(void)doWebSearchAction:searchText
{
    [self searchCityName:searchText];
    [_searchBoxView hideKeyboard];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([touches anyObject] != _searchBoxView) {
        [_searchBoxView hideKeyboard];
    }
}

// 返回
-(void)didBack:(id)sender{
    [self removeKeyboardObserver];
    Class classType = [PhoneSelectCityController class];
    PhoneSelectCityController *controller = [self findUserObject:classType];
    if ([controller isKindOfClass:classType]) {
        [controller hiderSearchCityView];
    }
}

-(void)viewNightModeChanged:(BOOL)isNight
{
    [_searchBoxView applyTheme:[ThemeMgr sharedInstance].isNightmode];
    if (isNight) {
        self.backgroundColor = [UIColor colorWithHexValue:0xFF2D2E2F];
    }
    else{
        self.backgroundColor = [UIColor colorWithHexValue:0xFFF8F8F8];
    }
}
@end
