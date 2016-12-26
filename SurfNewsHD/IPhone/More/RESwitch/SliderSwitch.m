//
//  SlideView.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SliderSwitch.h"
#import "AppSettings.h"

@implementation SliderSwitch
@synthesize labelTwo,labelOne,labelFour,labelThree;
@synthesize toggleButton,numberOflabels;

@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code       
   
    }
    
    return self;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSEnumerator *reverseE = [self.subviews reverseObjectEnumerator];
    UIView *iSubView;
    
    while ((iSubView = [reverseE nextObject])) {
        
        UIView *viewWasHit = [iSubView hitTest:[self convertPoint:point toView:iSubView] withEvent:event];
        if(viewWasHit) {
            return viewWasHit;
        }
        
    }
    return [super hitTest:point withEvent:event];
}

- (void)showBackGround:(CGRect)frame
{
    if (!backgroundImageView) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:backgroundImageView];
    }
    [backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    UIImage *image = [UIImage imageNamed:[[ThemeMgr sharedInstance] isNightmode]?
                      @"segmented-night.png":@"segmented-bg.png"];
    image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    backgroundImageView.image = image;
}


- (void)setFrameHorizontal:(CGRect)frame numberOfFields:(NSInteger)number withCornerRadius:(CGFloat)cornerRadius
{
    [self showBackGround:frame];
    
    float width;
    int n=(int)number;
    numberOflabels=n;
    float f=(float)frame.size.width;    
    width=f/n;
    
    UIFont *txtFont = [UIFont systemFontOfSize:12];
    UIColor *txtColor = [UIColor grayColor];
    if (!line1) {
        line1 = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    if (!line2) {
        line2 = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    if (!line3) {
        line3 = [UIButton buttonWithType:UIButtonTypeCustom];
    }

    toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
   	toggleButton.frame = CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height);
    [toggleButton.titleLabel setFont:txtFont];
    [toggleButton setBackgroundImage:[UIImage imageNamed:@"segmented-center"] forState:UIControlStateNormal];
    
    
    if (number==2) {
        labelOne = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height)];
        [labelOne setTextAlignment:NSTextAlignmentCenter];
        [labelOne setBackgroundColor:[UIColor clearColor]];
        [self addSubview:labelOne];
        
        labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x+width, frame.origin.y, width, frame.size.height)];
        [labelTwo setTextAlignment:NSTextAlignmentCenter];
        [labelTwo setBackgroundColor:[UIColor clearColor]];
        [self addSubview:labelTwo];
        
        [labelOne setFont:txtFont];
        [labelTwo setFont:txtFont];
        
        [labelOne setTextColor:txtColor];
        [labelTwo setTextColor:txtColor];
        
        labelOne.userInteractionEnabled=YES;
        labelTwo.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGestureLabelone =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelOneWithGesture:)];
        [labelOne addGestureRecognizer:tapGestureLabelone];
        UITapGestureRecognizer *tapGestureLabelTwo =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelTwoWithGesture:)];
        [labelTwo addGestureRecognizer:tapGestureLabelTwo];
        
        [line1 setFrame:CGRectMake(frame.origin.x + width, frame.origin.y, 1, frame.size.height)];
        [line1 setBackgroundColor:[UIColor colorWithRed:199/255 green:195/255 blue:195/255 alpha:0.2]];
        [self addSubview:line1];
    }
    
    
    if (number == 3) {
        
        labelOne = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height)];
        [labelOne setTextAlignment:NSTextAlignmentCenter];
        [labelOne setBackgroundColor:[UIColor clearColor]];
        [self addSubview:labelOne];
        
        labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x+width, frame.origin.y, width, frame.size.height)];
        [labelTwo setTextAlignment:NSTextAlignmentCenter];
        [labelTwo setBackgroundColor:[UIColor clearColor]];
        [self addSubview:labelTwo];
        
        labelThree = [[UILabel alloc] initWithFrame:CGRectMake(labelTwo.frame.origin.x+width, frame.origin.y, width, frame.size.height)];
        [labelThree setTextAlignment:NSTextAlignmentCenter];
        [labelThree setBackgroundColor:[UIColor clearColor]];
        [self addSubview:labelThree];
        
        labelOne.userInteractionEnabled=YES;
        labelTwo.userInteractionEnabled=YES;
        labelThree.userInteractionEnabled=YES;
        
        [labelOne setFont:txtFont];
        [labelTwo setFont:txtFont];
        [labelThree setFont:txtFont];
        
        [labelOne setTextColor:txtColor];
        [labelTwo setTextColor:txtColor];
        [labelThree setTextColor:txtColor];
        
        UITapGestureRecognizer *tapGestureLabelone =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelOneWithGesture:)];
        [labelOne addGestureRecognizer:tapGestureLabelone];
        UITapGestureRecognizer *tapGestureLabelTwo =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelTwoWithGesture:)];
        [labelTwo addGestureRecognizer:tapGestureLabelTwo];
        UITapGestureRecognizer *tapGestureLabelThree =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelThreeWithGesture:)];
        [labelThree addGestureRecognizer:tapGestureLabelThree];
        
        [line1 setFrame:CGRectMake(frame.origin.x + width, frame.origin.y, 1, frame.size.height)];
        [line1 setBackgroundColor:[UIColor colorWithRed:199/255 green:195/255 blue:195/255 alpha:0.2]];
        [self addSubview:line1];
        
        [line2 setFrame:CGRectMake(labelTwo.frame.origin.x + width, frame.origin.y, 1, frame.size.height)];
        [line2 setBackgroundColor:[UIColor colorWithRed:199/255 green:195/255 blue:195/255 alpha:0.2]];
        [self addSubview:line2];
    }
    
    if (number == 4) {
        labelOne = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height)];
        [labelOne setTextAlignment:NSTextAlignmentCenter];
        [labelOne setBackgroundColor:[UIColor clearColor]];
        [self addSubview:labelOne];
        
        labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x+width, frame.origin.y, width, frame.size.height)];
        [labelTwo setTextAlignment:NSTextAlignmentCenter];
        [labelTwo setBackgroundColor:[UIColor clearColor]];
        [self addSubview:labelTwo];
        
        labelThree = [[UILabel alloc] initWithFrame:CGRectMake(labelTwo.frame.origin.x+width, frame.origin.y, width, frame.size.height)];
        [labelThree setTextAlignment:NSTextAlignmentCenter];
        [labelThree setBackgroundColor:[UIColor clearColor]];
        [self addSubview:labelThree];
        
        labelFour = [[UILabel alloc] initWithFrame:CGRectMake(labelThree.frame.origin.x+width, frame.origin.y, width, frame.size.height)];
        [labelFour setTextAlignment:NSTextAlignmentCenter];
        [labelFour setBackgroundColor:[UIColor clearColor]];
        [self addSubview:labelFour];
        
        [labelOne setFont:txtFont];
        [labelTwo setFont:txtFont];
        [labelThree setFont:txtFont];
        [labelFour setFont:txtFont];
        
        [labelOne setTextColor:txtColor];
        [labelTwo setTextColor:txtColor];
        [labelThree setTextColor:txtColor];
        [labelFour setTextColor:txtColor];

        labelOne.userInteractionEnabled=YES;
        labelTwo.userInteractionEnabled=YES;
        labelThree.userInteractionEnabled=YES;
        labelFour.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *tapGestureLabelone =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelOneWithGesture:)];
        [labelOne addGestureRecognizer:tapGestureLabelone];
        UITapGestureRecognizer *tapGestureLabelTwo =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelTwoWithGesture:)];
        [labelTwo addGestureRecognizer:tapGestureLabelTwo];
        UITapGestureRecognizer *tapGestureLabelThree =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelThreeWithGesture:)];
        [labelThree addGestureRecognizer:tapGestureLabelThree];
        UITapGestureRecognizer *tapGestureLabelFour =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelFourWithGesture:)];
        [labelFour addGestureRecognizer:tapGestureLabelFour];
        
        
        [line1 setFrame:CGRectMake(frame.origin.x + width, frame.origin.y, 1, frame.size.height)];
        [line1 setBackgroundColor:[UIColor colorWithRed:199/255 green:195/255 blue:195/255 alpha:0.2]];
        [self addSubview:line1];
        
        [line2 setFrame:CGRectMake(labelTwo.frame.origin.x + width, frame.origin.y, 1, frame.size.height)];
        [line2 setBackgroundColor:[UIColor colorWithRed:199/255 green:195/255 blue:195/255 alpha:0.2]];
        [self addSubview:line2];
        
        [line3 setFrame:CGRectMake(labelThree.frame.origin.x + width, frame.origin.y, 1, frame.size.height)];
        [line3 setBackgroundColor:[UIColor colorWithRed:199/255 green:195/255 blue:195/255 alpha:0.2]];
        [self addSubview:line3];
    }

    [self addSubview:toggleButton];
    
    
}
#define LINEWIDTH       0
#define ONEFEAME    CGRectMake(labelOne.frame.origin.x+LINEWIDTH, labelOne.frame.origin.y-1, labelOne.frame.size.width+LINEWIDTH+3, labelOne.frame.size.height+2)
#define TOWFRMAME   CGRectMake(labelTwo.frame.origin.x+LINEWIDTH, labelTwo.frame.origin.y-1, labelTwo.frame.size.width+LINEWIDTH+3, labelTwo.frame.size.height+2)
#define THREEFEAME  CGRectMake(labelThree.frame.origin.x+LINEWIDTH, labelThree.frame.origin.y-1, labelThree.frame.size.width+LINEWIDTH+3, labelThree.frame.size.height+2)
#define FOURFEAME   CGRectMake(labelFour.frame.origin.x+LINEWIDTH, labelFour.frame.origin.y-1, labelFour.frame.size.width+3, labelFour.frame.size.height+2)

