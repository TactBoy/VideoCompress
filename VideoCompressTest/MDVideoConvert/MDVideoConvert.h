//
//  MDVideoConvert.h
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/8.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "MDVideoEditAdjustments.h"
#import "MDMediaVideoConversionResult.h"

@interface MDVideoConvert : NSObject

+ (void)convertAVAsset:(AVAsset *)avAsset outputURL:(NSURL *)outputURL adjustments:(MDVideoEditAdjustments *)adjustments inhibitAudio:(bool)inhibitAudio complete:(void(^)(NSError *error, CGFloat progress, MDMediaVideoConversionResult *result, void(^cancel)(void)))complete;

+ (void)convertAVAsset:(AVAsset *)avAsset outputURL:(NSURL *)outputURL preset:(MDMediaVideoConversionPreset)preset inhibitAudio:(bool)inhibitAudio complete:(void(^)(NSError *error, CGFloat progress, MDMediaVideoConversionResult *result, void(^cancel)(void)))complete;


@end

