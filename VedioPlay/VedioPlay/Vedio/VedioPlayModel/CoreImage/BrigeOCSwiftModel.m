//
//  BrigeOCSwiftModel.m
//  VedioPlay
//
//  Created by wenze on 2020/9/28.
//  Copyright © 2020 wenze. All rights reserved.
//

#import "BrigeOCSwiftModel.h"
#import <ImageIO/ImageIO.h>

@implementation BrigeOCSwiftModel
+(void)creatImageDataTransFormImage:(NSInteger)orientationValue  properties:(CFDictionaryRef)properties dataWidth:(size_t *)width  dataHeigth:(size_t *)height;
{
    if (properties) {
        CFTypeRef val = CFDictionaryGetValue(properties,kCGImagePropertyPixelHeight);
        if (val) CFNumberGetValue(val, kCFNumberLongType, height);
        val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
        if (val) CFNumberGetValue(val, kCFNumberLongType, width);
        val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
        if (val) CFNumberGetValue(val, kCFNumberIntType, &orientationValue);
        //CFRelease(properties);
    }
    
}
@end
