//
//  PhoneSelectCityCell.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityInfo.h"

@protocol SelectCityDelegate <NSObject>
@required
-(void)selectCity:(CityInfo*)cityInfo;

@end


@interface SelectCityCellData : NSObject

@property(nonatomic,readonly)float CellHeight;

//showWidth 控件显示在多大的范围中显示
- (id)initWithCities:(NSArray*)cities showWidth:(int)maxWidth;


@end



///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
@interface PhoneSelectCityCell : UITableViewCell<UIGestureRecognizerDelegate>{
    UIFont *_btnFont;
    UIColor *_btnTextColor;
    UIColor *_btnTextHColor;
    
    UIColor *_roundBtbMargeColor;
    UIColor *_roundBtnBgColor;
    UIColor *_roundBtnHLColor;  // 高亮颜色
    
//    NSMutableArray *_buttones;
    SelectCityCellData *_tempCellData;
    
    CGRect _touchRect; // 点击区域
    CityInfo *_touchCityInfo;
}
@property(nonatomic,weak)id<SelectCityDelegate> selectCityDelegate;
- (void)reloadCities:(SelectCityCellData*)cityData; // 重新加载城市数据

- (void)recoverCellState;   // 恢复Cell状态
@end
