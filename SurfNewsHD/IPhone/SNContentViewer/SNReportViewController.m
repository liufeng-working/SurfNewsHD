//
//  SNReportViewController.m
//  SurfNewsHD
//
//  Created by XuXg on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "SNReportViewController.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "SNReportModel.h"
#import "CNMutableRadioGroup.h"


@protocol SNReportInputViewDelegate <NSObject>

- (void)keyboardSendText:(NSString *)text;

@end

////////
// 自定义举报输入框
@interface SNReportInputView : UIView {
    
    UITextView *_textView;
}

@property (nonatomic,weak)id<SNReportInputViewDelegate> delegate;
@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;

// 输入内容
-(NSString*)inputTextContent;
@end

@implementation SNReportInputView



-(void)removeFromSuperview
{
    [_textView resignFirstResponder];
    [super removeFromSuperview];
}


// Override canBecomeFirstResponder
// to allow this view to be a responder
- (BOOL) canBecomeFirstResponder {
    return true;
}
// Override
- (BOOL)resignFirstResponder
{
    [_textView resignFirstResponder];
    return [super resignFirstResponder];
}
// Override inputAccessoryView to use
// an instance of KeyboardBar
- (UIView *)inputAccessoryView
{
    if(!_inputAccessoryView) {
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat barH = 40.f;
        CGRect barR = CGRectMake(0, 0, width, barH);
        _inputAccessoryView = [[UIView alloc]initWithFrame:barR];
        _inputAccessoryView.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        
        UITextView *textView =
        [[UITextView alloc]initWithFrame:CGRectMake(5, 5, width-70, barH-10)];
        textView.backgroundColor = [UIColor whiteColor];
        [_inputAccessoryView addSubview:_textView=textView];
        
        
        CGFloat btnX = width-60;
        UIButton *actionButton =
        [[UIButton alloc]initWithFrame:CGRectMake(btnX, 5, 55, barH - 10)];
        actionButton.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        actionButton.layer.cornerRadius = 2.0;
        actionButton.layer.borderWidth = 1.0;
        actionButton.layer.borderColor = [[UIColor colorWithWhite:0.45 alpha:1.0f] CGColor];
        [actionButton setTitle:@"发送" forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(didTouchAction) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:actionButton];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [textView becomeFirstResponder];
        });
    }
    return _inputAccessoryView;
}

-(void)didTouchAction
{
    [_textView resignFirstResponder];
    [_delegate keyboardSendText:_textView.text];
}

-(NSString *)inputTextContent
{
    return _textView.text;
}
@end


@interface SNReportViewController ()<SNReportInputViewDelegate> {
    
    NSMutableArray *_items;
    UIActivityIndicatorView *_activityView;// 风火轮
    
    NSString *_reportContent; // 举报内容
    
    __weak UITextField* _inputText;
}

@end

@interface SNReportViewController ()
{
    __weak SNReportInputView *_inuptV;
    
    __weak UIView *_errorView;
}


@end
@implementation SNReportViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [super setTitle:@"举报文章问题"];
    
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    // 提交按钮
    UIButton *commit = [UIButton buttonWithType:UIButtonTypeCustom];
    [commit setTitle:@"提交" forState:UIControlStateNormal];
    [commit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[commit titleLabel] setFont:[UIFont systemFontOfSize:12]];
    CGSize btnSize = [commit sizeThatFits:CGSizeZero];
    btnSize.width += 10;
    
    CGFloat btnX = width - btnSize.width-10;
    CGFloat btnY = [super topGoBackView].center.y - btnSize.height/2;
    [commit setFrame:CGRectMake(btnX, btnY, btnSize.width, btnSize.height)];
    [commit addTarget:self action:@selector(commitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [[super topBarView] addSubview:commit];
    
    
    // 风火轮
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityView sizeToFit];
    _activityView.center = self.view.center;
    [self.view addSubview:_activityView];
    
    // 请求举报内容
    [self requestReportConent];
    
}

-(void)reloadReportConent:(NSArray*)items
{
    _items = [items mutableCopy];
    if ([items count] > 0) {
        SNReportInfo *report = [SNReportInfo new];
        report.reportType = @"其它问题";
        [_items addObject:report];
    }
    
    
    NSMutableArray *array = [NSMutableArray new];
    for (int i=0; i<[_items count]; ++i) {
        SNReportInfo *info = _items[i];
        if ([info isKindOfClass:[SNReportInfo class]]) {
            [array addObject:info.reportType];
        }
    }

    
    CNMutableRadioGroup *group = [[CNMutableRadioGroup alloc] initWithChoices:array];
    group.raidoType = CNRadio;
    [group addTarget:self action:@selector(groupValueChanged:) forControlEvents:UIControlEventValueChanged];
    [group setFrame:CGRectMake(20, self.StateBarHeight + 10, group.frame.size.width, group.frame.size.height)];
    [self.view addSubview:group];
}

