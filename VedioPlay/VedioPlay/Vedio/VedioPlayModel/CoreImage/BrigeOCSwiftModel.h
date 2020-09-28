//
//  BrigeOCSwiftModel.h
//  VedioPlay
//
//  Created by wenze on 2020/9/28.
//  Copyright © 2020 wenze. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BrigeOCSwiftModel : NSObject
+(void)creatImageDataTransFormImage:(NSInteger)orientationValue  properties:(CFDictionaryRef)properties dataWidth:(size_t *)width  dataHeigth:(size_t *)height;
@end

NS_ASSUME_NONNULL_END
