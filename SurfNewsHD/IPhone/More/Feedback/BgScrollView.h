//
//  BgScrollView.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-20.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BgScrollViewDelegate;

@interface BgScrollView : UIScrollView

@property (nonatomic, assign) id<BgScrollViewDelegate>  bgSvDelegate;

@end


@protocol BgScrollViewDelegate <NSObject>

- (void)cilickBgScrollView:(BgScrollView *)bgScroll;

@end