//
//  MDMediaVideoConversionPresetSettings.h
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDVideoConvertHeader.h"

@interface MDMediaVideoConversionPresetSettings : NSObject

+ (CGSize)maximumSizeForPreset:(MDMediaVideoConversionPreset)preset;

+ (NSDictionary *)videoSettingsForPreset:(MDMediaVideoConversionPreset)preset dimensions:(CGSize)dimensions;

+ (NSDictionary *)audioSettingsForPreset:(MDMediaVideoConversionPreset)preset;

+ (bool)keepAudioForPreset:(MDMediaVideoConversionPreset)preset;

@end

