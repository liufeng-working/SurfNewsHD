//
//  PhoneNewsView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneNewsView.h"
#import "PhoneNewsControl.h"
#import "PhoneNewsManager.h"
#import "NewsWebController.h"


@implementation PhoneNewsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self hiderNotDataView:NO];
        [[self notDataMsgLbl] setText:nil];       
        
        UIImage *img = [UIImage imageNamed:@"phoneNewsGuide"];
        CGRect imgRect = CGRectMake((kContentWidth - img.size.width) * 0.6,
                                    (kContentHeight - img.size.height) * 0.3,
                                    img.size.width, img.size.height);
        [[self notDataImageView] setImage:img];
        [[self notDataImageView] setFrame:imgRect];
        
        
        
        
        
        // 添加一个风火轮        
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_loadingView setBackgroundColor:[UIColor grayColor]];
        _loadingView.layer.cornerRadius = 6.0f;
        CGRect rect = CGRectMake(0.f, 0.f, 100.f, 100.f);
        rect.origin = CGPointMake((kContentWidth-CGRectGetWidth(rect)) * 0.5f,
                                  (kContentHeight-CGRectGetHeight(rect))*0.3f);
        [_loadingView setFrame:rect];
        [_loadingView hidesWhenStopped];
        [self addSubview:_loadingView];
        
        newsArray  = [NSMutableArray arrayWithCapacity:10];
        
        // 加载本地数据
        [self reloadDataWithArray:[[PhoneNewsManager sharedInstance] getLocalPhoneNew]]; // 加载本地数据
        
    }
    return self;
}


- (void)reloadDataWithArray:(NSArray*)phoneNews{
    
    [newsArray removeAllObjects];
    [newsArray addObjectsFromArray:phoneNews];
    [self updateContent];
}

- (void)updateContent{

    // 删除旧UIView
    for (UIView *view in [_scrollView subviews]) {
        if ([view isKindOfClass:[PhoneNewsDateView class]] ||
            [view isKindOfClass:[PhoneNewCtrl class]]) {
            [view removeFromSuperview];
        }
    }
    [self hiderNotDataView:newsArray.count?YES:NO];
   
    
    NSDate *date = nil;
    NSUInteger rowNum = 0;
    float dateAndFavLR = 30.f;
    float favLR = 40.f;
    float favTB = 70.f;
    CGPoint point = {0.f, 30.f};
    float dateViewWidth = [PhoneNewsDateView fitSize].width;
    float width = self.bounds.size.width;
    float ctrlHeight = [PhoneNewCtrl fitSize].height;
    float ctrlWidth = [PhoneNewCtrl fitSize].width;
    for (PhoneNewsData *newsData in newsArray) {
        if ([newsData isKindOfClass:[PhoneNewsData class]]) {
            BOOL isEqual = NO;
            if (date == nil) {
                date = [NSDate dateWithTimeIntervalSince1970:newsData.datetime/1000.f];
            }
            else{
                NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:newsData.datetime/1000.f];
                isEqual = [self equalDayDate:date date:date2];
                if (!isEqual) {
                    date = date2;
                }
            }
            
            if (!isEqual) {
                // 创建一个时间控件
                if (point.x + dateViewWidth > width || rowNum > 1) {
                    point.x = 0;
                    point.y += ctrlHeight + favTB;
                    rowNum = 0;
                }
                else if(rowNum == 1){
                    // 这个分支需要检测后面一个
                    int curIdx = [newsArray indexOfObject:newsData];
                    if (curIdx < [newsArray count] -1) {
                        PhoneNewsData *tempData = [newsArray objectAtIndex:curIdx + 1];
                        NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:tempData.datetime/1000.f];
                        if ([self equalDayDate:date date:date2]) {
                            // 是同一天的手机报
                            point.x = 0;
                            point.y += ctrlHeight + favTB;
                            rowNum = 0;                            
                        };
                    }
                }
            
                
                CGPoint datePoint = point;
                datePoint.y -= 5.f;
                PhoneNewsDateView *dateView = [[PhoneNewsDateView alloc] initWithPoint:datePoint];
                [dateView relaodDate:date];
                [_scrollView addSubview:dateView];
                point.x += dateViewWidth + dateAndFavLR;
                
            }
            
            ++rowNum;
            if (point.x + ctrlWidth > width ) {
                point.x = dateViewWidth + dateAndFavLR;
                point.y += ctrlHeight + favTB;
            }
            
            PhoneNewCtrl *newCtrl = [[PhoneNewCtrl alloc] initWithPoint:point];
            [newCtrl reloadDate:newsData];
            
            // 点击事件
            [newCtrl setClickEvent:^(id sender) {
                // 调转到newWep
                PhoneNewCtrl *ctrl = sender;
                if ([ctrl isKindOfClass:[PhoneNewCtrl class]]) {
                    [self handleClickEvent:ctrl];
                }
            }];
            // 删除事件
            [newCtrl setDeleteClickEvent:^(id sender) {
                PhoneNewCtrl *ctrl = sender;
                if ([ctrl isKindOfClass:[PhoneNewCtrl class]]) {
                    // 弹出确认提示框
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"手机报删除后将不在云端保存，确认删除？"
                                                                        message:@""
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定",nil];
                    alertView.tag = 100;
                    deleteNews = [ctrl phoneData];
                    [alertView show];
                }
            }];
            [_scrollView addSubview:newCtrl];
            point.x += ctrlWidth + favLR;
        }
    }

    
    if (point.y + ctrlHeight+ 20.f < CGRectGetHeight([self bounds])) {
        [_scrollView setContentSize:CGSizeMake(width, CGRectGetHeight([self bounds]))];
    }
    else{
        [_scrollView setContentSize:CGSizeMake(width, point.y + ctrlHeight+ 20.f)];
    }
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1 && alertView.tag == 100 ) {
        // 删除操作，
        if (deleteNews != nil) {        
            // 提交退订关系
            [self startLoading];
            [[PhoneNewsManager sharedInstance] cancelPhoneNewsFavs:deleteNews complete:^(BOOL result) {
                if (result) {
                    [newsArray removeObject:deleteNews];
                    [self updateContent];
                }
                else{
                    [SurfNotification surfNotification:@"手机报取消收藏失败！"];
                }
                [self stopLoading];
            }];
        }
    }
}

#pragma mark 处理点击世界
- (void)handleClickEvent:(PhoneNewCtrl*)ctrl{
    NewsWebController *news = [NewsWebController new];
    news.webStyle = NewsWebrStylePhoneNews;
    news.currentNewsData = [ctrl phoneData];
    news.title = @"手机报";
    [_controller pushViewController:news animated:NO];
}


#pragma mark UIActivityIndicatorView
- (void)startLoading{
    [_loadingView startAnimating];
    [self setUserInteractionEnabled:NO];

}

-(void)stopLoading{
    [_loadingView stopAnimating];
    [_loadingView setHidden:YES];
    [self setUserInteractionEnabled:YES];
}


@end
