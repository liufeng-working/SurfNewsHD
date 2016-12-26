//
//  CloudViewBase.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudViewBase : UIView{
    UIScrollView *_scrollView;
}
// 无数据显示图片和文子
@property(nonatomic,strong)UIImageView *notDataImageView;
@property(nonatomic,strong)UILabel *notDataMsgLbl;

- (void)hiderNotDataView:(BOOL)hider;
- (BOOL)equalDayDate:(NSDate*)date1 date:(NSDate*)date2;
@end
