//
//  MDVideoEditAdjustments.h
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDVideoConvertHeader.h"

@interface MDVideoEditAdjustments : NSObject

@property (nonatomic, readonly) NSTimeInterval trimStartValue;
@property (nonatomic, readonly) NSTimeInterval trimEndValue;
@property (nonatomic, readonly) MDMediaVideoConversionPreset preset;
@property (nonatomic, readonly) bool sendAsGif;

@property (nonatomic, readonly) CGSize originalSize;
@property (nonatomic, readonly) CGRect cropRect;
@property (nonatomic, readonly) UIImageOrientation cropOrientation;
@property (nonatomic, readonly) CGFloat cropLockedAspectRatio;
@property (nonatomic, readonly) bool cropMirrored;
@property (nonatomic, readonly) UIImage *paintingData;

 - (bool)hasPainting;

 - (bool)cropAppliedForAvatar:(bool)forAvatar;

 - (bool)isDefaultValuesForAvatar:(bool)forAvatar;

- (CMTimeRange)trimTimeRange;

- (bool)trimApplied;

- (NSDictionary *)dictionary;

- (instancetype)editAdjustmentsWithPreset:(MDMediaVideoConversionPreset)preset maxDuration:(NSTimeInterval)maxDuration;

+ (instancetype)editAdjustmentsWithOriginalSize:(CGSize)originalSize preset:(MDMediaVideoConversionPreset)preset;

+ (instancetype)editAdjustmentsWithDictionary:(NSDictionary *)dictionary;

+ (instancetype)editAdjustmentsWithOriginalSize:(CGSize)originalSize
                                       cropRect:(CGRect)cropRect
                                cropOrientation:(UIImageOrientation)cropOrientation
                          cropLockedAspectRatio:(CGFloat)cropLockedAspectRatio
                                   cropMirrored:(bool)cropMirrored
                                 trimStartValue:(NSTimeInterval)trimStartValue
                                   trimEndValue:(NSTimeInterval)trimEndValue
                                   paintingData:(UIImage *)paintingData
                                      sendAsGif:(bool)sendAsGif
                                         preset:(MDMediaVideoConversionPreset)preset;

@end

