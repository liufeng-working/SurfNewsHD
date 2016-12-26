//
//  ImageMutiButton.m
//  SurfNewsHD
//
//  Created by jsg on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ImageMutiButton.h"

@implementation ImageMutiButton

@synthesize m_imgView;
@synthesize m_selectBtn;
@synthesize m_selectMiniBtn;
@synthesize m_imgSelectView;
@synthesize isSelected;
@synthesize isPressed;
@synthesize totalBtn;
@synthesize itemSize;
@synthesize m_selectDelegate;


- (id)init {
	self = [super init];
	
	if (self) {

		itemSize = UIImageViewSize;
	}
	
	return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupSubviews:(NSInteger)num :(BOOL)req :(UIColor*)color{
    self.m_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemSize.width+3, itemSize.width+3)];
    if (req) {
        //[self.m_imgView setImage:[UIImage imageNamed:@"rahmen.png"]];
        [self.m_imgView setBackgroundColor:color];
    }
    else{
        [self.m_imgView setImage:[UIImage imageNamed:@"webview-img-click-to-download-fg.png"]];
    }

    self.m_imgView.userInteractionEnabled = YES;
    [self addSubview:self.m_imgView];
    isSelected = NO;
    isPressed = NO;

}


- (void)addButton:(NSInteger)num{
    
    //Btn
    self.m_selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.m_selectBtn.frame = self.m_imgView.frame;
    self.m_selectBtn.tag = num;

    self.totalBtn = num;
    [self.m_selectBtn addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.m_selectBtn];
    
    
    self.m_selectMiniBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.m_selectMiniBtn setFrame:CGRectMake(itemSize.width+0.5, 0, 17-0.5, 17)];
    self.m_selectMiniBtn.tag = num;
    
    //MiniBtn
    self.m_imgSelectView = [[UIImageView alloc] initWithFrame:CGRectMake(-5, -2, 17-0.5, 17)];
    [self.m_imgSelectView setImage:[UIImage imageNamed:@"unDilog.png"]];
    self.m_imgSelectView.tag = num;
    
    [self.m_selectMiniBtn addSubview:self.m_imgSelectView];
    [self.m_selectMiniBtn addTarget:self action:@selector(itemPressedMini:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.m_selectMiniBtn];
}

- (IBAction)itemPressed:(id)sender{
    NSUInteger index = [sender tag];
    NSString *strTmp = [NSString stringWithFormat:@"%@",@(index)];
    
    [m_selectDelegate DidSelectedMuti:strTmp withBtn:sender];
}

- (IBAction)itemPressedMini:(id)sender{
    NSUInteger index = [sender tag];
    NSString *strTmp = [NSString stringWithFormat:@"%@",@(index)];
    
    [m_selectDelegate DidSelectedMuti:strTmp withBtn:sender];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
