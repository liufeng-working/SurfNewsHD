//
//  ClassifyUpdateFlagResponse.h
//  SurfNewsHD
//
//  Created by XuXg on 14-10-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"


@interface surfFlagsBase : NSObject

@property BOOL isNewFlag;
@property(nonatomic,strong)NSString *title;
@end



@interface NewsFlagInfo : surfFlagsBase

@property long newID;

@end



@interface GalleryFlagInfo: surfFlagsBase

@property long photoId;


@end

@interface MagazineFlagInfo : surfFlagsBase

@property long magazineId;

@end


@interface ClassifyUpdateFlagResponse : SurfJsonResponseBase


@property(nonatomic,strong)NewsFlagInfo *infoNews;
@property(nonatomic,strong)GalleryFlagInfo *imgNews;
@property(nonatomic,strong)MagazineFlagInfo *magazine;



@end


typedef ClassifyUpdateFlagResponse ClassifyUpdateFlag;