- (void)refresh
{
    [self showBackGround:backgroundImageView.frame];
    if (_modelChange == TEXT_MODEL) {
        float model = [AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize];
        if (model == kWebContentSize1)
        {
            [toggleButton setFrame:ONEFEAME];
            [toggleButton setTitle:@"小" forState:UIControlStateNormal];
        }
        else if (model == kWebContentSize2)
        {
            [toggleButton setFrame:TOWFRMAME];
            [toggleButton setTitle:@"中" forState:UIControlStateNormal];
        }
        else if (model == kWebContentSize3)
        {
            [toggleButton setFrame:THREEFEAME];
            [toggleButton setTitle:@"大" forState:UIControlStateNormal];
        }
        else if (model == kWebContentSize4)
        {
            [toggleButton setFrame:FOURFEAME];
            [toggleButton setTitle:@"极大" forState:UIControlStateNormal];
        }
    }
    else if (_modelChange == IMAGE_MODEL){
        //
        ReaderPicMode picMode = [AppSettings integerForKey:IntKey_ReaderPicMode];
        if(picMode == ReaderPicOn)
        {
            [toggleButton setFrame:ONEFEAME];
            [toggleButton setTitle:@"自动" forState:UIControlStateNormal];
        }
        else if(picMode == ReaderPicOff)
        {
            [toggleButton setFrame:TOWFRMAME];
            [toggleButton setTitle:@"无图" forState:UIControlStateNormal];
        }
        else if(picMode == ReaderPicManually)
        {
            [toggleButton setFrame:THREEFEAME];
            [toggleButton setTitle:@"手动" forState:UIControlStateNormal];
        }
    }
    else if (_modelChange == NIGHT_MODEL){
        //
        BOOL night = [[ThemeMgr sharedInstance] isNightmode];
        if (night) {
            [toggleButton setFrame:TOWFRMAME];
            [toggleButton setTitle:@"开" forState:UIControlStateNormal];
        }
        else
        {
            [toggleButton setFrame:ONEFEAME];
            [toggleButton setTitle:@"关" forState:UIControlStateNormal];
        }
    }
    

}

