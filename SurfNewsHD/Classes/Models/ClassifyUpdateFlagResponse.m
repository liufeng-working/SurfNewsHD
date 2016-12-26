//
//  ClassifyUpdateFlagResponse.m
//  SurfNewsHD
//
//  Created by XuXg on 14-10-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "ClassifyUpdateFlagResponse.h"

@implementation surfFlagsBase

@synthesize isNewFlag = __DO_NOT_SERIALIZE_;

-(id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.isNewFlag = YES;
    return self;
}

@end


@implementation NewsFlagInfo
@synthesize newID = __KEY_NAME_id;

@end



@implementation GalleryFlagInfo

@synthesize photoId = __KEY_NAME_id;

@end

@implementation MagazineFlagInfo

@synthesize magazineId = __KEY_NAME_id;

@end




@implementation ClassifyUpdateFlagResponse

@end
