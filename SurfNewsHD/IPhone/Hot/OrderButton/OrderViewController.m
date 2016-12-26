//
//  OrderViewController.m
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import "OrderViewController.h"
#import "TouchViewModel.h"
#import "TouchView.h"
#import "HotChannelsListResponse.h"
#import "HotChannelsManager.h"

@interface OrderViewController()
{
    UIImageView * _arrowImage;    //箭头图片
    UIButton * _finishBtn;        //完成按钮
}

@end

@implementation OrderViewController

- (void)dealloc
{
    [_arrowImage release];_arrowImage = nil;
    [_finishBtn release]; _finishBtn  = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.isEditButton = NO;
    
    
    HotChannelsManager *manager = [HotChannelsManager sharedInstance];
    _modelArr1 = manager.visibleHotChannels;
    NSArray * modelArr2 = manager.invisibleHotChannels;
    _viewArr1 = [[NSMutableArray alloc] init];
    _viewArr2 = [[NSMutableArray alloc] init];
    
    
    
    
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    _titleLabel.text = @"所有频道";
    _titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setTextColor:[UIColor colorWithHexString:@"d71919"]];
    [self.view addSubview:_titleLabel];
    
    UILabel* label = [[UILabel alloc]init];
    label.frame = CGRectMake(80, 0, 160, 40);
    label.textColor = [UIColor colorWithHexString:@"999999"];
    label.font = [UIFont systemFontOfSize:10.0f];
    label.text = @"长按并拖动编辑频道位置或删减";
    [self.view addSubview:label];
    [label release];
    
    
    _titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, KTableStartPointY + (KButtonHeight) * ([self array2StartY] - 1) , 80, 30)];
    _titleLabel2.text = @"更多频道";
    [_titleLabel2 setFont:[UIFont systemFontOfSize:15.0f]];
    [_titleLabel2 setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel2 setTextColor:[UIColor colorWithHexString:@"666666"]];
    [self.view addSubview:_titleLabel2];
    
    
    for (int i = 0; i < _modelArr1.count; i++) {
        TouchView * touchView = [[TouchView alloc] initWithFrame:CGRectMake(KTableStartPointX + (KButtonWidth)* (i%5), KTableStartPointY + (KButtonHeight) * (i/5), KButtonWidth-5, KButtonHeight-5)];
        touchView.tag = 100+i;
        //选中的频道，特殊显示
        [touchView selectChannelWithIndex:i];
        
        UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPressTap:)];
        [touchView addGestureRecognizer:recognizer];
        
        [_viewArr1 addObject:touchView];
        [touchView release];
        touchView->_array = _viewArr1;
        
        HotChannel* hc = [_modelArr1 objectAtIndex:i];
        touchView.label.text = hc.channelName;
        touchView.label.font = [UIFont systemFontOfSize:14.0f];
        [touchView.label setTextAlignment:NSTextAlignmentCenter];
        [touchView setMoreChannelsLabel:_titleLabel2];
        touchView->_viewArr11 = _viewArr1;
        touchView->_viewArr22 = _viewArr2;
        [touchView setTouchViewModel:[_modelArr1 objectAtIndex:i]];
        
        [self.view addSubview:touchView];
        
        //如果是新增频道，添加个红点
        [touchView setItemIsNew:hc];
    }
    
    for (int i = 0; i < modelArr2.count; i++) {
        TouchView * touchView = [[TouchView alloc] initWithFrame:CGRectMake(KTableStartPointX + (KButtonWidth) * (i%5), KTableStartPointY + [self array2StartY] * (KButtonHeight) + (KButtonHeight) * (i/5), KButtonWidth-5, KButtonHeight-5)];
        
        touchView.tag = 1000+i;
        
        UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPressTap:)];
        [touchView addGestureRecognizer:recognizer];
        
        [touchView.label setTextColor:[UIColor colorWithHexString:@"666666"]];
        touchView.label.font = [UIFont systemFontOfSize:14.0f];
        [_viewArr2 addObject:touchView];
        touchView->_array = _viewArr2;
        
        HotChannel* hc = [modelArr2 objectAtIndex:i];
        touchView.label.text = hc.channelName;
        [touchView.label setTextAlignment:NSTextAlignmentCenter];
        [touchView setMoreChannelsLabel:_titleLabel2];
        touchView->_viewArr11 = _viewArr1;
        touchView->_viewArr22 = _viewArr2;
        [touchView setTouchViewModel:[modelArr2 objectAtIndex:i]];
        
        [self.view addSubview:touchView];
        
        [touchView release];
        
        //如果是新增频道，添加个红点
        [touchView setItemIsNew:hc];
    }
    
    _arrowImage = [[UIImageView alloc]init];
    [_arrowImage setFrame:CGRectMake(self.view.bounds.size.width - 25, 17, 12, 6)];
    _arrowImage.image = [UIImage imageNamed:@"order_back.png"];
    [self.view addSubview:_arrowImage];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(0, 0, 320, 40)];
    [self.view addSubview:self.backButton];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
}

