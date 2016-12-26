//
//  FeedbackRequest.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonRequestBase.h"

//意见反馈
@interface FeedbackRequest : SurfJsonRequestBase
{
    
}
@property(nonatomic, copy)   NSString *userId;
@property(nonatomic, copy)   NSString *cont;
@property(nonatomic, copy)   NSString *mobile;
@property(nonatomic, copy)   NSString *type;
@property(nonatomic, copy)   NSString *mail;

- (id)initWithUserId:(NSString *)userIdStr andCont:(NSString *)contStr andPhoneNum:(NSString *)phoneNumStr;

@end
