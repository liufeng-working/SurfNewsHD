//
//  ImageLoadModelView.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


#define IMAGELOADMODELVIEW_FRAME    CGRectMake(0, 0, 280, 200)

typedef enum {
    TEXT_MODEL = 0,
    IMAGE_MODEL,
    NIGHT_MODEL
} MODEL_CHANGE;

typedef enum {
    DEFAULT_IMAGEMODEL = 1,
    HD_IMAGEMODEL,
    SUPER_IMAGEMODEL
} IMAGEVIEWMODEL;

typedef enum {
    SMALL_TEXTMODEL = 1,
    DEFUALT_TEXTMODEL,
    BIG_TEXTMODEL,
    GREAT_TEXTMODEL
} TEXTMODEL;

typedef enum {
    LIGHT_MOD = 0,
    NIGHT_MOD
}NIGHTMODEL;

@protocol ImageLoadModelViewDelegate;

@interface ImageLoadModelView : UIView
{
    UIView   *bgView;
    UIButton *bt1;
    UIButton *bt2;
    UIButton *bt3;
    UIButton *bt4;
    
    BOOL isNight;
}

@property (nonatomic, assign) MODEL_CHANGE      modelChange;
@property (nonatomic, assign) IMAGEVIEWMODEL    imageModel;
@property (nonatomic, assign) TEXTMODEL         textModel;
@property (nonatomic, assign) NIGHTMODEL        nightModel;

@property (nonatomic, assign)   id<ImageLoadModelViewDelegate>  imageLoadViewDelegate;

- (void)getNightModelFrom:(BOOL)nightModel;

@end


@protocol ImageLoadModelViewDelegate <NSObject>

- (void)cancelcilick:(ImageLoadModelView *)imageMocelView;
- (void)entercilick:(ImageLoadModelView *)imageMocelView;

@end