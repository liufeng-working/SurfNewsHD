//
//  PhoneClassifyCell.h
//  SurfNewsHD
//
//  Created by xuxg on 14-10-13.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneClassifyCell : UIControl

@property BOOL isFlag;
@property(nonatomic,strong) UIImage *icon;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *content;
@property(nonatomic,strong) NSString *defaultContent;

@end
