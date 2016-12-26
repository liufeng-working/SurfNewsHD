//
//  WebDesPeriodicalController.m
//  SurfNewsHD
//
//  Created by apple on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "WebDesPeriodicalController.h"
#import "AppSettings.h"
#import "PathUtil.h"


@interface WebDesPeriodicalController ()

@property(nonatomic,strong) NSMutableArray* hrefArr;
@property(nonatomic) NSInteger currentIndex;

@end

@implementation WebDesPeriodicalController
@synthesize hrefArr;
@synthesize currentIndex;

-(id)initWithPeriodicalLinks:(NSArray*)links
              andActiveIndex:(NSInteger)idx
{
    self = [super init];
    if (!self) return (nil);
    
    
    currentIndex = idx;
    self.titleState = PhoneSurfControllerStateTop;
    hrefArr = [NSMutableArray arrayWithArray:links];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    float width = CGRectGetWidth(self.view.frame);
    float height = CGRectGetHeight(self.view.frame);

    scrollView = [[PeriodicalScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height-4)];
    scrollView.scrollViewDelegate= self;
    [self.view addSubview:scrollView];    
    
    UIButton *sizeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sizeBtn.frame = CGRectMake(4*64.0f,0.0f, 64.0f, 49.0f);
    [sizeBtn setBackgroundImage:[UIImage imageNamed:@"moreBar.png"] forState:UIControlStateNormal];
    [sizeBtn addTarget:self action:@selector(sizeSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    indexLabel = [[UILabel alloc] initWithFrame:CGRectMake((width - 100.0f) / 2, 0.0f, 100.0f, 47.0f)];
    indexLabel.backgroundColor = [UIColor clearColor];
    indexLabel.textColor = [[ThemeMgr sharedInstance] isNightmode] ? [UIColor whiteColor] : [UIColor grayColor];
    [indexLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    settingBar = [[PhoneSettingBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    settingBar.hidden = YES;
    settingBar.delegate = self;
    [self.view addSubview:settingBar];
    
    UIView *toolsBar = [self addBottomToolsBar];
    [toolsBar addSubview:sizeBtn];
    [toolsBar addSubview:indexLabel];
    scrollView.toolsBar = toolsBar;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [scrollView reloadScrollView];
}
#pragma mark - PhoneSettingBarDelegate
-(void)settingFontSize:(float)size
{
    PeriodicalWebView *currentScrollWeb = [scrollView currentScrollWeb];
    [AppSettings setFloat:size forKey:FLOATKEY_ReaderBodyFontSize];
    NSString *js = [NSString stringWithFormat:@"setArticleFontSize(%f)",size];
    [currentScrollWeb stringByEvaluatingJavaScriptFromString:js];
    
    
    PeriodicalWebView *leftScrollWeb =  [scrollView leftScrollWeb];
    if (leftScrollWeb ) {
        [leftScrollWeb stringByEvaluatingJavaScriptFromString:js];
    }
    
    PeriodicalWebView *rightScrollWeb =  [scrollView rightScrollWeb];
    if (rightScrollWeb) {
        [rightScrollWeb stringByEvaluatingJavaScriptFromString:js];
    }
}

-(void)hiddenSettingBar
{
    [settingBar showSettingBar:NO isAnimate:YES completion:^(BOOL finished) {
        settingBar.hidden = YES;
    }];
}
-(void)sizeSettingClicked:(id)sender
{
    if (!settingBar.isHidden) {
        [self hiddenSettingBar];
    }
    else {
        [settingBar setHidden:NO];
        [settingBar showSettingBar:YES isAnimate:YES completion:nil];
    }
}

#pragma mark - NightModeChangedDelegate
-(void) nightModeChanged:(BOOL) night
{
    [super nightModeChanged:night];
    
    NSString *js =[NSString stringWithFormat:@"document.getElementById('CustomCSS').href=\"file://%@\"",[PathUtil pathOfResourceNamed:night?@"mag_article_n.css":@"mag_article_d.css" ]];
    
    
    PeriodicalWebView *currentScrollWeb = [scrollView currentScrollWeb];
    [currentScrollWeb stringByEvaluatingJavaScriptFromString:js];
    
    
    PeriodicalWebView *leftScrollWeb =  [scrollView leftScrollWeb];
    if (leftScrollWeb ) {
        [leftScrollWeb stringByEvaluatingJavaScriptFromString:js];
    }
    
    PeriodicalWebView *rightScrollWeb =  [scrollView rightScrollWeb];
    if (rightScrollWeb) {
        [rightScrollWeb stringByEvaluatingJavaScriptFromString:js];
    }

    //by Jerry
    if (IOS7) {
        if (!statusBarBgView) {
            statusBarBgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        }
        
        if (![self.view.subviews containsObject:statusBarBgView]) {
            [self.view addSubview:statusBarBgView];
        }
        
        if (night) {
            [statusBarBgView setBackgroundColor:[UIColor blackColor]];
        }
        else{
            [statusBarBgView setBackgroundColor:[UIColor whiteColor]];
        }
    }
}
#pragma mark - PeriodicalScrollViewDelegate
-(NSArray *)getThreadArr
{
    return hrefArr;
}
-(NSInteger)currentScrollPage
{
    return currentIndex;
}
-(void)reloadNewsScrollView
{
    if ([hrefArr count]<=0) {
        DJLog(@"error threadArr count is 0");
        return;
    }

    if (currentIndex == NSNotFound)
    {
        currentIndex = 0;
    }
    
    PeriodicalWebView *currentScrollWeb =  [scrollView currentScrollWeb];
    [currentScrollWeb hrefReloadWeb:[hrefArr objectAtIndex:currentIndex]];
    
    PeriodicalWebView *leftScrollWeb =  [scrollView leftScrollWeb];
    if (leftScrollWeb && currentIndex > 0) {
        [leftScrollWeb hrefReloadWeb:[hrefArr objectAtIndex:currentIndex-1]];

    }
    
    PeriodicalWebView *rightScrollWeb =  [scrollView rightScrollWeb];
    if (rightScrollWeb) {
        [rightScrollWeb hrefReloadWeb:[hrefArr objectAtIndex:currentIndex+1]];

    }
    
    indexLabel.text = [NSString stringWithFormat:@"%@ / %@", @(currentIndex + 1), @(hrefArr.count)];
}
-(void)pageMoveToLeft
{
    if (currentIndex == NSNotFound)
    {
        currentIndex = 0;
    }
    currentIndex --;
    if (currentIndex <0) {
        currentIndex = 0;
    }
    [self reloadNewsScrollView];
}
-(void)pageMoveToRight
{
    if (currentIndex == NSNotFound)
    {
        currentIndex = 0;
    }
    currentIndex ++;
    [self reloadNewsScrollView];
}
-(void)dismissModalViewController
{
    [self clearWebview];
    [self dismissControllerAnimated:PresentAnimatedStateNone];
}
- (void)dismissBackController
{
    if (!settingBar.hidden) {
        [self hiddenSettingBar];
        return;
    }
    [self clearWebview];
    [super dismissBackController];
}
-(void)clearWebview
{
    for(UIView *v in scrollView.scrollView.subviews)
    {
        if([v isKindOfClass:[PeriodicalWebView class]])
        {
            PeriodicalWebView *web = (PeriodicalWebView *)v;
            [web webWillDealloc];
        }
    }
}
@end
