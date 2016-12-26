//
//  SearchBoxControl.h
//  SurfNewsHD
//
//  Created by SYZ on 13-7-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 SYZ -- 2014/08/11
 SearchBoxControl在AddSubscribeController界面用到的一个搜索式样的control
 */

@interface SearchBoxControl : UIControl
{
    NSString *tipString;
    CGImageRef searchImage;
}

- (id)initWithFrame:(CGRect)frame tipString:(NSString*)string;

@property(nonatomic, strong) UIFont *textFont;

@end
