//
//  ImageMutiButton.h
//  SurfNewsHD
//
//  Created by jsg on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define UIImageViewSize   CGSizeMake(75, 75)
#define UISelectionBtn    CGRectMake(0, 0, 85, 85)
@class ImageMutiButton;
@protocol ImageMutiButtonDelegate
- (void)DidSelectedMuti:(NSString*)index
                withBtn:(id)sender;
@end

@interface ImageMutiButton : UIView
{
    UIImageView *m_imgView;
    UIButton *m_selectBtn;
    UIButton *m_selectMiniBtn;
    UIImageView *m_imgSelectView;
    
    BOOL isSelected;
    NSInteger totalBtn;
    BOOL isPressed;
    id<ImageMutiButtonDelegate> m_selectDelegate;
}

@property (nonatomic,retain) id<ImageMutiButtonDelegate> m_selectDelegate;
@property (nonatomic) UIImageView *m_imgView;
@property (nonatomic) UIButton *m_selectBtn;
@property (nonatomic) UIButton *m_selectMiniBtn;
@property (nonatomic) UIImageView *m_imgSelectView;
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,assign) BOOL isPressed;
@property (nonatomic,assign) NSInteger seletedCount;
@property (nonatomic,assign) NSInteger totalBtn;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) NSMutableArray *saveSeletedArr;


- (void)setupSubviews:(NSInteger)num :(BOOL)req :(UIColor*)color;
- (void)addButton:(NSInteger)num;
- (IBAction)itemPressed:(id)sender;
- (IBAction)itemPressedMini:(id)sender;
@end
