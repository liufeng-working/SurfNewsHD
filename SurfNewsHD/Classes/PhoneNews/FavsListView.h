//
//  FavsListView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudViewBase.h"

@interface FavsListView : CloudViewBase
@property(nonatomic,weak)SurfNewsViewController *controller;

- (void)refreshView;
@end
