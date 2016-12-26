//
//  CustomPageControl.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPageControl : UIView{
    float _indicatorSpace;
}

@property(nonatomic,retain) UIColor *indicatorNormalColor;      // [UIColor grayColor]
@property(nonatomic,retain) UIColor *indicatorHighlightedColor; // [UIColor whiteColor]
@property(nonatomic)CGSize indicatorSize;   // default  CGSizeMake(10, 2)
@property(nonatomic) NSInteger numberOfPages;          // default is 0
@property(nonatomic) NSInteger currentPage;            // default is 0. value pinned to 0..numberOfPages-1
@property(nonatomic) BOOL hidesForSinglePage; // hide the the indicator if there is only one page. default is NO

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

@end