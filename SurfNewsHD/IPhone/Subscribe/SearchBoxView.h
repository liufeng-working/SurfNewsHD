//
//  SearchBoxView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-6-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Extensions.h"
/**
 SYZ -- 2014/08/11
 搜索RSS源的搜索控件
 */
@protocol SearchBoxViewDelegate <NSObject>

@optional
- (void)doSearchAction:(NSString*)searchText showNotification:(BOOL)show;
- (void)doWebSearchAction:(NSString*)searchText;

@end

@interface SearchBoxView : UIView <UITextFieldDelegate>
{
    UIView *searchBg;
    UITextField *searchTextFiled;
    UIButton *searchButton;
    NSString *searchText;
}

@property(nonatomic, weak) id<SearchBoxViewDelegate> delegate;

-(void)searchBoxPlaceholder:(NSString*)placeholder;
- (void)popupKeyboard;
- (void)hideKeyboard;
- (void)applyTheme:(BOOL)isNight;
- (void)clearText;
- (void)setKeyboardType:(UIKeyboardType)type;

@end
