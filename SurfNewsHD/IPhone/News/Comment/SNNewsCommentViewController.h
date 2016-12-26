//
//  SNNewsCommentViewController.h
//  SurfNewsHD
//
//  Created by XuXg on 15/5/29.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"


/**
 *  新闻评论
 */
@interface SNNewsCommentViewController : PhoneSurfController

@property(nonatomic,strong)ThreadSummary* thread;
@end
