//
//  ContentShareView.m
//  SurfNewsHD
//
//  Created by jsg on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ContentShareView.h"
#import "ImageCacher.h"
#import "UIColor+extend.h"

@implementation ContentShareView

#define shareWordHeight   kContentHeight-313    //分享文本
#define linehHeight       kContentHeight-270-41   //线
#define shareFieldHeight  kContentHeight-260-43   //网络链接
#define labelHeight       kContentHeight-240-43   //输入字数
#define clearBtnHeight    kContentHeight-310-43   //清空按钮
#define scrollPhotoHeight kContentHeight-195-43-15   //分享图片

@synthesize m_mainScreen;

@synthesize m_shareWord;
@synthesize m_lineLabel;
@synthesize m_remainLab;
@synthesize m_shareAds;
@synthesize m_scrollPhotos;
@synthesize m_numOfPhotos;
@synthesize m_clearButton;
@synthesize m_shareImage;
@synthesize m_shareArray;
@synthesize m_shareStr;
@synthesize m_shareNewsAds;
@synthesize m_shareToWeibo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        
        //初始化控件
        [self initShareWord];
        [self initShareAds];
        [self initSharePhotos];
        
        [self addSubviews];

     }
    return self;
}
#pragma mark set()
- (void)setShareWordText:(NSString*)text{
    [self.m_shareWord setText:text];
}

- (void)setShareMode:(ShareMode)mode{
    self.m_shareToWeibo = mode;
}

- (void)setShareAds:(NSString*)ads{
    if (!ads) {
        return;
    }
    [self.m_shareAds setText:ads];
}

- (void)setShareNewsAds:(NSString*)newsAds{
    if (!newsAds) {
        return;
    }
    self.m_shareNewsAds = newsAds;
}

- (void)setShareStr:(NSString*)str{
    if (!str) {
        return;
    }
    self.m_shareStr = str;
}

- (void)setNumOfPhotos:(NSMutableArray*)photos{
    if(!photos){
        return;
    }
    self.m_numOfPhotos = photos;
}

- (void)setPic:(UIImage*)pic{
    if (!pic) {
        return;
    }
    self.m_shareImage = pic;
    
    ImageMutiButton *thumbnail = [[ImageMutiButton alloc] init];
    
    NSUInteger numColumns = 3;//列数
    
    NSUInteger numItems = 1;
    
    //padding
    CGFloat padding = roundf((kContentWidth-40 - (thumbnail.itemSize.width * numColumns)) / (numColumns + 1));
    NSUInteger numRows = numItems % numColumns == 0 ? (numItems / numColumns) : (numItems / numColumns) + 1;
    NSLog(@"padding:(%f)", padding);
    CGFloat totalHeight = ((thumbnail.itemSize.width + padding) * numRows) + padding;
    NSLog(@"totalHeight:(%f)", totalHeight);
    
    // get an even y padding if less than the max number of rows
    CGFloat yPadding = padding;
    if (totalHeight < thumbnail.itemSize.width) {
        CGFloat leftoverHeight = thumbnail.itemSize.width - totalHeight;
        CGFloat extraYPadding = roundf(leftoverHeight / (numRows + 1));
        yPadding += extraYPadding;
        
        totalHeight = ((thumbnail.itemSize.width + yPadding) * numRows) + yPadding;
    }
    
    for (NSInteger i = 0; i < numItems; i++) {
        
        NSUInteger column = i % numColumns;
        NSUInteger row = i / numColumns;
        
        CGFloat xOffset = (column * (thumbnail.itemSize.width + padding+3) + padding);
        CGFloat yOffset = (row * (thumbnail.itemSize.width + yPadding)) + yPadding;
        
        NSLog(@"offset:(%f,%f)", xOffset,yOffset);
    
        ImageMutiButton *thumbnailBtn = [[ImageMutiButton alloc] init];
        thumbnailBtn.m_selectDelegate = self;
        thumbnailBtn.tag = i+InitialTag;
        [thumbnailBtn setFrame:CGRectMake(xOffset, yOffset, thumbnail.itemSize.width+15, thumbnail.itemSize.width)];
        
        
        UIColor *color;
        if ([[ThemeMgr sharedInstance] isNightmode]) {
            color = [UIColor colorWithRed:60.0f/255.0f green:61.0f/255.0f blue:62.0f/255.0f alpha:1.0f];
        }
        else{
            color = [UIColor colorWithRed:246.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
        }
        
        [thumbnailBtn setupSubviews:i :YES :color];
        [thumbnailBtn addButton:i];
        
        UIImage *imageLocal=pic;
        CGSize origImageSize= [imageLocal size];
            //图片横向 纵向
            BOOL req = [self orientationImg:origImageSize.height :origImageSize.width];
            if (req) {
                //portrait
                NSLog(@"portrait");
                NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:imageLocal,@"path",thumbnailBtn.m_imgView,@"imageView",thumbnailBtn.m_selectBtn,@"button",nil];
                SEL cachePicSel = NSSelectorFromString(@"cachePic:");
                [NSThread detachNewThreadSelector:cachePicSel
                                         toTarget:[ImageCacher defaultCacher]
                                       withObject:dic];
            }
            else{
                //landscape orientation
                NSLog(@"landscape orientation");
                NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:imageLocal,@"path",thumbnailBtn.m_imgView,@"imageView",thumbnailBtn.m_selectBtn,@"button",nil];
                SEL cachePicSel = NSSelectorFromString(@"cachePic:");
                [NSThread detachNewThreadSelector:cachePicSel toTarget:[ImageCacher defaultCacher] withObject:dic];
            }
        
        [self.m_scrollPhotos addSubview:thumbnailBtn];
    }
    scrollPhotosHeight = totalHeight;
    self.m_scrollPhotos.contentSize = CGSizeMake(kContentWidth-40, totalHeight);
}

