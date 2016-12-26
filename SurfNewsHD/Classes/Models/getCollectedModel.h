//
//  getCollectedModel.h
//  SurfNewsHD
//
//  Created by duanmu on 15/10/26.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getCollectedModel : SurfJsonRequestBase


@property(nonatomic)int page; /**<  页数,默认为1 */
@property(nonatomic)int count; /**<  每页展示的条数 */

@end
