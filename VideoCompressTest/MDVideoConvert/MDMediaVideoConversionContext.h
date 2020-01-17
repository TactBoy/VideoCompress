//
//  MDMediaVideoConversionContext.h
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDVideoConvertHeader.h"
#import "MDMediaSampleBufferProcessor.h"

@interface MDMediaVideoConversionContext : NSObject

@property (nonatomic, readonly) bool cancelled;
@property (nonatomic, readonly) bool finished;

@property (nonatomic, readonly) AVAssetReader *assetReader;
@property (nonatomic, readonly) AVAssetWriter *assetWriter;

@property (nonatomic, readonly) MDMediaSampleBufferProcessor *videoProcessor;
@property (nonatomic, readonly) MDMediaSampleBufferProcessor *audioProcessor;

@property (nonatomic, readonly) CMTimeRange timeRange;
@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, readonly) UIImage *coverImage;

- (void)addWithAssetReader:(AVAssetReader *)assetReader
   assetWriter:(AVAssetWriter *)assetWriter
videoProcessor:(MDMediaSampleBufferProcessor *)videoProcessor
audioProcessor:(MDMediaSampleBufferProcessor *)audioProcessor
     timeRange:(CMTimeRange)timeRange
                dimensions:(CGSize)dimensions;

- (void)addImageGenerator:(AVAssetImageGenerator *)imageGenerator;

- (void)cancelledContext;

- (void)finishedContext;

@end

