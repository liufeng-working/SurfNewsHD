//
//  CommentModel.m
//  SurfNewsHD
//
//  Created by XuXg on 15/5/20.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "NewsCommentModel.h"

@implementation CommentBase
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"commentId":@"id" ,
             };
}

/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSArray *)ignoredPropertyNames
{
    return @[@"attitude",@"coid"];
}
@end

@implementation HotComment

@end


@implementation NewComment

@end





@implementation NewsCommentRequest

-(id)initWithThreadSummary:(ThreadSummary*)ts pageNum:(NSInteger)page;
{
    self = [super init];
    if (!self)  return nil;
    
    self.coid = [ts channelId];
    self.newsId = [ts threadId];
    self.page = page;
    return self;
}

@end

@implementation NewsCommentAttitudeRequest

-(id)init
{
    self = [super init];
    if (self) {
        self.attitude = @"up";
    }
    return self;
}

@end


@implementation CommitNewsCommentRequest



@end

@implementation NewsCommentResponse

/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"hotList" : @"HotComment",
             @"newsList" : @"NewComment"
             };
}
/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"newsList":@"newList"
             };
}


@end

@implementation HotCommentResponse

// 数组中需要转换的模型类
+ (NSDictionary *)objectClassInArray
{
    return @{@"hotList" : @"HotComment"};
}

@end