//
//  SNVoteTableCell.h
//  SurfNewsHD
//
//  Created by XuXg on 15/10/28.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNNewsContentInfoResponse.h"
#import "PhoneSurfController.h"
#import "UserManager.h"
#import "NSString+Extensions.h"

@interface SNVoteTableCell : UITableViewCell
{
    UIView* voteView;//投票
    UIView* voteResuleView;//投票结果
    UILabel* myTitleLabel;
    
    UIButton* submitButton;//提交按钮
}
@property(nonatomic,retain)NSMutableArray* resultArray;//点击投票后，每条数据
@property(nonatomic,retain)NSMutableArray* selectArray;//选中
@property(nonatomic,retain)SNNewsExtensionInfo* myVote;//对象

+(CGFloat)cellHeight:(SNNewsExtensionInfo*)vote;


-(void)loadDataWithVote:(SNNewsExtensionInfo*)vote;
@end
