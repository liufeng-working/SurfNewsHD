//
//  RankingListCell.h
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankingInfoResponse.h"
#import "SurfTableViewCell.h"


@interface RankingListCell : SurfTableViewCell



-(void)loadDataWithRankingNews:(RankingNews*)obj atIndex:(NSInteger)idx;

@end