// 选项回调
- (void)groupValueChanged:(CNMutableRadioGroup *)radioGroup
{
    NSUInteger index =
    [radioGroup.selectedIndexs.firstObject integerValue];
    if(index == [_items count]-1){
        // 显示输入框
        CGFloat y = radioGroup.frame.origin.y + CGRectGetHeight(radioGroup.bounds);
        [self showInputView:y+10.f];
    }
    else {
        // 因为我这里是单选，没有多选的问题。
        _reportContent = [_items[index] reportType];
        
        [self hidderInputView];
    }
}

// 显示输入框
- (void)showInputView:(CGFloat)Y
{
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGRect vR = CGRectMake(0, Y, w, 50);
    SNReportInputView *inputV = [[SNReportInputView alloc] initWithFrame:vR];
    inputV.delegate = self;
    [self.view addSubview:_inuptV=inputV];
    [inputV becomeFirstResponder];
}
-(void)hidderInputView
{
    if (_inuptV) {
        [_inuptV resignFirstResponder];
        [_inuptV removeFromSuperview];
    }
}

-(NSString *)inputViewContent
{
    if (_inuptV) {
        return [_inuptV inputTextContent];
    }
    return nil;
}

// 提交内容
-(void)commitButtonClick:(UIButton*)btn
{
    NSString *inputContent = [self inputViewContent];
    if (inputContent) {
        _reportContent = inputContent;
        [self hidderInputView];
    }
    
    
    if(!_reportContent || [_reportContent isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"意见不能为空"];
        return;
    }
    [self submitReportConent];
}

// 获取举报内容
-(void)requestReportConent
{
    if ([_activityView isAnimating]) {
        return;
    }
    
    [_activityView startAnimating];
    
    
    __block typeof(self)weakSelf = self;
    id req = [SurfRequestGenerator newsReport];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error){
        [_activityView stopAnimating];
        if(!error)
        {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            SNReportResponse *res = [SNReportResponse objectWithKeyValues:body];
            if ([res.item count] > 0) {
                [weakSelf reloadReportConent:res.item];
            }
        } else {
            // TODO:显示刷新失败界面
            [self showReportTypeError:YES];
        }
    }];
}

-(void)showReportTypeError:(BOOL)isShow
{
    if (isShow) {
        if (!_errorView) {
            UIView *containerV = [UIView new];
            containerV.backgroundColor = [UIColor clearColor];
            
            UIImage *btnImg = [UIImage imageNamed:@"news_error"];
            UIImageView *errImageV =
            [[UIImageView alloc] initWithImage:btnImg];
            [containerV addSubview:errImageV];
            
            
            UIButton *errorBtn = [UIButton new];
            [errorBtn setTitle:@"重新加载" forState:UIControlStateNormal];
            [errorBtn setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
            [errorBtn setBackgroundColor:[UIColor colorWithHexValue:0xffAD2F2F]];
            [errorBtn addTarget:self
                         action:@selector(reloadButtonClick:)
               forControlEvents:UIControlEventTouchUpInside];
            CGSize btnSize = [errorBtn sizeThatFits:CGSizeZero];
            btnSize.width += 20;
            CGFloat btnX = (btnImg.size.width - btnSize.width)/2;
            CGFloat btnY = btnImg.size.height + 20.f;
            [errorBtn setFrame:CGRectMake(btnX, btnY, btnSize.width, btnSize.height)];
            errorBtn.layer.cornerRadius = 5.f;
            [errorBtn.layer setMasksToBounds:YES];
            [containerV addSubview:errorBtn];

     
            CGFloat cW = btnImg.size.width;
            CGFloat cH = btnY + btnSize.height;
            CGFloat cX = (CGRectGetWidth(self.view.bounds)-cW)/2;
            CGFloat cY = (CGRectGetHeight(self.view.bounds)-cH)/2;
            [containerV setFrame:CGRectMake(cX, cY, cW, cH)];
            [self.view addSubview:_errorView = containerV];
        }
    }
    else {
        [_errorView removeFromSuperview];
        _errorView = nil;
    }
}

-(void)reloadButtonClick:(UIButton*)btn
{
    [self requestReportConent];
    [self showReportTypeError:NO];
}

// 提交举报内容
-(void)submitReportConent
{
    if (!_ts) {
        return;
    }


    id req = [SurfRequestGenerator newsReportSubmit:_ts
                                      reportContent:_reportContent];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error){
        BOOL isSucceed = NO;
        if(!error)
        {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            SurfJsonResponseBase *res = [SurfJsonResponseBase objectWithKeyValues:body];
            isSucceed = [res.res.reCode isEqualToString:@"1"];
        }
        
        // TODO:显示刷新失败界面
        [PhoneNotification autoHideWithText:isSucceed?@"举报成功":@"举报失败"];
    }];
    
    // 直接返回上一级
    [self dismissBackController];
}



#pragma mark SNReportInputViewDelegate 设置搜索的代理
-(void)keyboardSendText:(NSString *)text
{
    if ([text length] > 0 && ![text isEmptyOrBlank]) {
        _reportContent = text;
        [self submitReportConent];
    }
    else {
        [PhoneNotification autoHideWithText:@"意见不能为空"];
    }
}
@end
