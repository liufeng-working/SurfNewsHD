//
//  SNSpecialHeaderTableCell.h
//  SurfNewsHD
//
//  Created by XuXg on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SurfTableViewCell.h"

/**
 *  新闻专题头部
 */
@interface SNSpecialHeaderTableCell : SurfTableViewCell {
    
    UIImage *_specialIcon;
}

@property(nonatomic,strong)ThreadSummary *thread;

@end
