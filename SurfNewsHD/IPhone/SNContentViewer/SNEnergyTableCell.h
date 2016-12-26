//
//  SNEnergyTableCell.h
//  SurfNewsHD
//
//  Created by XuXg on 15/8/21.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurfTableViewCell.h"
#import "SNNewsContentInfoResponse.h"

@interface SNEnergyTableCell : SurfTableViewCell {
    __weak SNNewsExtensionInfo *_energyInfo;
    UIFont *_titleFont;
    
    // 正能量和负能量图片
    UIImage *_pIcon;
    UIImage *_nIcon;
    
    UIImage *_rArrow; // 右箭头
    UIImage *_p_en_flag;// 正能量标记图片
    UIImage *_n_en_flag;// 负能量标记图片
    
}

+(CGFloat)energyCellHeight;

-(void)loadEnergyInfo:(SNNewsExtensionInfo*)info;
@end