-(void)setSwitchBorderWidth:(CGFloat)width
{
   [toggleButton.layer setBorderWidth:width];
}

- (void)setTextColor:(UIColor *)color
{
    labelOne.textColor=color;
    labelTwo.textColor=color;
    labelThree.textColor=color;
    labelFour.textColor=color;
    
}

- (void)setTextFont:(UIFont *)font
{
    if (font) {
        labelOne.font=font;
        labelTwo.font=font;
        labelThree.font=font;
        labelFour.font=font;
    }
}

- (void)setFrameBackgroundColor:(UIColor *)color
{
    labelOne.backgroundColor=color;
    labelTwo.backgroundColor=color;
    labelThree.backgroundColor=color;
    labelFour.backgroundColor=color;
    
}

- (void)setSwitchFrameColor:(UIColor *)color
{
    [toggleButton.layer setBorderColor:[color CGColor]];
    //toggleButton.alpha=0.1;
    //toggleButton.backgroundColor=color;
   
}

- (void)changeOneBt:(UIButton*)bt
{
    [bt setFrame:ONEFEAME];
    if (_modelChange == TEXT_MODEL) {
        [bt setTitle:@"小" forState:UIControlStateNormal];
    }
    else if (_modelChange == IMAGE_MODEL){
        [bt setTitle:@"自动" forState:UIControlStateNormal];
    }
    else if (_modelChange == NIGHT_MODEL){
        [bt setTitle:@"关" forState:UIControlStateNormal];
    }
    
    [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)changeTowBt:(UIButton*)bt
{
    [bt setFrame:TOWFRMAME];
    if (_modelChange == TEXT_MODEL) {
        [bt setTitle:@"中" forState:UIControlStateNormal];
    }
    else if (_modelChange == IMAGE_MODEL){
        [bt setTitle:@"无图" forState:UIControlStateNormal];
    }
    else if (_modelChange == NIGHT_MODEL){
        [bt setTitle:@"开" forState:UIControlStateNormal];
    }
    
    [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)changeThreeBt:(UIButton*)bt
{
    [bt setFrame:THREEFEAME];
    if (_modelChange == TEXT_MODEL) {
        [bt setTitle:@"大" forState:UIControlStateNormal];
    }
    else if (_modelChange == IMAGE_MODEL){
        [bt setTitle:@"手动" forState:UIControlStateNormal];
    }
    
    
    [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)changeFourBt:(UIButton*)bt
{
    [bt setFrame:FOURFEAME];
    [bt setTitle:@"极大" forState:UIControlStateNormal];
    [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)didTapLabelOneWithGesture:(UITapGestureRecognizer *)tapGesture {
    [self changeOneBt:toggleButton];
    [self.delegate slideView:self switchChangedAtIndex:0];
}

- (void)didTapLabelTwoWithGesture:(UITapGestureRecognizer *)tapGesture {
    [self changeTowBt:toggleButton];
    [self.delegate slideView:self switchChangedAtIndex:1];
}

- (void)didTapLabelThreeWithGesture:(UITapGestureRecognizer *)tapGesture {
    [self changeThreeBt:toggleButton];
    [self.delegate slideView:self switchChangedAtIndex:2];
}

- (void)didTapLabelFourWithGesture:(UITapGestureRecognizer *)tapGesture {
    [self changeFourBt:toggleButton];
    [self.delegate slideView:self switchChangedAtIndex:3];
}

- (void)setText:(NSString *)text forTextIndex:(NSInteger )number
{
    NSInteger labelnumber=number;
    
    if(labelnumber==1)
    {
        labelOne.text=text;
//        [self.delegate slideView:self switchChangedAtIndex:0];
    }
    if(labelnumber==2)
    {
        labelTwo.text=text;
    }
    if(labelnumber==3)
    {
        labelThree.text=text;
    }
    if(labelnumber==4)
    {
        labelFour.text=text;
    }
    
}


@end