#pragma mark UITextView
- (void)initShareWord{

    self.m_shareWord = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, kContentWidth-19, shareWordHeight)];
    self.m_shareWord.textColor = [UIColor colorWithHexString:@"999292"];
    self.m_shareWord.font = [UIFont fontWithName:@"Arial" size:12.0];
    self.m_shareWord.text = @"Now is he time for all good developers to come to serve their country.";
    self.m_shareWord.delegate = self;
    self.m_shareWord.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:237.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
    self.m_shareWord.returnKeyType = UIReturnKeyDefault;
    self.m_shareWord.keyboardType = UIKeyboardTypeDefault;
    self.m_shareWord.scrollEnabled = YES;
    
    
    self.m_shareWord.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    //还可输入。。
    self.m_remainLab = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, labelHeight, 150, 17)];
    [self.m_remainLab setFont:[UIFont fontWithName:@"Arial-Bold" size:12.0]];
    self.m_remainLab.font = [UIFont systemFontOfSize:12];
    //[self.m_remainLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0]];
    [self.m_remainLab setBackgroundColor:[UIColor clearColor]];
    [self.m_remainLab setTextColor:[UIColor colorWithHexString:@"34393d"]];
    
    //清空按钮
    self.m_clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.m_clearButton.frame = CGRectMake(kContentWidth-75, clearBtnHeight, 55, 25);
    [self.m_clearButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.m_clearButton setBackgroundImage:[UIImage imageNamed:@"navBtnBG"] forState:UIControlStateHighlighted];
    [self.m_clearButton setTitle:@"清空" forState:UIControlStateNormal];
    self.m_clearButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:12.0];
    [self.m_clearButton setBackgroundColor:[UIColor whiteColor]];
    
    [self.m_clearButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.m_clearButton addTarget:self action:@selector(clearPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)remainlab:(NSString *)str{
    NSInteger length = 120 - [str length];
    [self.m_remainLab setText:[NSString stringWithFormat:@"还可输入 : %@字", @(length)]];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    //限制字数120字
    NSString *finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([finalString length] > 120)
    {
        return NO;
    }
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    //markedTextRange：用中文拼音输入法时，输入拼音，尚未选定具体字符时
    if (textView.markedTextRange == nil && [textView.text length] <= 120) {
        [self.m_remainLab setText:[NSString stringWithFormat:@"还可输入 : %@字", @(120 - [textView.text length])]];
        self.m_shareStr = textView.text;
    }
}

#pragma mark UITextField
- (void)initShareAds{
    
    self.m_lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, linehHeight, kContentWidth-19, 2.0f)];
    self.m_lineLabel.backgroundColor = [UIColor colorWithHexString:@"dcdbdb"];

    self.m_shareAds = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, shareFieldHeight, kContentWidth-19, 17)];
    [self.m_shareAds setBorderStyle:UITextBorderStyleNone];
    [self.m_shareAds setFont:[UIFont fontWithName:@"Arial" size:12.0]];
    self.m_shareAds.secureTextEntry = NO;
    self.m_shareAds.textColor = [UIColor colorWithHexString:@"999292"];
    self.m_shareAds.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:237.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
    self.m_shareAds.autocorrectionType = UITextAutocorrectionTypeNo;
    self.m_shareAds.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.m_shareAds.returnKeyType = UIReturnKeyDone;
    self.m_shareAds.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.m_shareAds.delegate = self;
    
}

