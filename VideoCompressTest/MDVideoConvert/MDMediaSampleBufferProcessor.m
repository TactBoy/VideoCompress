//
//  MDMediaSampleBufferProcessor.m
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import "MDMediaSampleBufferProcessor.h"

@implementation MDMediaSampleBufferProcessor

- (void)dealloc
{
    
}

- (instancetype)initWithAssetReaderOutput:(AVAssetReaderOutput *)assetReaderOutput assetWriterInput:(AVAssetWriterInput *)assetWriterInput
{
    self = [super init];
    if (self != nil)
    {
        _assetReaderOutput = assetReaderOutput;
        _assetWriterInput = assetWriterInput;
        
        _queue = dispatch_queue_create("mingdao.videoCompress", 0);
        _finished = false;
        _succeed = false;
        _started = false;
    }
    return self;
}

- (void)startWithTimeRange:(CMTimeRange)timeRange progressBlock:(void (^)(CGFloat progress))progressBlock completionBlock:(void (^)(void))completionBlock
{
    _started = true;
    
    _completionBlock = [completionBlock copy];
    
    [_assetWriterInput requestMediaDataWhenReadyOnQueue:_queue usingBlock:^
    {
        if (self->_finished)
            return;
        
        bool ended = false;
        bool failed = false;
        while ([self->_assetWriterInput isReadyForMoreMediaData] && !ended && !failed)
        {
            CMSampleBufferRef sampleBuffer = [self->_assetReaderOutput copyNextSampleBuffer];
            if (sampleBuffer != NULL)
            {
                if (progressBlock != nil)
                    progressBlock(progressOfSampleBufferInTimeRange(sampleBuffer, timeRange));
                
                bool success = false;
                @try {
                    success = [self->_assetWriterInput appendSampleBuffer:sampleBuffer];
                } @catch (NSException *exception) {
                    if ([exception.name isEqualToString:NSInternalInconsistencyException])
                        success = false;
                } @finally {
                    CFRelease(sampleBuffer);
                }
                
                failed = !success;
            }
            else
            {
                ended = true;
            }
        }
        
        if (ended || failed)
        {
            self->_succeed = !failed;
            [self _finish];
        }
    }];
}

- (void)cancel
{
    dispatch_sync(_queue, ^{
        [self _finish];
    });
}

- (void)_finish
{
    bool didFinish = _finished;
    _finished = true;
    
    if (!didFinish)
    {
        if (_started)
            [_assetWriterInput markAsFinished];
        
        if (_completionBlock != nil)
        {
            void (^completionBlock)(void) = [_completionBlock copy];
            _completionBlock = nil;
            completionBlock();
        }
    }
}



@end
