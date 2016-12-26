//
//  ResultsData.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

// 余额
@interface FlowData : NSObject

@property (nonatomic, copy) NSString        *balance;    // 余额
@property (nonatomic, copy) NSString        *loginbusUrlStr;
@property (nonatomic, copy) NSString        *usedsumStr;
@property (nonatomic, copy) NSString        *prepaidUrlStr;
@property (nonatomic, strong) NSArray *packDataArr;
@property (nonatomic, strong)NSString       *total;


@end



