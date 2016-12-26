//
//  PhoneBeautyChannelCell.h
//  SurfNewsHD
//
//  Created by XuXg on 15/1/6.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SurfTableViewCell.h"

// 美女频道tableView cell
@interface PhoneBeautyChannelCell : SurfTableViewCell

+(UIEdgeInsets)imageEdgeInsets;

// 加载数据
-(void)loadingDataWithThreadSummary:(ThreadSummary*)ts;
@end