-(IBAction) textFieldDone:(id) sender
{
    [self.m_shareAds resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"editKeyboardWillHide" object:nil];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([string isEqualToString:@"\n"])
    {
        return YES;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (m_shareAds == textField)
    {
        if ([toBeString length] > 120) {
            textField.text = [toBeString substringToIndex:120];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"超过最大120字数不能输入了" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}

#pragma mark UIScrollView
- (void)initSharePhotos{
    NSInteger row = [m_numOfPhotos count] / 3;
    self.m_scrollPhotos = [[UIScrollView alloc] initWithFrame:CGRectMake(10.0f,scrollPhotoHeight, kContentWidth-19, row*60+170) ];
    self.m_scrollPhotos.contentSize = CGSizeMake(kContentWidth-40, row*60+300);
    self.m_scrollPhotos.scrollEnabled = YES;
    self.m_scrollPhotos.bounces = YES;
    self.m_scrollPhotos.delegate = self;
    self.m_scrollPhotos.alwaysBounceVertical = YES;
    [self.m_scrollPhotos setBackgroundColor:[UIColor clearColor]];
    
    m_shareArray = [[NSMutableArray alloc] init];
    m_Array = [[NSMutableArray alloc] init];
    isRepeat = 0;

}

- (void)nightModeChange{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        [self.m_shareWord setBackgroundColor:[UIColor colorWithHexValue:0xFF242526]];
        [self.m_shareWord setTextColor:[UIColor whiteColor]];
        [self.m_shareAds setBackgroundColor:[UIColor colorWithHexValue:0xFF242526]];
        [self.m_shareAds setTextColor:[UIColor whiteColor]];
        [self.m_remainLab setTextColor:[UIColor whiteColor]];
        [self.m_clearButton setBackgroundColor:[UIColor colorWithHexString:@"2D2E2F"]];
        self.m_lineLabel.backgroundColor = [UIColor blackColor];
    } else {
        [self.m_shareWord setBackgroundColor:[UIColor colorWithRed:240.0f/255.0f green:237.0f/255.0f blue:239.0f/255.0f alpha:1.0f]];
        [self.m_shareWord setTextColor:[UIColor colorWithHexValue:0xFF999292]];
        [self.m_shareAds setBackgroundColor:[UIColor colorWithRed:240.0f/255.0f green:237.0f/255.0f blue:239.0f/255.0f alpha:1.0f]];
        [self.m_shareAds setTextColor:[UIColor colorWithHexValue:0xFF999292]];
        [self.m_remainLab setTextColor:[UIColor colorWithHexValue:0xFF999292]];
        [self.m_clearButton setBackgroundColor:[UIColor whiteColor]];
        self.m_lineLabel.backgroundColor = [UIColor colorWithHexString:@"dcdbdb"];
    }
}

- (void)reloadPhotosOnline{

    //Add ImageMutiButton
    //打印每个图片地址
    for (NSInteger num = 0; num < [m_numOfPhotos count]; num++) {
        
        NSLog(@"imgUrl is %@",[m_numOfPhotos objectAtIndex:num]);
    }
    
    ImageMutiButton *thumbnail = [[ImageMutiButton alloc] init];
    
    NSUInteger numColumns = 3;//列数
    
	NSUInteger numItems = [m_numOfPhotos count];
	
    //padding
    CGFloat padding = roundf((kContentWidth-40 - (thumbnail.itemSize.width * numColumns)) / (numColumns + 1));
	NSUInteger numRows = numItems % numColumns == 0 ? (numItems / numColumns) : (numItems / numColumns) + 1;
    NSLog(@"padding:(%f)", padding);
	CGFloat totalHeight = ((thumbnail.itemSize.width + padding) * numRows) + padding;
    NSLog(@"totalHeight:(%f)", totalHeight);
	
	// get an even y padding if less than the max number of rows
	CGFloat yPadding = padding;
	if (totalHeight < thumbnail.itemSize.width) {
		CGFloat leftoverHeight = thumbnail.itemSize.width - totalHeight;
		CGFloat extraYPadding = roundf(leftoverHeight / (numRows + 1));
		yPadding += extraYPadding;
		
		totalHeight = ((thumbnail.itemSize.width + yPadding) * numRows) + yPadding;
	}
	
	// get an even x padding if we have less than a single row of items
	if (numRows == 1 && numItems < numColumns) {
        switch (numColumns) {
            case 1:
                padding = 5;
                break;
            case 2:
                padding = roundf((kContentWidth-80 - (thumbnail.itemSize.width * numColumns)) / (numColumns + 1));
                break;
            default:
                break;
        }
	}
    
	
	for (NSInteger i = 0; i < numItems; i++) {
        
        NSUInteger column = i % numColumns;
		NSUInteger row = i / numColumns;
        
        CGFloat xOffset = (column * (thumbnail.itemSize.width + padding+3) + padding);
		CGFloat yOffset = (row * (thumbnail.itemSize.width + yPadding)) + yPadding;
        
        NSLog(@"offset:(%f,%f)", xOffset,yOffset);
        
        NSString *path = [m_numOfPhotos objectAtIndex:i];
        
        ImageMutiButton *thumbnailBtn = [[ImageMutiButton alloc] init];
        thumbnailBtn.m_selectDelegate = self;
        thumbnailBtn.tag = i+InitialTag;
        [thumbnailBtn setFrame:CGRectMake(xOffset, yOffset, thumbnail.itemSize.width+15, thumbnail.itemSize.width)];

        BOOL DownloadImg = NO;
        NSData *dataPath=[NSData dataWithContentsOfFile:path];
        if (!dataPath){
            DownloadImg = NO;
        }
        else{
            DownloadImg = YES;
        }
        
        UIColor *color;
        if ([[ThemeMgr sharedInstance] isNightmode]) {
            color = [UIColor colorWithRed:60.0f/255.0f green:61.0f/255.0f blue:62.0f/255.0f alpha:1.0f];
        }
        else{
            color = [UIColor colorWithRed:246.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
        }
        
        [thumbnailBtn setupSubviews:i :DownloadImg :color];
        [thumbnailBtn addButton:i];

        if (pathInDocumentDirectory(path)){
            NSData *data=[NSData dataWithContentsOfFile:path] ;
            UIImage *imageLocal=[UIImage imageWithData:data];
            CGSize origImageSize= [imageLocal size];
            //图片横向 纵向
            BOOL req = [self orientationImg:origImageSize.height :origImageSize.width];
            if (req) {
                //portrait
                NSLog(@"portrait");
                NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:path,@"path",thumbnailBtn.m_imgView,@"imageView",thumbnailBtn.m_selectBtn,@"button",nil];
                [NSThread detachNewThreadSelector:@selector(cacheImage:) toTarget:[ImageCacher defaultCacher] withObject:dic];
            }
            else{
                //landscape orientation
                NSLog(@"landscape orientation");
                NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:path,@"path",thumbnailBtn.m_imgView,@"imageView",thumbnailBtn.m_selectBtn,@"button",nil];
                [NSThread detachNewThreadSelector:@selector(cacheImage:) toTarget:[ImageCacher defaultCacher] withObject:dic];
            }
            
        }
        else{
            //把控件存入字典
            NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:path,@"path",thumbnailBtn.m_imgView,@"imageView",thumbnailBtn.m_selectBtn,@"button",nil];
            [NSThread detachNewThreadSelector:@selector(cacheImage:) toTarget:[ImageCacher defaultCacher] withObject:dic];

        }
        [self.m_scrollPhotos addSubview:thumbnailBtn];
	}
    scrollPhotosHeight = totalHeight;
    self.m_scrollPhotos.contentSize = CGSizeMake(kContentWidth-40, totalHeight);
    
}

