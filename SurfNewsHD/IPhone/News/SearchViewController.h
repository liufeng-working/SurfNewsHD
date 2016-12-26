//
//  SearchViewController.h
//  SurfNewsHD
//
//  Created by 潘俊申 on 15/7/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverViewControlloer.h"

@interface SearchViewController : PhoneSurfController <UITextFieldDelegate>

{
    UITextField *searchField;
    
    UIButton *searchBtn;
    
    UIView *bgView;
    
    BOOL keyboardShowing;

}

@end
