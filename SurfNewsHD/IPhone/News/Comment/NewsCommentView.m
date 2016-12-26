//
//  NewsCommentView.m
//  SurfNewsHD
//
//  Created by NJWC on 15/12/1.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "NewsCommentView.h"
#import "GTMHTTPFetcher.h"
#import "SurfRequestGenerator.h"
#import "UserManager.h"
#import "WeatherManager.h"
#import "NewsCommentModel.h"

#define kMaxTextLenght 120                  // 最大的文字长度
#define space 5.f                           // 间距
@interface NewsCommentView ()
{
    UITextView  * _textView;     //输入框
    UIButton    * _sendBtn;      //发送按钮
    UILabel     * _placeHolder;  //占位文字
    CGRect        _rectV;        //记录view原始位置
    CGRect        _rectT;        //记录输入框原始位置
    CGRect        _rectS;        //记录发送按钮原始位置
    CGFloat       _keyboardH;    //记录键盘高度
}

@end

@implementation NewsCommentView

-(void)dealloc
{
    // 监控键盘弹出
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _rectV = frame;
        self.backgroundColor = [UIColor whiteColor];
        
        UIFont * fontS = [UIFont systemFontOfSize:15.0f];
        //发送按钮
        CGFloat sW = 55.f, sH = CGRectGetHeight(frame) - 2 * space;
        CGFloat sX = kContentWidth - sW -space;
        CGFloat sY = space;
        _rectS = CGRectMake(sX, sY, sW, sH);
        UIButton * sendBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn = sendBtn;
        [sendBtn setFrame:_rectS];
        sendBtn.backgroundColor = [UIColor colorWithHexValue:0xffAD2F2F];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendBtn.titleLabel.font = fontS;
        sendBtn.layer.borderWidth = 0.7f;
        sendBtn.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.7].CGColor;
        sendBtn.layer.cornerRadius = 5.f;
        [sendBtn addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendBtn];
        
        // 输入框
        CGFloat tX = space;
        CGFloat tY = space;
        CGFloat tW = kContentWidth - sW - 3 * space;
        CGFloat tH = CGRectGetHeight(frame) - 2 * space;
        _rectT = CGRectMake(tX, tY, tW, tH);
        UITextView *text = [[UITextView alloc] initWithFrame:_rectT];
        _textView = text;
        [text setDelegate:self];
        [text setTextColor:[UIColor blackColor]];
        [text setFont:fontS];
        [text setReturnKeyType:UIReturnKeySend];
        [text setBackgroundColor:[UIColor clearColor]];
        text.layer.borderWidth = 0.7f;
        text.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.7].CGColor;
        text.layer.cornerRadius = 5.f;
        [self addSubview:text];
        
        // 占位符
        NSString *str = @"我来说两句";
        CGRect pR = CGRectMake(5, 0, 100, tH);
        UILabel *placeholder = [[UILabel alloc] initWithFrame:pR];
        _placeHolder = placeholder;
        placeholder.text = str;
        placeholder.textColor = [UIColor colorWithWhite:0.5 alpha:0.7];
        placeholder.userInteractionEnabled = NO;
        placeholder.lineBreakMode = NSLineBreakByClipping;
        placeholder.backgroundColor = [UIColor clearColor];
        placeholder.font = fontS;
        [text addSubview:placeholder];
        
        // 监控键盘弹出
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

//键盘出现
-(void)keyBoardShow:(NSNotification *)noti
{
    NSDictionary * dic = noti.userInfo;
    CGRect rect = [dic[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardH = rect.size.height;
    [self keyboardAppear:_keyboardH];
}

-(void)keyboardAppear:(CGFloat)height
{
    CGFloat vX = 0.f;
    CGFloat vH = self.frame.size.height;
    CGFloat vY = kContentHeight - height - vH;
    CGFloat vW = kContentWidth;
    CGRect vR = CGRectMake(vX, vY, vW, vH);
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = vR;
    }];
}

//点击发送按钮
-(void)sendComment
{
    //发送评论请求
    [self sendCommentRequest:_textView.text];
    
    //还原底部view的状态
    [self returnTo];
}

