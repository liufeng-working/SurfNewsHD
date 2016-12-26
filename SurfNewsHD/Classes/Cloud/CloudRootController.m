//
//  CloudRootController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CloudRootController.h"
#import "NewsWebController.h"
#import "PhoneNewAndFavsView.h"
#import "PopupLoginController.h"
#import "SurfAccountController.h"
#import "FavsManager.h"



@interface CloudRootController ()
@property(nonatomic,strong)UIButton *logoutOrSynBtn;    // 注销或同步按钮
@property(nonatomic,strong)PhoneNewAndFavsView *newsAndFavs;

// 标题
@property(nonatomic,strong)UIButton *phoneNewsBtn;
@property(nonatomic,strong)UIButton *favsBtn;
@property(nonatomic,strong)UIImageView *flagImgView;


@end

@implementation CloudRootController

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        self.titleState = ViewTitleStateNormal;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 登陆按钮呢
    float btnY = 40.f;
    float btnWidth = 65.f;
    float btnHeight = 25.f;

    
    // 注销或同步按钮
    CGRect btnRect = CGRectMake(kContentWidth-btnWidth, btnY, btnWidth, btnHeight);
    _logoutOrSynBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_logoutOrSynBtn setFrame:btnRect];    
    [self.view addSubview:_logoutOrSynBtn];
    

    NSString *title = @"云端手机报";
    UIFont *font = [UIFont boldSystemFontOfSize:20.f];
    _phoneNewsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_phoneNewsBtn setTitle:title forState:UIControlStateNormal];
    CGSize btnSize = [title sizeWithFont:font];
    [_phoneNewsBtn setFrame:CGRectMake(0.f, -btnSize.height, btnSize.width, btnSize.height)];
    [[_phoneNewsBtn titleLabel] setFont:font];
    [_phoneNewsBtn setHidden:YES];
    [self.view addSubview:_phoneNewsBtn];
    
    
    title = @"本地收藏";
    _favsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_favsBtn setTitle:title forState:UIControlStateNormal];    
    btnSize = [title sizeWithFont:font];
    [_favsBtn setFrame:CGRectMake(0.f, -btnSize.height, btnSize.width, btnSize.height)];
    [[_favsBtn titleLabel] setFont:font];
    [self.view addSubview:_favsBtn];


    _flagImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dwnArrow"]];
    [_flagImgView setFrame:CGRectMake(10, 41.f, 10.f, 4.f)];
    [_flagImgView setHidden:YES];
    [self.view addSubview:_flagImgView];

    
    CGRect rect = CGRectMake(0.0f, kPaperTopY, kContentWidth, kContentHeight - kPaperTopY - kPaperBottomY);
    _newsAndFavs = [[PhoneNewAndFavsView alloc] initWithFrame:rect];
    [_newsAndFavs setController:self];
    [_newsAndFavs indexChanger:^(NSInteger idx) {
        [self checkTitleState]; 
    }];
    [self.view addSubview:_newsAndFavs];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager addUserLoginObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
    [_newsAndFavs refreshDate];
    [self checkTitleState];                 // 检测标题状态
    [self checkLogoutOrSynButtonState];     // 设置按钮状态
    
    // 添加事件
    [_logoutOrSynBtn addTarget:self action:@selector(logoutOrSynButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager addUserLoginObserver:self];  

    
    [_favsBtn addTarget:self action:@selector(favsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_phoneNewsBtn addTarget:self action:@selector(phoneNewsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    // 移除事件
    [_logoutOrSynBtn removeTarget:self action:@selector(logoutOrSynButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    UserManager *manager = [UserManager sharedInstance];
    [manager removeUserLoginObserver:self];
    
    [_favsBtn removeTarget:self action:@selector(favsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_phoneNewsBtn removeTarget:self action:@selector(phoneNewsButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark logoutOrSyn button 
- (void)logoutOrSynButtonEvent:(UIButton*)button{
    // TODO弹出浮动登陆框    
    if ([self isLogin]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否确认退出账户"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
        alertView.tag = 100;
        [alertView show];
    }
    else{
        PopupLoginController *controller = [PopupLoginController sharedInstance];
        [controller addLoginViewToSuperView];
    }    
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 100) {
        [SurfAccountController logoutAccount:nil];
    }
}

- (void)checkLogoutOrSynButtonState{
    UIImage *btnImage = nil;
    if (![self isLogin]) { // 没有登陆状态
        btnImage = [UIImage imageNamed:@"synBtn"];
    }
    else{
         btnImage = [UIImage imageNamed:@"logoutBtn"];
    }
    [_logoutOrSynBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
}

// 检测标题状态
- (void)checkTitleState{
    
    float bY = 38.f;
    NSInteger heightlightColorValue = 0xFF3c3c3c;
    if ([self isLogin]) {
        float gap = 10.f;       
        NSInteger colorValue = 0xFF9d9696;
        CGSize phoneNewBtnSize = [_phoneNewsBtn bounds].size;
        CGSize favsBtnSize = [_favsBtn bounds].size;
        float width = phoneNewBtnSize.width + favsBtnSize.width + gap;
        float flagWidth = [_flagImgView bounds].size.width;
        float flagHeight = [_flagImgView bounds].size.height;
        
        CGRect rect = CGRectZero;
        rect.origin.x = (kContentWidth - width) * 0.5f;
        rect.origin.y = bY;
        rect.size = phoneNewBtnSize;
        [_phoneNewsBtn setHidden:NO];
        [_phoneNewsBtn setFrame:rect];
        
        
        rect.origin.x += gap + rect.size.width;
        rect.size = favsBtnSize;
        [_favsBtn setFrame:rect];
        [_flagImgView setHidden:NO];
        
        NSInteger index = _newsAndFavs.index;
        if (index == 0) {
            [_phoneNewsBtn setTitleColor:[UIColor colorWithHexValue:heightlightColorValue] forState:UIControlStateNormal];
            [_favsBtn setTitleColor:[UIColor colorWithHexValue:colorValue] forState:UIControlStateNormal];
            
            CGRect flagRect = [_phoneNewsBtn frame];
            flagRect.origin.x += (phoneNewBtnSize.width - flagWidth)*0.5f;
            flagRect.origin.y += CGRectGetHeight(flagRect);
            flagRect.size.width = flagWidth;
            flagRect.size.height = flagHeight;
            [_flagImgView setFrame:flagRect];
          
        }
        else if(index == 1){
            [_phoneNewsBtn setTitleColor:[UIColor colorWithHexValue:colorValue] forState:UIControlStateNormal];
            [_favsBtn setTitleColor:[UIColor colorWithHexValue:heightlightColorValue] forState:UIControlStateNormal];
            
            CGRect flagRect = [_favsBtn frame];
            flagRect.origin.x += (flagRect.size.width - flagWidth) * 0.5f;
            flagRect.origin.y += CGRectGetHeight(flagRect);
            flagRect.size.width = flagWidth;
            flagRect.size.height = flagHeight;
            [_flagImgView setFrame:flagRect];
        }
    }
    else{
        [_phoneNewsBtn setHidden:YES];
        [_flagImgView setHidden:YES];
        [_favsBtn setTitleColor:[UIColor colorWithHexValue:heightlightColorValue] forState:UIControlStateNormal];
        
        CGRect rect = [_favsBtn bounds];
        rect.origin.x = (kContentWidth - rect.size.width) * 0.5f;
        rect.origin.y = bY;
        [_favsBtn setFrame:rect];
    }
}

- (BOOL)isLogin{
    return ([[UserManager sharedInstance] loginedUser] == nil) ? NO : YES;
}

#pragma mark UserManagerObserver
- (void)currentUserLoginChanged
{
    [_newsAndFavs refreshDate];
    [self checkTitleState];                 // 检测标题状态
    [self checkLogoutOrSynButtonState];     // 设置按钮状态
}

// 文章按钮点击事件
-(void)favsButtonClick{
    if (![_phoneNewsBtn isHidden]) {
        [_newsAndFavs changeToFavsView];
    }
}
- (void)phoneNewsButtonClick{
    [_newsAndFavs changeToPhoneNewView];
}


@end
