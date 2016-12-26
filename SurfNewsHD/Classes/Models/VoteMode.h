//
//  VoteMode.h
//  SurfNewsHD
//
//  Created by duanmu on 15/10/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoteMode : SurfJsonRequestBase {
    NSMutableArray *_oldList;
}

@property(nonatomic)long coid;
@property(nonatomic)long newsId;
@property(nonatomic,retain)NSString *oids;


-(void)addOlds:(NSArray*)olds;
-(void)removeOlds:(NSArray*)olds;
@end
