//
//  OrderViewController.h
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"Header.h"

//@protocol TouchViewDelegate <NSObject>
//
//-(void)changeEdit:(BOOL)flage;
//
//@end

@interface OrderViewController : UIViewController
{
    @public
    NSArray * _modelArr1;
    
    
}

@property (nonatomic,retain)UILabel * titleLabel;
@property (nonatomic,retain)UILabel * titleLabel2;
@property (nonatomic,retain)NSArray * titleArr;

@property (nonatomic,retain)NSArray * urlStringArr;
@property (nonatomic,retain)UIButton * backButton;

@property (nonatomic,retain)NSMutableArray * viewArr1;
@property (nonatomic,retain)NSMutableArray * viewArr2;


@property(nonatomic,assign)BOOL isEditButton;//是否编辑
//@property(nonatomic,assign)id<TouchViewDelegate> delegate;
@end
