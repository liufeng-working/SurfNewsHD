//
//  SNSearchHistoryView.m
//  SurfNewsHD
//
//  Created by XuXg on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNSearchHistoryView.h"
#import "UIButton+Block.h"
#import "DispatchUtil.h"

#define kClearHistoryCell 35.f

// 历史记录cell委托事件
@protocol SNSearchHistoryCellDelegate <NSObject>

// 添加一个搜索记录
-(void)addSearchHistoryFromCell:(id)userInfo;
-(void)deleteSearchHistory:(id)userInfo;

@end

// 历史记录cell
@interface SNSearchHistoryCell : UITableViewCell {
    
    __weak UIButton *_delBtn;
    __weak UIButton *_addBtn;
    __weak UILabel *_titleLabel;
    
    __weak id userInfo;
}

@property(nonatomic, weak)id<SNSearchHistoryCellDelegate> delegate;
-(void)loadedHistoryData:(id)data;

@end

@implementation SNSearchHistoryCell

+ (CGFloat)historyCellFits
{
    return 35.f;
}


-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
    
        // 添加Button
        UIImage *addImage = [UIImage imageNamed:@"dis_history_cell_add"];
        UIImage *delImage = [UIImage imageNamed:@"dis_history_cell_del"];
        
        CGFloat btnWidth = delImage.size.width;
        CGFloat btnHeight = delImage.size.height;
        UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn = add;
        [add setImage:addImage forState:UIControlStateNormal];
        [add addTarget:self action:@selector(addHistoryTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [add setFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
        [add setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [self.contentView addSubview:add];
        
        
        // delete button
        CGRect delRect = CGRectMake(0, 0, btnWidth, btnHeight);
        UIButton *delButn = [UIButton buttonWithType:UIButtonTypeCustom];
        _delBtn = delButn;
        [delButn setFrame:delRect];
        [delButn setImage:delImage forState:UIControlStateNormal];
        [delButn addTarget:self action:@selector(delHistoryButton:) forControlEvents:UIControlEventTouchUpInside];
        [delButn setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [self.contentView addSubview:delButn];
        
        
        UILabel *label = [UILabel new];
        _titleLabel = label;
        label.textColor = [UIColor colorWithHexValue:0xff333333];
        label.font = [UIFont systemFontOfSize:13.f];
        [self.contentView addSubview:label];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat rMargin = 20.f;
    CGFloat btnSpace = 20.f;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat btnW = CGRectGetWidth(_delBtn.bounds);
    CGFloat midY = CGRectGetMidY(self.bounds);
    CGPoint center = CGPointMake(width-rMargin-btnW-btnW/2, midY);
    
    _addBtn.center = center;
    center.x += (btnW/2+btnSpace);
    _delBtn.center = center;
    
    
    CGFloat tX = 15.f;
    CGFloat tH = _titleLabel.font.lineHeight;
    CGFloat tY = (height - tH)/2.f;
    CGFloat tW = width - tX - rMargin - btnSpace- btnW-btnW;
    CGRect tR = CGRectMake(tX, tY, tW, tH);
    [_titleLabel setFrame:tR];
    
}
-(void)loadedHistoryData:(id)data
{
    _titleLabel.text = data;
    userInfo = data;
}

-(void)addHistoryTitleButton:(UIButton *)addBtn
{
    if([_delegate respondsToSelector:@selector(addSearchHistoryFromCell:)])
        [_delegate addSearchHistoryFromCell:userInfo];
}
-(void)delHistoryButton:(UIButton *)delBtn
{
    if([_delegate respondsToSelector:@selector(deleteSearchHistory:)])
        [_delegate deleteSearchHistory:userInfo];
}
@end




@interface SNSearchHistoryView () <UITableViewDelegate,
UITableViewDataSource,SNSearchHistoryCellDelegate>{
    
    __weak UITableView *_historyTable;
    NSMutableArray *_historyData;
    UIImage *_deleteBtnImage;
    
    __weak UILabel *_tips;
}




@end



@implementation SNSearchHistoryView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UITableView *table =
        [[UITableView alloc] initWithFrame:self.bounds
                                     style:UITableViewStylePlain];
        _historyTable = table;
        table.delegate = self;
        table.dataSource = self;
        table.bounces = NO;
        table.tableFooterView = [UIView new];
        table.backgroundColor = [UIColor clearColor];
        table.autoresizingMask = UIViewAutoresizingFlexibleWidth|
        UIViewAutoresizingFlexibleHeight;
        if ([table respondsToSelector:@selector(setSeparatorInset:)]) {
            [table setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([table respondsToSelector:@selector(setLayoutMargins:)]) {
            [table setLayoutMargins:UIEdgeInsetsZero];
        }
        [self addSubview:table];
        
        
        
        UIFont *font = [UIFont systemFontOfSize:15.f];
        CGFloat tipsH = font.lineHeight;
        CGFloat tipsW = CGRectGetWidth(self.bounds);
        CGRect tipsRect = CGRectMake(0, 10, tipsW, tipsH);
        UILabel *tips = [[UILabel alloc] initWithFrame:tipsRect];
        _tips = tips;
        [tips setHidden:YES];
        tips.text = @"暂时没有搜索记录";
        tips.font = font;
        tips.textAlignment = NSTextAlignmentCenter;
        tips.textColor = [UIColor colorWithHexValue:0xff999999];
        tips.backgroundColor = [UIColor clearColor];
        [self addSubview:tips];
    }
    return self;
}


#pragma mark- public method
-(void)loadDataWithHistoryArray:(NSArray*)historyList
{
    if (!historyList || [historyList count] == 0) {
        [_tips setHidden:NO];
        return;
    }
    
    [_tips setHidden:YES];
    _historyData = [historyList mutableCopy];
    [_historyTable reloadData];
}

#pragma mark- private mathod
- (CGSize)sizeThatFits:(CGSize)size
{    
    CGFloat selfHeight = [SNSearchHistoryCell historyCellFits];
    selfHeight *= [_historyData count];
    selfHeight += kClearHistoryCell; // 清除历史记录Cell高度
    return CGSizeMake(size.width, selfHeight);
}
#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = indexPath.row;
    if (index < [_historyData count]) {
        return [SNSearchHistoryCell historyCellFits];
    }
    return kClearHistoryCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger index = indexPath.row;
    if (index < [_historyData count]) {
        id data = _historyData[index];
        if ([_delegate respondsToSelector:@selector(searchHistory:)]) {
            [_delegate searchHistory:data];
        }
    }
    else {
        
        // 清除历史记录
        [DispatchUtil dispatch:^{
             [_historyData removeAllObjects];
             [_historyTable reloadData];
        } after:0.5f];
       
        if ([_delegate respondsToSelector:@selector(clearSearchHistory)]) {
            [_delegate clearSearchHistory];
        }
    }
}


#pragma mark- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if ([_historyData count] == 0) {
        return 0;
    }
    return [_historyData count] + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    NSInteger index = indexPath.row;
    
    if (index < [_historyData count]) {
        // 历史记录
        static NSString *ident = @"history_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:ident];
        NSString *title = _historyData[index];
        
        if (!cell) {
            cell = [[SNSearchHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
            cell.backgroundColor = [UIColor clearColor];
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }
            [(SNSearchHistoryCell*)cell setDelegate:self];
        }
        [(SNSearchHistoryCell*)cell loadedHistoryData:title];
    }
    else{
        // 清除历史记录
        static NSString *ident = @"clear_history_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
            cell.backgroundColor = [UIColor clearColor];
            
            cell.textLabel.text = @"清除历史记录";
            cell.textLabel.font = [UIFont systemFontOfSize:15.f];
            cell.textLabel.textColor = [UIColor colorWithHexValue:0xff999999];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
            }
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
            }
        }
    }
    return  cell;
}

