//
//  ImageLoadModelView.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ImageLoadModelView.h"
#import "AppSettings.h"
#import "ThemeMgr.h"
#import "CustomAnimation.h"

#define BUTTONHEGHT     25

#define WIDTH           10.0f
#define HEIGHT          25.0f

#define BTTITLECOLOR    [UIColor hexChangeFloat:@"2D2E2F"]
#define NIGHTBTTITLECOLOR   [UIColor grayColor]
#define SELECTBTBGCOLOR     [UIColor colorWithRed:169/255.0f green:49/255.0f blue:43/255.0f alpha:1]
#define UNSELECTBTBGCOLOR   [UIColor clearColor]

@implementation ImageLoadModelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    isNight = [[ThemeMgr sharedInstance] isNightmode];

    if (_modelChange == TEXT_MODEL)
        [self getDefaultTxtModel];
    else if(_modelChange == IMAGE_MODEL)
        [self getDefaultImage];
    else if(_modelChange == NIGHT_MODEL)
        [self getNightModelFrom];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect rect1;
    CGRect rect2;
    CGRect rect3;
    CGRect rect4;
    
    if (!bgView)
    {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, BUTTONHEGHT)];
        bgView.backgroundColor = [UIColor colorWithRed:153/255.0f green:146/255.0f blue:146/255.0f alpha:1];

        [self addSubview:bgView];
    }
    
    bt1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt1 setBackgroundColor:[UIColor clearColor]];
    [bt1 addTarget:self action:@selector(changeBt:) forControlEvents:UIControlEventTouchUpInside];
    
    bt2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt2 setBackgroundColor:[UIColor clearColor]];
    [bt2 addTarget:self action:@selector(changeBt:) forControlEvents:UIControlEventTouchUpInside];
    
    bt3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt3 setBackgroundColor:[UIColor clearColor]];
    [bt3 addTarget:self action:@selector(changeBt:) forControlEvents:UIControlEventTouchUpInside];
    
    bt4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt4 setBackgroundColor:[UIColor clearColor]];
    [bt4 addTarget:self action:@selector(changeBt:) forControlEvents:UIControlEventTouchUpInside];

    [bt1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bt2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bt3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bt4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [bt1.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [bt2.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [bt3.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [bt4.titleLabel setFont:[UIFont systemFontOfSize:15]];
    
    float btwidth = 0;
    switch (_modelChange)
    {
        case TEXT_MODEL:
            [bt1 setTag:SMALL_TEXTMODEL];
            [bt2 setTag:DEFUALT_TEXTMODEL];
            [bt3 setTag:BIG_TEXTMODEL];
            [bt4 setTag:GREAT_TEXTMODEL];
            
            btwidth =  self.bounds.size.width / 4;
            rect1 = CGRectMake(0, 0, btwidth, BUTTONHEGHT);
            rect2 = CGRectMake(btwidth, 0, btwidth, BUTTONHEGHT);
            rect3 = CGRectMake(btwidth * 2, 0, btwidth, BUTTONHEGHT);
            rect4 = CGRectMake(btwidth * 3, 0, btwidth, BUTTONHEGHT);
            
            [bt1 setFrame:rect1];
            [bt2 setFrame:rect2];
            [bt3 setFrame:rect3];
            [bt4 setFrame:rect4];
            
            [bt1 setTitle:@"小" forState:UIControlStateNormal];
            [bt2 setTitle:@"中" forState:UIControlStateNormal];
            [bt3 setTitle:@"大" forState:UIControlStateNormal];
            [bt4 setTitle:@"极大" forState:UIControlStateNormal];
            
            break;
            
        case IMAGE_MODEL:
            [bt1 setTag:DEFAULT_IMAGEMODEL];
            [bt2 setTag:HD_IMAGEMODEL];
            [bt3 setTag:SUPER_IMAGEMODEL];
            
            btwidth =  self.bounds.size.width / 3;
            rect1 = CGRectMake(0, 0, btwidth, BUTTONHEGHT);
            rect2 = CGRectMake(btwidth, 0, btwidth, BUTTONHEGHT);
            rect3 = CGRectMake(btwidth * 2, 0, btwidth, BUTTONHEGHT);
            
            [bt1 setFrame:rect1];
            [bt2 setFrame:rect2];
            [bt3 setFrame:rect3];
            
            [bt1 setTitle:@"自动" forState:UIControlStateNormal];
            [bt2 setTitle:@"无图" forState:UIControlStateNormal];
            [bt3 setTitle:@"手动" forState:UIControlStateNormal];

            break;
            
        case NIGHT_MODEL:
            [bt1 setTag:LIGHT_MOD];
            [bt2 setTag:NIGHT_MOD];
            
            btwidth =  self.bounds.size.width / 2;
            [bt1 setFrame:CGRectMake(0, 0, btwidth, BUTTONHEGHT)];
            [bt2 setFrame:CGRectMake(btwidth, 0, btwidth, BUTTONHEGHT)];
            
            [bt1 setTitle:@"关" forState:UIControlStateNormal];
            [bt2 setTitle:@"开" forState:UIControlStateNormal];
            
            break;
            
        default:
            break;
    }
    
    [bgView addSubview:bt1];
    [bgView addSubview:bt2];
    [bgView addSubview:bt3];
    [bgView addSubview:bt4];
    
}

- (void)changeBt:(UIButton *)button
{
    switch (_modelChange)
    {
        case TEXT_MODEL:
            switch (button.tag)
        {
            case SMALL_TEXTMODEL:
                [bt1 setBackgroundColor:SELECTBTBGCOLOR];
                [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt4 setBackgroundColor:UNSELECTBTBGCOLOR];
                
                _textModel = SMALL_TEXTMODEL;
                [AppSettings setFloat:kWebContentSize1 forKey:FLOATKEY_ReaderBodyFontSize];

                break;
            case DEFUALT_TEXTMODEL:
                [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt2 setBackgroundColor:SELECTBTBGCOLOR];
                [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt4 setBackgroundColor:UNSELECTBTBGCOLOR];
                
                _textModel = DEFUALT_TEXTMODEL;
                [AppSettings setFloat:kWebContentSize2 forKey:FLOATKEY_ReaderBodyFontSize];

                break;
            case BIG_TEXTMODEL:
                [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt3 setBackgroundColor:SELECTBTBGCOLOR];
                [bt4 setBackgroundColor:UNSELECTBTBGCOLOR];
                
                _textModel = BIG_TEXTMODEL;
                [AppSettings setFloat:kWebContentSize3 forKey:FLOATKEY_ReaderBodyFontSize];

                break;
            case GREAT_TEXTMODEL:
                [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt4 setBackgroundColor:SELECTBTBGCOLOR];
                
                _textModel = GREAT_TEXTMODEL;
                [AppSettings setFloat:kWebContentSize4 forKey:FLOATKEY_ReaderBodyFontSize];

                break;
            default:
                break;
        }
            break;
        case IMAGE_MODEL:
            switch (button.tag)
        {
            case DEFAULT_IMAGEMODEL:
                [bt1 setBackgroundColor:SELECTBTBGCOLOR];
                [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
                
                _imageModel = DEFAULT_IMAGEMODEL;
                break;
            case HD_IMAGEMODEL:
                [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt2 setBackgroundColor:SELECTBTBGCOLOR];
                [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
                
                _imageModel = HD_IMAGEMODEL;
                break;
            case SUPER_IMAGEMODEL:
                [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt3 setBackgroundColor:SELECTBTBGCOLOR];
                
                _imageModel = SUPER_IMAGEMODEL;
                break;
            default:
                break;
        }
            [AppSettings setFloat:_imageModel - 1 forKey:IntKey_ReaderPicMode];
            break;
        case NIGHT_MODEL:
            NSLog(@"button.tag: %@", @(button.tag));

            switch (button.tag)
        {
            case LIGHT_MOD:
                [bt1 setBackgroundColor:SELECTBTBGCOLOR];
                [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
                _nightModel = LIGHT_MOD;
                break;
            case NIGHT_MOD:
                [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
                [bt2 setBackgroundColor:SELECTBTBGCOLOR];
                _nightModel = NIGHT_MOD;
                break;
            default:
                break;
        }

            [[ThemeMgr sharedInstance] changeNightmode:_nightModel];
            [self cilickCancelBt];
            break;
        default:
            break;
    }
}

- (void)cilickCancelBt
{
    if ([_imageLoadViewDelegate respondsToSelector:@selector(cancelcilick:)])
    {
        [_imageLoadViewDelegate cancelcilick:self];
    }
}

- (void)getDefaultTxtModel
{
    
    float model = [AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize];
    
    if (kWebContentSize1 == model)
    {
        [bt1 setBackgroundColor:SELECTBTBGCOLOR];
        [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt4 setBackgroundColor:UNSELECTBTBGCOLOR];
    }
    else if (kWebContentSize2 == model)
    {
        [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt2 setBackgroundColor:SELECTBTBGCOLOR];
        [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt4 setBackgroundColor:UNSELECTBTBGCOLOR];
    }
    else if (kWebContentSize3 == model)
    {
        [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt3 setBackgroundColor:SELECTBTBGCOLOR];
        [bt4 setBackgroundColor:UNSELECTBTBGCOLOR];
    }
    else if (kWebContentSize4 == model)
    {
        [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt4 setBackgroundColor:SELECTBTBGCOLOR];
    }
}


- (void)getDefaultImage
{

    ReaderPicMode picMode = [AppSettings integerForKey:IntKey_ReaderPicMode];
    if(picMode == ReaderPicOn)
    {        
        [bt1 setBackgroundColor:SELECTBTBGCOLOR];
        [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
    }
    else if(picMode == ReaderPicOff)
    {
        [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt2 setBackgroundColor:SELECTBTBGCOLOR];
        [bt3 setBackgroundColor:UNSELECTBTBGCOLOR];
    }
    else if(picMode == ReaderPicManually)
    {
        [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt3 setBackgroundColor:SELECTBTBGCOLOR];
    }
}

- (void)getNightModelFrom
{
    if (isNight)
    {
        [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt2 setBackgroundColor:SELECTBTBGCOLOR];
    }
    else
    {

        [bt1 setBackgroundColor:SELECTBTBGCOLOR];
        [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
    }
}

- (void)getNightModelFrom:(BOOL)nightModel
{
    if (nightModel)
    {
        [bt1 setBackgroundColor:UNSELECTBTBGCOLOR];
        [bt2 setBackgroundColor:SELECTBTBGCOLOR];
    }
    else
    {
        
        [bt1 setBackgroundColor:SELECTBTBGCOLOR];
        [bt2 setBackgroundColor:UNSELECTBTBGCOLOR];
    }    
}

@end