/**
 *  长按处理
 *
 *  @param recognizer
 */
-(void)LongPressTap:(UILongPressGestureRecognizer*)recognizer
{
    //处理长按操作
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        //创建完成按钮
        [self creatFinishButton];
        //隐藏箭头
        _arrowImage.hidden = YES;
        //改变编辑状态
        self.isEditButton = !self.isEditButton;
        //改变频道的显示状态
        [self changeTouchViewStatus];
/*
        TouchView* touchView = (TouchView*)recognizer.view;
        if (touchView.frame.origin.y>self.titleLabel2.frame.origin.y)
        {
            NSLog(@"点击的是下面的");
            for (UIView* view in [self.view subviews]) {
                
                if (view.class == [TouchView class])
                {
                    TouchView* view1 = (TouchView*)view;
                    if (view1.frame.origin.y<self.titleLabel2.frame.origin.y)
                    {
                        if (self.isEditButton)
                        {
                            if ([view1.label.text isEqualToString:@"热推"])
                            {
                                view1.editeState = NO;
                            }
                            else
                            {
                                 view1.editeState = YES;
                            }
                       }
                       else
                       {
                            view1.editeState = NO;
                       }
                    }
                    view1.myY = self.titleLabel2.frame.origin.y;
                    [view1 changeEdit:self.isEditButton];
                }
            }
        }
        else
        {
            NSLog(@"点击的是上面的");
            self.isEditButton = !self.isEditButton;
            for (UIView* view in [self.view subviews]) {
                
                if (view.class == [TouchView class])
                {
                    TouchView* view1 = (TouchView*)view;
                    if (view1.frame.origin.y<self.titleLabel2.frame.origin.y)
                    {
                        if (self.isEditButton)
                        {
                            if ([view1.label.text isEqualToString:@"热推"])
                            {
                                view1.editeState = NO;
                            }
                            else
                            {
                                view1.editeState = YES;
                            }
                        }
                        else
                        {
                            view1.editeState = NO;
                        }
                    }
                    view1.myY = self.titleLabel2.frame.origin.y;
                    [view1 changeEdit:self.isEditButton];
                }
            }
        }
*/
        NSLog(@"长按了");
    }
}

-(void)creatFinishButton
{
    if (!_finishBtn) {
        _finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 30 - 10, 0, 30, 40)];
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_finishBtn setTitleColor:[UIColor colorWithHexString:@"d71919"] forState:UIControlStateNormal];
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_finishBtn addTarget:self action:@selector(finishBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_finishBtn];
    }else{
        _finishBtn.hidden = NO;
    }
}

-(void)finishBtnClick
{
    self.isEditButton = NO;
    [self changeTouchViewStatus];
}

-(void)changeTouchViewStatus
{
    for (UIView* view in [self.view subviews]) {
        if (view.class == [TouchView class])
        {
            TouchView* view1 = (TouchView*)view;
            if (view1.frame.origin.y<self.titleLabel2.frame.origin.y)
            {
                if (self.isEditButton)
                {
                    if ([view1.label.text isEqualToString:@"热推"])
                    {
                        view1.editeState = NO;
                    }
                    else
                    {
                        view1.editeState = YES;
                    }
                    self.backButton.enabled = NO; //禁止返回按钮的点击时间
                }
                else
                {
                    _finishBtn.hidden = YES;
                    _arrowImage.hidden = NO;
                    self.backButton.enabled = YES; //完成修改才可以返回
                    view1.editeState = NO;
                }
            }
            view1.myY = self.titleLabel2.frame.origin.y;
            [view1 changeEdit:self.isEditButton];
        }
    }
}

- (unsigned long )array2StartY{
    unsigned long y = 0;

    y = _modelArr1.count/5 + 2;
    if (_modelArr1.count%5 == 0) {
        y -= 1;
    }
    return y;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
