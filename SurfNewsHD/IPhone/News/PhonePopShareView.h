//
//  PhonePopShareView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-10-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareMenuView.h"
#import "PhoneShareView.h"


@interface PhonePopShareView : UIView <ShareMenuViewDelegate>
{
    UIView *bgView;
}

@property(nonatomic, weak) id<PhoneShareWeiboDelegate> delegate;

@end