//  发送新闻评论
-(void)sendCommentRequest:(NSString*)content
{
    if (!_thread) {
        return;
    }
    
    if([_textView.text length] <= 0) {
        [PhoneNotification autoHideWithText:@"输入内容不能为空"];
        return;
    }
    
    // 检查是否包含表情符号
    if ([content isContainsEmoji]) {
        [PhoneNotification autoHideWithText:@"发表内容包含表情符号，评论失败"];
        return;
    }
    
    [PhoneNotification manuallyHideWithIndicator];
    id req = [SurfRequestGenerator commitNewsComment:_thread commentContent: _textView.text];
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    __block GTMHTTPFetcher* weakFetcher = fetcher;
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         BOOL succeed = NO;
         if (!error) {
             NSString* body = [[NSString alloc] initWithData:data encoding:[[[weakFetcher response] textEncodingName] convertToStringEncoding]];
             
             
             // json to model
             // 结果值 0：成功 -1:失败
             SurfJsonResponseBase *resp =
             resp = [SurfJsonResponseBase objectWithKeyValues:body];
             if ([resp.res.reCode isEqualToString:@"1"]) {
                 succeed = YES;
                 
                 // TODO:创建一个评论，添加到新闻评论管理器中
                 NewComment *newComment = [NewComment new];
                 newComment.content = content;
                 newComment.location = [[WeatherManager sharedInstance] weatherInfo].cityName;
                 newComment.createtime = [[NSDate date] timeIntervalSince1970] * 1000;
                 
                 UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
                 if (userInfo.userDes) {
                     newComment.nickname = userInfo.userDes.nickName;
                     newComment.headPic = userInfo.userDes.headPic;
                 }
                 
                 //代理回调
                 if ([_delegate respondsToSelector:@selector(insertNewsComment:)]) {
                     [_delegate insertNewsComment:newComment];
                 }
                 _thread.comment_count += 1; // 评论数加1
             }
         }
         
         if (!succeed) {
             [PhoneNotification autoHideWithText:@"新闻评论发表失败"];
         }
         
         [PhoneNotification hideNotification];
     }];
}

#pragma mark Deletage
// UITextViewDelegate
// UItextView 将要改变文字
-(BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
replacementText:(NSString *)text
{
    //如果点击了键盘上的发送按钮
    if ([text isEqualToString:@"\n"]) {

        // TODO:发送评论请求
        [self sendCommentRequest:_textView.text];
        
        // 隐藏键盘，并恢复位置
        [self returnTo];
        
        return YES;
    }
    return YES;
}

//根据用户输入内容，实时改变输入框和父视图View的大小
- (void)textViewDidChange:(UITextView *)textView
{
    [_placeHolder setHidden:[textView.text length] > 0];
    
    // 检查是否包含表情符号
    if ([textView.text isContainsEmoji]) {
        [PhoneNotification autoHideWithText:@"发表内容不能包含表情符号，暂不支持"];
    }
    
    //markedTextRange：用中文拼音输入法时，输入拼音，尚未选定具体字符时
    if (textView.markedTextRange == nil && [textView.text length] > kMaxTextLenght) {
        textView.text = [textView.text substringToIndex:kMaxTextLenght];
        [PhoneNotification autoHideWithText:[NSString stringWithFormat:@"评论文字长度不能超过%@",@(kMaxTextLenght)]];
    }
    
    //改变每个控件的坐标
    [self changeUIFrame:textView];
}

//改变控件坐标
-(void)changeUIFrame:(UITextView *)textView
{
    //文字显示宽度
    CGFloat tW = _textView.frame.size.width;
    //指定宽，求高
    CGSize size = [textView sizeThatFits:CGSizeMake(tW, CGFLOAT_MAX)];
    
    //按照要求，只显示三行高度
    if (size.height > 70) {
        size.height = 70.f;
    }
    
    //textView的坐标
    CGFloat tX = _textView.frame.origin.x, tY = space;
    CGFloat tH = size.height;
    
    //view的坐标
    CGFloat vX = 0.f;
    CGFloat vW = kContentWidth;
    CGFloat vH = size.height + 2 * space;
    CGFloat vY = kContentHeight - _keyboardH - vH;
   
    //发送按钮的坐标
    CGFloat sW = _rectS.size.width, sH = _rectS.size.height;
    CGFloat sX = kContentWidth - sW -space;
    CGFloat sY = (vH - sH)/2.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        _textView.frame = CGRectMake(tX, tY, tW, tH);
        self.frame = CGRectMake(vX, vY, vW, vH);
        _sendBtn.frame = CGRectMake(sX, sY, sW, sH);
    }];
    
}

//返回原始位置，但是view大小根据内容设定
-(void)exitKeyboard
{
    // 隐藏keyBoard
    [_textView resignFirstResponder];
    CGFloat vX = 0.f;
    CGFloat vH = self.frame.size.height;
    CGFloat vY = kContentHeight - vH;
    CGFloat vW = kContentWidth;
    CGRect vR = CGRectMake(vX, vY, vW, vH);
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = vR;
    }];
}

//还原成原始状态
-(void)returnTo
{
    [_textView resignFirstResponder];
    //清空输入框的内容
    _textView.text = nil;
    [_placeHolder setHidden:NO];
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = _rectV;
        _textView.frame = _rectT;
        _sendBtn.frame = _rectS;
    }];
}

@end
