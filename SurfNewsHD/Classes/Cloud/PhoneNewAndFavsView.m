//
//  PhoneNewAndFavsView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneNewAndFavsView.h"
#import "FavsManager.h"
#import "FavsListView.h"
#import "PhoneNewsView.h"
#import "UserManager.h"
#import "PhoneNewsManager.h"


@interface PhoneNewAndFavsView ()
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) FavsListView *favsListView;
@property(nonatomic,strong) PhoneNewsView *phoneNewsView;
@property(nonatomic,strong) void(^indexChanger)(NSInteger);

@end

@implementation PhoneNewAndFavsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _scrollView = [[UIScrollView alloc] initWithFrame:[self bounds]];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setDelegate:self];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:_scrollView];
        
        CGRect rect = [self bounds];        
        _favsListView = [[FavsListView alloc] initWithFrame:rect];
        [_scrollView addSubview:_favsListView];
        
        
        _phoneNewsView = [[PhoneNewsView alloc] initWithFrame:rect];
        [_phoneNewsView setHidden:YES];        
        [_scrollView addSubview:_phoneNewsView];
        
    }
    return self;
}

-(void)setController:(SurfNewsViewController *)controller
{
    _controller = controller;
    [_favsListView setController:_controller];
    [_phoneNewsView setController:_controller];
}

- (void)refreshDate{
    [_favsListView refreshView];

    
    // 刷新手机报
    if ([self isLogin]) {
        [_phoneNewsView setHidden:NO];
        
        CGRect rect = [self bounds];
        rect.origin.x += rect.size.width;
        [_favsListView setFrame:rect];
        
        rect.size.width += rect.size.width;
        [_scrollView setContentSize:rect.size];
    }else{
        [_phoneNewsView setHidden:YES];
        [_favsListView setFrame:[self bounds]];
        
        [_scrollView setContentSize:[self bounds].size];
    }
    
    
    // 刷新手机报列表
    UserInfo *user = [[UserManager sharedInstance] loginedUser];
    if (user == nil || [[user userID] length] == 0)
    { return; }
    
    
    PhoneNewsManager *mgr = [PhoneNewsManager sharedInstance];
    
    [mgr refreshPhoneNewsList:^(BOOL succeeded, NSArray *arry) {
        if (succeeded) {            
            [_phoneNewsView reloadDataWithArray:arry];           
        }
    }];
}

-(BOOL)isLogin{
    return ([[UserManager sharedInstance] loginedUser] == nil) ? NO : YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_sView
{
    CGFloat width = _sView.frame.size.width;
    float index = floor((_sView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2
    [self changeScrollIndex:index];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    CGFloat width = scrollView.frame.size.width;
    float index = floor((scrollView.contentOffset.x - width / 2) / width) + 1;  // 0 1 2
    [self changeScrollIndex:index];
}

- (void)changeScrollIndex:(float)idx{
    if (_index != idx) {
        _index = idx;
        
        if (_indexChanger != nil) {
            _indexChanger(_index);
        }
    }
}

- (void)indexChanger:(void(^)(NSInteger idx))handle{
    _indexChanger = handle;
}

// 切换到手机报屏幕
- (void)changeToPhoneNewView{
    [_scrollView setContentOffset:CGPointMake(0.f, 0.f) animated:YES];
}
// 切换到收藏屏幕
- (void)changeToFavsView{
     [_scrollView setContentOffset:CGPointMake(CGRectGetWidth([self bounds]), 0.f) animated:YES];
}
@end
