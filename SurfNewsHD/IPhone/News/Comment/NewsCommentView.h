//
//  NewsCommentView.h
//  SurfNewsHD
//
//  Created by NJWC on 15/12/1.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewsCommentViewDelegate <NSObject>

//添加新的评论
-(void)insertNewsComment:(id)object;

@end

@interface NewsCommentView : UIView<UITextViewDelegate>

@property(nonatomic,weak)id<NewsCommentViewDelegate> delegate;
@property(nonatomic,strong)ThreadSummary * thread;

//退出键盘
-(void)exitKeyboard;

@end
