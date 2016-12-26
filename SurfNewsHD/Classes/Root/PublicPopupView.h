//
//  PublicPopupView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublicPopupView : UIView
{
    UIImageView *backgroundView;
    UILabel *titleLable;
    NSString *title;
}

@property(nonatomic, strong) NSString *title;

@end
