//
//  FavsListView.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "FavsListView.h"
#import "PhoneNewsControl.h"
#import "FavsManager.h"
#import "NewsWebController.h"



////////////////////////////////////////////////////////////
@interface FavsListView ()
@property(nonatomic,strong) NSMutableArray *favsArray;
@property(nonatomic,weak)FavsThreadCtrl *tempDeleteObject;// 临时对象
@end


@implementation FavsListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    
        _favsArray = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

//- (void)reloadDataWithFavsArray:(NSArray*)favs{
//    
//    [_favsArray removeAllObjects];
//    [_favsArray addObjectsFromArray:favs];
//}


-(void)refreshView{
    
    // 初始化收藏数据
    [_favsArray removeAllObjects];
    FavsManager *manager = [FavsManager sharedInstance];
    NSInteger count =  [manager threadsCount];
    if (count != 0)
    {
        [self hiderNotDataView:YES];
        [_favsArray addObjectsFromArray:[manager fetchThreadsWithRange:NSMakeRange(0, count)]];
    }
    else{
        [self hiderNotDataView:NO];
    }
    
    
    
    // 删除旧UIView
    for (UIView *view in [_scrollView subviews]) {
        if ([view isKindOfClass:[PhoneNewsDateView class]] ||
            [view isKindOfClass:[FavsThreadCtrl class]]) {
            [view removeFromSuperview];
        }
    }
    
    
    NSDate *date = nil;
    NSUInteger rowNum = 0;
    float dateAndFavLR = 30.f;
    float favLR = 40.f;
    float favTB = 70.f;
    CGPoint point = {0.f, 30.f};
    float dateViewWidth = [PhoneNewsDateView fitSize].width;
    float width = self.bounds.size.width;
    float ctrlHeight = [FavsThreadCtrl fitSize].height;
    float ctrlWidth = [FavsThreadCtrl fitSize].width;
    for (FavThreadSummary *favTS in _favsArray) {
        if ([favTS isKindOfClass:[FavThreadSummary class]]) {
            BOOL isEqual = NO;
            if (date == nil) {
                date = [NSDate dateWithTimeIntervalSince1970:favTS.creationDate/1000.f];
            }
            else{
                NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:favTS.creationDate/1000.f];
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
                    NSInteger curIdx = [_favsArray indexOfObject:favTS];
                    if (curIdx < [_favsArray count] -1) {
                        FavThreadSummary *tempData = [_favsArray objectAtIndex:curIdx + 1];
                        NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:tempData.creationDate/1000.f];
                        if ([self equalDayDate:date date:date2]) {
                            // 是同一天收藏
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
            
            FavsThreadCtrl *favsView = [[FavsThreadCtrl alloc] initWithPoint:point];
            [favsView reloadDate:favTS];
            
            // 点击事件
            [favsView setClickEvent:^(id sender) {
                // 调转到newWep
                FavsThreadCtrl *ctrl = sender;
                if ([ctrl isKindOfClass:[FavsThreadCtrl class]]) {
                    if (_controller) {
                        NewsWebController *news = [NewsWebController new];
                        news.currentThread = [ctrl favTS];
                        news.webStyle = NewsWebrStyleFav;
                        [news.channels addObjectsFromArray:_favsArray];
                        news.title = @"收藏－文章";                        
                        [_controller pushViewController:news animated:NO];
                    }
                }
            }];
            // 删除事件
            [favsView setDeleteClickEvent:^(id sender) {
                FavsThreadCtrl *ctrl = sender;                
                if ([ctrl isKindOfClass:[FavsThreadCtrl class]]) {
                    // 弹出确认提示框
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否确认删除"
                                                                        message:@""
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定",nil];
                    alertView.tag = 100;
                    _tempDeleteObject = ctrl;
                    [alertView show];
                }
            }];
            [_scrollView addSubview:favsView];            
            point.x += ctrlWidth + favLR;
        }
    }
    
    // 设置ScrollView的内容大小
    if (point.y + ctrlHeight+ 20.f < CGRectGetHeight([self bounds])) {
        [_scrollView setContentSize:CGSizeMake(width, CGRectGetHeight([self bounds]))];
    }
    else{
        [_scrollView setContentSize:CGSizeMake(width, point.y + ctrlHeight+ 20.f)];
    }
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 100 && _tempDeleteObject != nil) {
        [_tempDeleteObject removeFromSuperview];
        [[FavsManager sharedInstance] removeFav:[_tempDeleteObject favTS]];
        _tempDeleteObject = nil;
        [self refreshView];  
    }
}

@end
