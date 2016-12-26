//
//  SNUserFlowResponst.h
//  SurfNewsHD
//
//  Created by XuXg on 15/10/12.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"
#import "MJExtension.h"



// 套餐说明
@interface PackflowData : NSObject

@property (nonatomic, copy) NSNumber *isTwenty; /**< 是否二十元封顶 */
@property (nonatomic, copy) NSString *packId;   /**< 套餐ID  */
@property (nonatomic, copy) NSString *packname; /**< 套餐名称 */
@property (nonatomic, copy) NSString *remain;   /**< 剩余 */
@property (nonatomic, copy) NSString *used;     /**< 已使用 */

@end


// 语音套餐 voicepackflow
@interface VoicePackFlowData : NSObject
@property (nonatomic, copy) NSString *packId;   /**< 套餐ID  */
@property (nonatomic, copy) NSString *packname; /**< 套餐名称 */
@property (nonatomic, copy) NSString *remain;   /**< 剩余 */
@property (nonatomic, copy) NSString *used;     /**< 已使用 */
@property (nonatomic, copy) NSString *total;    /**< 总量 */
@end



//{"balance":"39.08","loginbusUrl":"http://go.10086.cn/mb1/go/6?coc=3lnmllng&suid=d884bbc35ecf5822&sid=1","packflow":[{"isTwenty":"0","packId":"6058","packname":"集团统付个人流量包50元包","remain":"841.02","used":"182.97998"},{"isTwenty":"0","packId":"3991","packname":"动感上网套餐（社会版2014）18元","remain":"100.0","used":"0.0"}],"prepaidUrl":"http://wap.js.10086.cn/page?FOLDERID=0002","res":{"reCode":"1","resMessage":"Operation is successful"},"time":1444699344073,"total":"1124.0","usedsum":"182.98","voicepackflow":[{"packId":"4907","packname":"亲情号码组合（1元月功能费）","remain":"482","total":"500","used":"18.0"}]}
@interface SNUserFlowResponst : SurfJsonResponseBase

@property(nonatomic,strong)NSNumber *usedsum;   /**< 已用流量 */
@property(nonatomic,strong)NSNumber *total;     /**< 总流量 */
@property(nonatomic,strong)NSString *balance; /**< 余额 */
@property(nonatomic,strong)NSString *loginbusUrl; /**<  */
@property(nonatomic,strong)NSString *prepaidUrl;    /**<  */
@property(nonatomic,strong)NSArray *packflow; /**< 套餐说明 */
@property(nonatomic,strong)NSArray *voicepackflow; /**< 语音套餐 */
@property(nonatomic)double time;
@end
