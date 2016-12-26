//
//  SNNewsContentInfoResponse.m
//  SurfNewsHD
//
//  Created by XuXg on 15/7/23.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNNewsContentInfoResponse.h"


@implementation SNRecommendationInfo
@end

@implementation SNNewsContentInfoResponse
@end


@implementation SNVoteInfo

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"voteId":@"id"};
}

@end

@implementation SNNewsExtensionInfo
/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSArray *)ignoredPropertyNames{
    return @[@"newsId"];
}

/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)objectClassInArray
{
    return @{@"recommendation_list" : @"SNRecommendationInfo",
             @"hot_comment_list" : @"CommentBase",
             @"options": @"SNVoteInfo"};
}

// 是否可以投票
-(BOOL)isVote
{
    if (_vote_title && [_options count] > 0) {
        return YES;
    }
    return NO;
}
@end