//
//  PhoneNewsView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudViewBase.h"
@class PhoneNewsData;


@interface PhoneNewsView : CloudViewBase<UIAlertViewDelegate>{
    PhoneNewsData *deleteNews;
    NSMutableArray *newsArray;
    UIActivityIndicatorView *_loadingView;
}
@property(nonatomic,weak)SurfNewsViewController *controller;

- (void)reloadDataWithArray:(NSArray*)phoneNews;
@end
