//
//  PopMenuView.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-8-2.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopMenuViewDelegate;

@interface PopMenuView : UIView
{
    UIButton *nightBt;
    BOOL isNight;
}

@property (nonatomic, assign) id<PopMenuViewDelegate>   popMenuViewDelegate;

@end


@protocol PopMenuViewDelegate <NSObject>

- (void)clickMenuBt:(UIButton *)bt;

@end