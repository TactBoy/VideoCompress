//
//  MDMediaVideoConversionContext.m
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import "MDMediaVideoConversionContext.h"

@implementation MDMediaVideoConversionContext

- (void)addWithAssetReader:(AVAssetReader *)assetReader
               assetWriter:(AVAssetWriter *)assetWriter
            videoProcessor:(MDMediaSampleBufferProcessor *)videoProcessor
            audioProcessor:(MDMediaSampleBufferProcessor *)audioProcessor
                 timeRange:(CMTimeRange)timeRange
                dimensions:(CGSize)dimensions {
    
    _assetReader = assetReader;
    _assetWriter = assetWriter;
    _videoProcessor = videoProcessor;
    _audioProcessor = audioProcessor;
    _timeRange = timeRange;
    _dimensions = dimensions;
}

- (void)cancelledContext {
    _cancelled = true;
}

- (void)finishedContext {
    _finished = true;
}

- (void)addImageGenerator:(AVAssetImageGenerator *)imageGenerator {
    _imageGenerator = imageGenerator;
}


@end