- (BOOL)orientationImg:(CGFloat)height
                      :(CGFloat)width{
    BOOL orientation = height > width ? YES:NO;
    return orientation;
}

- (void)reloadPhotosOffline{
    [self reloadPhotosOnline];

}

- (void)addSubviews{
    
    //滑动背景
    self.m_mainScreen = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, kContentHeight)];
    self.m_mainScreen.contentSize = CGSizeMake(kContentWidth, kContentHeight+80);    [self addSubview:self.m_scrollPhotos];
    self.m_mainScreen.scrollEnabled = YES;
    self.m_mainScreen.bounces = YES;
    self.m_mainScreen.delegate = self;
    self.m_mainScreen.alwaysBounceVertical = YES;
    [self.m_mainScreen setBackgroundColor:[UIColor clearColor]];
    
    //加上控件
    [self.m_mainScreen addSubview:self.m_shareWord];
    [self.m_mainScreen addSubview:self.m_shareAds];
    [self.m_mainScreen addSubview:self.m_lineLabel];
    [self.m_mainScreen addSubview:self.m_scrollPhotos];
    [self.m_mainScreen addSubview:self.m_remainLab];
    [self.m_mainScreen addSubview:self.m_clearButton];
    
    [self addSubview:self.m_mainScreen];
    
}

