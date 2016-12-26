#import "RSWeakifySelf.h"

id rs_blockWithWeakifiedSelf(id self, id(^intermediateBlock)(id __weak self)){
    id __weak weakSelf = self;
    return intermediateBlock(weakSelf);
}