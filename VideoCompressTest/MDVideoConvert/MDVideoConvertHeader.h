//
//  MDVideoConvertHeader.h
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#ifdef __LP64__
#   define CGFloor floor
#else
#   define CGFloor floorf
#endif

typedef enum
{
    MDMediaVideoConversionPresetCompressedDefault = 0,
    MDMediaVideoConversionPresetCompressedVeryLow = 1,
    MDMediaVideoConversionPresetCompressedLow = 2,
    MDMediaVideoConversionPresetCompressedMedium = 3,
    MDMediaVideoConversionPresetCompressedHigh = 4,
    MDMediaVideoConversionPresetCompressedVeryHigh = 5,
    MDMediaVideoConversionPresetAnimation = 6,
    MDMediaVideoConversionPresetVideoMessage = 7,
} MDMediaVideoConversionPreset;


bool MDOrientationIsSideward(UIImageOrientation orientation, bool *mirrored);

CGSize MDFitSizeF(CGSize size, CGSize maxSize);

CGAffineTransform MDVideoTransformForCrop(UIImageOrientation orientation, CGSize size, bool mirrored);

CGAffineTransform MDVideoTransformForOrientation(UIImageOrientation orientation, CGSize size, CGRect cropRect, bool mirror);

CGAffineTransform MDVideoCropTransformForOrientation(UIImageOrientation orientation, CGSize size, bool rotateSize);

CGAffineTransform MDTransformForVideoOrientation(AVCaptureVideoOrientation orientation, bool mirrored);

UIImageOrientation MDVideoOrientationForAsset(AVAsset *asset, bool *mirrored);

UIImageOrientation MDMirrorSidewardOrientation(UIImageOrientation orientation);

CGFloat MDRotationForOrientation(UIImageOrientation orientation);

CGFloat progressOfSampleBufferInTimeRange(CMSampleBufferRef sampleBuffer, CMTimeRange timeRange);

CGSize MDFitSizeF(CGSize size, CGSize maxSize);

@interface MDVideoConvertHeader : NSObject




@end