- (void)DidSelectedMuti:(NSString*)index
               withBtn:(id)sender{
    
        NSUInteger didSeletedIndex = [sender tag];
        ImageMutiButton *Button = [self ImageViewWithIndex:didSeletedIndex];
    
        if (!Button.isPressed) {
            [self reloadAllImageMutiButton];
            seletedCount = 0;
            [Button.m_imgSelectView setImage:[UIImage imageNamed:@"dilog.png"]];
            Button.isSelected = YES;
            Button.isPressed = YES;
            
            seletedCount++;
            }
        else{
            [Button.m_imgSelectView setImage:[UIImage imageNamed:@"unDilog.png"]];
            Button.isSelected = NO;
            Button.isPressed = NO;
            
            seletedCount = 0;
        }
    
//        if ([m_Array containsObject:index]) {
//            //重复
//            return;
//        }
    
        if (seletedCount >= 2) {
            NSString *stringInt = [NSString stringWithFormat:@"最多只能选择一个图片分享"];
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提醒" message:stringInt delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alter show];
            
            [self reloadAllImageMutiButton];           
            NSUInteger index = [sender tag];
            ImageMutiButton *btn = [self ImageViewWithIndex:index];
            [btn.m_imgSelectView setImage:[UIImage imageNamed:@"dilog.png"]];
            btn.isPressed = YES;
            btn.isSelected = YES;
            seletedCount = 0;
        }
        else{
            [m_Array addObject:index];
        }

        [self ShareImgArray:[index intValue]];

}

-(ImageMutiButton *)ImageViewWithIndex:(NSUInteger)index
{
    ImageMutiButton *button = nil;
    for(ImageMutiButton *btn in self.m_scrollPhotos.subviews)
    {
        if([btn isKindOfClass:[ImageMutiButton class]])
        {
            if(btn.m_imgSelectView.tag == index ) {
                button = (ImageMutiButton *)btn;
                break;
            }
        }
    }
    return button;
}

- (void)reloadAllImageMutiButton{
    for(ImageMutiButton *btn in self.m_scrollPhotos.subviews)
    {
        if([btn isKindOfClass:[ImageMutiButton class]])
        {
           [btn.m_imgSelectView setImage:[UIImage imageNamed:@"unDilog.png"]];
            btn.isPressed = NO;
            btn.isSelected = NO;
        }
    }
}

- (void)ShareImgArray:(NSInteger)imgIndex
{
    NSString *path = [m_numOfPhotos objectAtIndex:imgIndex];
    if (!path) {
        [m_shareArray addObject:self.m_shareImage ];
        return;
    }
    if (pathInDocumentDirectory(path)){
        NSData *data=[NSData dataWithContentsOfFile:path] ;
        UIImage *imageShareLocal = [UIImage imageWithData:data];
        self.m_shareImage = imageShareLocal;
        [m_shareArray addObject:imageShareLocal];
    }
}

- (IBAction)clearPressed:(id)sender{
    self.m_shareWord.text = @"";
    [self.m_remainLab setText:[NSString stringWithFormat:@"还可输入 : %d字", 120]];
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
