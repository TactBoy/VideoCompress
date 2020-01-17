//
//  MDMediaSampleBufferProcessor.h
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MDVideoConvertHeader.h"

@interface MDMediaSampleBufferProcessor : NSObject

{
    AVAssetReaderOutput *_assetReaderOutput;
    AVAssetWriterInput *_assetWriterInput;
    
    dispatch_queue_t _queue;
    bool _finished;
    bool _started;
    
    void (^_completionBlock)(void);
}

@property (nonatomic, readonly) bool succeed;

- (instancetype)initWithAssetReaderOutput:(AVAssetReaderOutput *)assetReaderOutput assetWriterInput:(AVAssetWriterInput *)assetWriterInput;

- (void)startWithTimeRange:(CMTimeRange)timeRange progressBlock:(void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(void))completionBlock;

- (void)cancel;

@end

