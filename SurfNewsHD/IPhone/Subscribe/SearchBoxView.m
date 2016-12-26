//
//  SearchBoxView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-6-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SearchBoxView.h"

@implementation SearchBoxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        float buttonWidth = 50.0f;
        
        searchBg = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 5.0f, self.frame.size.width - 20.0f, 35.0f)];
        searchBg.layer.cornerRadius = 1.0f;
        [self addSubview:searchBg];
        
        //self.frame.size.width - buttonWidth - 40.0f, 40.0f是左右边距的宽度
        CGRect rect = CGRectMake(20.0f, 5.0f, self.frame.size.width - buttonWidth - 30.0f, 35.0f);
        searchTextFiled = [[UITextField alloc] initWithFrame:rect];
        [searchTextFiled setTextColor:[UIColor colorWithHexString:@"999292"]];
        [searchTextFiled setBackgroundColor:[UIColor clearColor]];
        [searchTextFiled setFont:[UIFont systemFontOfSize:15.0f]];
        [searchTextFiled setPlaceholder:@"请输入栏目名称"];
        searchTextFiled.delegate = self;
        searchTextFiled.returnKeyType = UIReturnKeySearch;
        searchTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchTextFiled.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        searchTextFiled.autocorrectionType = UITextAutocorrectionTypeNo;
        searchTextFiled.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [searchTextFiled addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:searchTextFiled];
        
        searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchButton setBackgroundImage:[UIImage imageNamed:@"search_subs_channel.png"]
                                forState:UIControlStateNormal];
        searchButton.frame = CGRectMake(kContentWidth - buttonWidth - 10.0f, 5.0f, buttonWidth, 35.0f);
        [searchButton addTarget:self action:@selector(doSearch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchButton];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    float buttonWidth = 50.0f;
    searchBg.frame = CGRectMake(10.0f, 5.0f, frame.size.width - 20.0f, 35.0f);
    searchTextFiled.frame = CGRectMake(20.0f, 5.0f, frame.size.width - buttonWidth - 30.0f, 35.0f);
    searchButton.frame = CGRectMake(frame.size.width - buttonWidth - 10.0f, 5.0f, buttonWidth, 35.0f);
}

- (void)doSearch:(id)sender
{
    if (searchTextFiled.text == nil ||
        [searchTextFiled.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"搜索内容不能为空"];
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(doSearchAction:showNotification:)]) {
        [_delegate doSearchAction:searchTextFiled.text showNotification:YES];
    }
}

-(void)searchBoxPlaceholder:(NSString*)placeholde
{
    [searchTextFiled setPlaceholder:placeholde];
}

- (void)popupKeyboard
{
    [searchTextFiled becomeFirstResponder];
//    [searchTextFiled resignFirstResponder];
}

- (void)hideKeyboard
{
    [searchTextFiled resignFirstResponder];
}

- (void)setKeyboardType:(UIKeyboardType)type
{
    searchTextFiled.keyboardType = type;
}

- (void)clearText 
{
    searchTextFiled.text = nil;
}

- (void)applyTheme:(BOOL)isNight
{
    if (isNight) {
        [searchBg setBackgroundColor:[UIColor colorWithHexString:@"222223"]];
    } else {
        [searchBg setBackgroundColor:[UIColor colorWithHexString:@"F3F1F1"]];
    }
}

//检测输入文字变化
- (void)textFieldEditChanged:(UITextField *)textField
{
    searchText = textField.text;
    if ([_delegate respondsToSelector:@selector(doSearchAction: showNotification:)]) {
        [_delegate doSearchAction:searchText showNotification:NO];
    }
}

#pragma mark UITextFieldDelegate methods
//SYZ -- 2014/08/11 点击键盘右下角搜索按钮的时候执行联网搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (searchText && ![searchText isEmptyOrBlank]) {
        if ([_delegate respondsToSelector:@selector(doWebSearchAction:)]) {
            [_delegate doWebSearchAction:searchText];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    searchText = @"";
    if ([_delegate respondsToSelector:@selector(doSearchAction:showNotification:)]) {
        [_delegate doSearchAction:searchText showNotification:YES];
    }
    return YES;
}

@end
