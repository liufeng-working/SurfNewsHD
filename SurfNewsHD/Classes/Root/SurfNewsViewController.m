//
//  SurfNewsViewController.m
//  SurfNewsHD
//
//  Created by apple on 12-11-27.
//  Copyright (c) 2012年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"

@interface SurfNewsViewController ()

@end

@implementation SurfNewsViewController
@synthesize titleState;
- (id)init
{
    self = [super init];
    if (self) {
        _StateBarHeight = 60.f;
        self.titleState = ViewTitleStateNormal;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    /*
    self.navigationItem.titleView = nil;
    
    //set navBarBackground
#ifdef __IPHONE_5_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"titlebg"] forBarMetrics:UIBarMetricsDefault];
    }
#endif
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5)
    {
       	UIImage *barImage = [UIImage imageNamed:[NSString stringWithFormat:@"titlebg"]];
        self.navigationController.navigationBar.layer.contents = (id)barImage.CGImage;
    }
     */
#ifdef ipad
    if (self.titleState != ViewTitleStateNone)
    {
    
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paper_bg.png"]];
        imageView.frame = CGRectMake(0.0f, 0.0f, 900, 748);
        [self.view addSubview:imageView];
        
        surfTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 30.0f, kContentWidth, 38.0f)];
        surfTitlelabel.backgroundColor = [UIColor clearColor];
        surfTitlelabel.font = [UIFont boldSystemFontOfSize:24.0f];
        surfTitlelabel.textAlignment = UITextAlignmentCenter;
        surfTitlelabel.textColor = [UIColor hexChangeFloat:@"3C3C3C"];
        surfTitlelabel.text = self.title;
        [self.view addSubview:surfTitlelabel];

        UIView *titleLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 68.0f, kContentWidth, 5)];
        titleLineView.backgroundColor = [UIColor colorWithPatternImage:
                                         [UIImage imageNamed:@"hotchannel_divide_line"]];
        [self.view addSubview:titleLineView];

        
        if (self.titleState == ViewTitleStateNormal)
        {
/*
            UIView *titleLineTopView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 39.0f, kContentWidth, 2)];
            titleLineTopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hotchannel_item_border"]];
            [self.view addSubview:titleLineTopView];            
 */
        }
        else if (self.titleState == ViewTitleStateSpecial)
        {
            titleLineView.frame = CGRectMake(0.0f, 39.0f, kContentWidth, 5);
        }
    }
#else
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    surfTitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, .0f, kContentWidth, _StateBarHeight - 3 )];
    surfTitlelabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [surfTitlelabel setTextAlignment:NSTextAlignmentLeft];
    surfTitlelabel.textColor = [UIColor colorWithHexValue:0xFF3C3C3C];
    surfTitlelabel.text = self.title;
    [self.view addSubview:surfTitlelabel];
    
    
    // 分割线
    float lineHeight = 3.5f;
    CGRect lineRect = CGRectMake(0.f, _StateBarHeight - lineHeight, kContentWidth, lineHeight);
    UIView *lineView = [[UIView alloc] initWithFrame:lineRect];
    [lineView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:lineView];
#endif
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef ipad
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
#else
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
#endif

}
-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    surfTitlelabel.text = title;    
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
#ifdef ipad
    if (animated)
    {
        CATransition *t = [CATransition animation];
        t.subtype = kCATransitionFromRight;
        t.type = @"pageCurl";
        t.duration = 0.5f;
        [self.navigationController.view.layer addAnimation:t forKey:@"Transition"];
    }
    [self.navigationController pushViewController:viewController animated:NO];
#else
    
    
//    [self.tabBarController presentModalViewController:viewController animated:animated];
    [self.tabBarController presentViewController:viewController animated:animated completion:nil];
#endif

}
-(void)popViewControllerAnimated:(BOOL)animated
{
#ifdef ipad
    if (animated)
    {
        CATransition *t = [CATransition animation];
        t.subtype = kCATransitionFromRight;
        t.type = @"pageUnCurl";
        t.duration = 0.5f;
        [self.navigationController.view.layer addAnimation:t forKey:@"Transition"];
    }
    [self.navigationController popViewControllerAnimated:NO];
#else
    
    
//    [self dismissModalViewControllerAnimated:animated];
    [self dismissViewControllerAnimated:animated completion:nil];
#endif
}
@end