#pragma mark- SNSearchHistoryCellDelegate
// 添加一个搜索记录
-(void)addSearchHistoryFromCell:(id)userInfo
{
    if ([_delegate respondsToSelector:@selector(addSearchHistory:)]) {
        [_delegate addSearchHistory:userInfo];
    }
}
-(void)deleteSearchHistory:(id)userInfo
{
    if (![_historyData containsObject:userInfo])
        return;
    
    // 删除一条cell
    __block typeof(self)weakSelf = self;
    [DispatchUtil dispatch:^{
        NSUInteger index = [_historyData indexOfObject:userInfo];
        if (index != NSNotFound && index < [_historyData count]) {
            NSIndexPath *delPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            
            [weakSelf->_historyData removeObject:userInfo];
            if ([weakSelf->_historyData count] > 0) {
                [weakSelf->_historyTable beginUpdates];
                [weakSelf->_historyTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:delPath, nil] withRowAnimation:UITableViewRowAnimationBottom];
                [weakSelf->_historyTable endUpdates];
            }
            else {
                [_tips setHidden:NO];
                [weakSelf->_historyTable reloadData];
            }
            [weakSelf performSelector:@selector(sizeToFit) withObject:nil afterDelay:0.25]; // 从新调整大小
            
            if([weakSelf->_delegate respondsToSelector:@selector(    deleateSearchHistory:)]){
                [weakSelf->_delegate deleateSearchHistory:userInfo];
            }
        }
        
    } after:0.1];
    
}
@end
