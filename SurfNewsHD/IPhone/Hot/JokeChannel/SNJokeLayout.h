//
//  SNJokeLayout.h
//  SurfNewsHD
//
//  Created by Tianyao on 16/2/2.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadSummary.h"

#define SNJokeCellContentFont   [UIFont systemFontOfSize:14.f]
#define SNJokeCellCountFont     [UIFont systemFontOfSize:13.f]

#define kScreenWidth            [UIScreen mainScreen].bounds.size.width
#define kJCellTopPadding        15.5f
#define kJCellLeftPadding       12.5f
#define kJCellRightPadding      12.5f
#define kJContentWidth          kScreenWidth - kJCellLeftPadding - kJCellRightPadding
#define kJActionsViewHeight     14.f
#define kJActionItemWidth       64.f

@interface SNJokeLayout : NSObject

@property (nonatomic, strong) ThreadSummary *joke;

@property (nonatomic, assign) CGRect textF;

@property (nonatomic, assign) CGFloat height;

@end
