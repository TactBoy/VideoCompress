#import "MDVideoConvert.h"
#import "MDVideoConvertHeader.h"
#import "MDMediaSampleBufferProcessor.h"
#import "MDMediaVideoConversionPresetSettings.h"
#import "MDMediaVideoConversionContext.h"

@interface MDVideoConvert ()

@end

@implementation MDVideoConvert

+ (void)convertAVAsset:(AVAsset *)avAsset outputURL:(NSURL *)outputURL preset:(MDMediaVideoConversionPreset)preset inhibitAudio:(bool)inhibitAudio complete:(void(^)(NSError *error, CGFloat progress, MDMediaVideoConversionResult *result, void(^cancel)(void)))complete {
    MDVideoEditAdjustments *adjust = [MDVideoEditAdjustments editAdjustmentsWithDictionary:@{@"preset": @(preset)}];
    [self convertAVAsset:avAsset outputURL:outputURL adjustments:adjust inhibitAudio:inhibitAudio complete:complete];
}


+ (void)convertAVAsset:(AVAsset *)avAsset outputURL:(NSURL *)outputURL adjustments:(MDVideoEditAdjustments *)adjustments inhibitAudio:(bool)inhibitAudio complete:(void(^)(NSError *error, CGFloat progress, MDMediaVideoConversionResult *result, void(^cancel)(void)))complete {
    
    MDMediaVideoConversionContext *context = [MDMediaVideoConversionContext new];
    
    NSArray *requiredKeys = @[@"tracks", @"duration"];
    
    [avAsset loadValuesAsynchronouslyForKeys:requiredKeys completionHandler:^
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (context.cancelled) {
                return ;
            }
            
            void (^cancel)(void) = ^() {
                if (context.finished)
                    return ;
                
                [context.videoProcessor cancel];
                [context.audioProcessor cancel];
                
                [context cancelledContext];
            };
            
            CGSize dimensions = [avAsset tracksWithMediaType:AVMediaTypeVideo].firstObject.naturalSize;
            NSLog(@"adjustments.preset: %d", adjustments.preset);
            NSLog(@"dimensions: %@", NSStringFromCGSize(dimensions));
            MDMediaVideoConversionPreset preset = adjustments.sendAsGif ? MDMediaVideoConversionPresetAnimation : [self _presetFromAdjustments:adjustments];
            if (!CGSizeEqualToSize(dimensions, CGSizeZero)) {
                MDMediaVideoConversionPreset bestPreset = [self bestAvailablePresetForDimensions:dimensions];
                NSLog(@"bestPreset: %d", bestPreset);
                if (preset > bestPreset) {
                    preset = bestPreset;
                }
            }
            NSLog(@"preset: %d", preset);

            NSError *error = nil;
            for (NSString *key in requiredKeys)
            {
                if ([avAsset statusOfValueForKey:key error:&error] != AVKeyValueStatusLoaded || error != nil)
                {
                    if (complete) {
                        complete(error, -1, nil, cancel);
                    }
                    return;
                }
            }
            
            NSString *outputPath = outputURL.path;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:outputPath])
            {
                [fileManager removeItemAtPath:outputPath error:&error];
                if (error != nil)
                {
                    if (complete) {
                        complete(error, -1, nil, cancel);
                    }
                    return;
                }
            }
            
            if (![self setupAssetReaderWriterForAVAsset:avAsset outputURL:outputURL preset:preset adjustments:adjustments inhibitAudio:inhibitAudio conversionContext:context error:&error]) {
                if (complete) {
                    complete(error, -1, nil, cancel);
                }
                return;
            }

            [self processWithConversionContext:context complete:^(NSError *error, CGFloat progress) {
                
                if (error) {
                    if (complete) {
                        complete(error, -1, nil, cancel);
                    }
                } else if (progress < 1.0f) {
                    if (complete) {
                        complete(nil, progress, nil, cancel);
                    }
                } else {
                    MDMediaVideoConversionContext *resultContext = context;
                    
                    [resultContext.imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:kCMTimeZero]] completionHandler:^(__unused CMTime requestedTime, CGImageRef _Nullable image, __unused CMTime actualTime, AVAssetImageGeneratorResult result, __unused NSError * _Nullable error)
                    {
                        UIImage *coverImage = nil;
                        if (result == AVAssetImageGeneratorSucceeded) {
                            coverImage = [UIImage imageWithCGImage:image];
                        }
                        
                        MDMediaVideoConversionResult *contextResult = [MDMediaVideoConversionResult resultWithFileURL:outputURL fileSize:0 duration:CMTimeGetSeconds(resultContext.timeRange.duration) dimensions:resultContext.dimensions coverImage:coverImage];
                        
                        [context finishedContext];
                        
                        if (complete) {
                            complete(nil, 1, contextResult, cancel);
                        }
   
                    }];
                }
            }];
            
        });
    }];
    
}

+ (bool)setupAssetReaderWriterForAVAsset:(AVAsset *)avAsset outputURL:(NSURL *)outputURL preset:(MDMediaVideoConversionPreset)preset adjustments:(MDVideoEditAdjustments *)adjustments inhibitAudio:(bool)inhibitAudio conversionContext:(MDMediaVideoConversionContext *)outConversionContext error:(NSError **)error
{
    MDMediaSampleBufferProcessor *videoProcessor = nil;
    MDMediaSampleBufferProcessor *audioProcessor = nil;
    
    AVAssetTrack *audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (videoTrack == nil)
        return false;
    
    CGSize dimensions = CGSizeZero;
    CMTimeRange timeRange = videoTrack.timeRange;
    if (adjustments.trimApplied)
    {
        NSTimeInterval duration = CMTimeGetSeconds(videoTrack.timeRange.duration);
        if (adjustments.trimEndValue < duration)
        {
            timeRange = adjustments.trimTimeRange;
        }
        else
        {
            timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(adjustments.trimStartValue, NSEC_PER_SEC), CMTimeMakeWithSeconds(duration - adjustments.trimStartValue, NSEC_PER_SEC));
        }
    }
    timeRange = CMTimeRangeMake(CMTimeAdd(timeRange.start, CMTimeMake(10, 100)), CMTimeSubtract(timeRange.duration, CMTimeMake(10, 100)));
    NSLog(@"timeRange: 开始 - %f 时长 - %f", CMTimeGetSeconds(timeRange.start), CMTimeGetSeconds(timeRange.duration));
    
    NSDictionary *outputSettings = nil;
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVAssetReaderVideoCompositionOutput *output = [self setupVideoCompositionOutputWithAVAsset:avAsset composition:composition videoTrack:videoTrack preset:preset adjustments:adjustments timeRange:timeRange outputSettings:&outputSettings dimensions:&dimensions conversionContext:outConversionContext];
    
    NSLog(@"outputSettings: %@", outputSettings);
    
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:composition error:error];
    if (assetReader == nil)
        return false;
    
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeMPEG4 error:error];
    if (assetWriter == nil)
        return false;
    
    [assetReader addOutput:output];
    
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    [assetWriter addInput:input];
    
    videoProcessor = [[MDMediaSampleBufferProcessor alloc] initWithAssetReaderOutput:output assetWriterInput:input];
    
    if (!inhibitAudio && [MDMediaVideoConversionPresetSettings keepAudioForPreset:preset] && audioTrack != nil)
    {
        AVMutableCompositionTrack *trimAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [trimAudioTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:kCMTimeZero error:NULL];
        
        AVAssetReaderOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:trimAudioTrack outputSettings:@{ AVFormatIDKey: @(kAudioFormatLinearPCM) }];
        [assetReader addOutput:output];
        
        NSDictionary *audioSetting = [MDMediaVideoConversionPresetSettings audioSettingsForPreset:preset];
        NSLog(@"audioSetting: %@", audioSetting);
        
        AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSetting];
        [assetWriter addInput:input];
        
        audioProcessor = [[MDMediaSampleBufferProcessor alloc] initWithAssetReaderOutput:output assetWriterInput:input];
    }
    
    [outConversionContext addWithAssetReader:assetReader assetWriter:assetWriter videoProcessor:videoProcessor audioProcessor:audioProcessor timeRange:timeRange dimensions:dimensions];
    
    return true;
}

+ (AVAssetReaderVideoCompositionOutput *)setupVideoCompositionOutputWithAVAsset:(AVAsset *)avAsset composition:(AVMutableComposition *)composition videoTrack:(AVAssetTrack *)videoTrack preset:(MDMediaVideoConversionPreset)preset adjustments:(MDVideoEditAdjustments *)adjustments timeRange:(CMTimeRange)timeRange outputSettings:(NSDictionary **)outputSettings dimensions:(CGSize *)dimensions conversionContext:(MDMediaVideoConversionContext *)conversionContext
{
    CGSize transformedSize = CGRectApplyAffineTransform((CGRect){CGPointZero, videoTrack.naturalSize}, videoTrack.preferredTransform).size;;
    CGRect transformedRect = CGRectMake(0, 0, transformedSize.width, transformedSize.height);
    if (CGSizeEqualToSize(transformedRect.size, CGSizeZero))
        transformedRect = CGRectMake(0, 0, videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    
    bool hasCropping = [adjustments cropAppliedForAvatar:false];
    CGRect cropRect = hasCropping ? CGRectIntegral(adjustments.cropRect) : transformedRect;

    CGSize maxDimensions = [MDMediaVideoConversionPresetSettings maximumSizeForPreset:preset];
    CGSize outputDimensions = MDFitSizeF(cropRect.size, maxDimensions);
    outputDimensions = CGSizeMake(ceil(outputDimensions.width), ceil(outputDimensions.height));
    outputDimensions = [self _renderSizeWithCropSize:outputDimensions];
    
    if (MDOrientationIsSideward(adjustments.cropOrientation, NULL))
        outputDimensions = CGSizeMake(outputDimensions.height, outputDimensions.width);
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    NSLog(@"nominalFrameRate: %f", videoTrack.nominalFrameRate);
    if (videoTrack.nominalFrameRate > 0)
        videoComposition.frameDuration = CMTimeMake(1, (int32_t)videoTrack.nominalFrameRate);
    else if (CMTimeCompare(videoTrack.minFrameDuration, kCMTimeZero) == 1)
        videoComposition.frameDuration = videoTrack.minFrameDuration;
    else
        videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableCompositionTrack *trimVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [trimVideoTrack insertTimeRange:timeRange ofTrack:videoTrack atTime:kCMTimeZero error:NULL];
    
    if (MDOrientationIsSideward(adjustments.cropOrientation, NULL))
        videoComposition.renderSize = [self _renderSizeWithCropSize:CGSizeMake(cropRect.size.height, cropRect.size.width)];
    else
        videoComposition.renderSize = [self _renderSizeWithCropSize:cropRect.size];
    
    bool mirrored = false;
    UIImageOrientation videoOrientation = MDVideoOrientationForAsset(avAsset, &mirrored);
    CGAffineTransform transform = MDVideoTransformForOrientation(videoOrientation, videoTrack.naturalSize, cropRect, mirrored);
    CGAffineTransform rotationTransform = MDVideoTransformForCrop(adjustments.cropOrientation, cropRect.size, adjustments.cropMirrored);
    CGAffineTransform finalTransform = CGAffineTransformConcat(transform, rotationTransform);
    
    AVMutableVideoCompositionLayerInstruction *transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:trimVideoTrack];
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, timeRange.duration);
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    UIImage *overlayImage = nil;
    if (adjustments.paintingData != nil)
        overlayImage = adjustments.paintingData;
    
    if (overlayImage != nil)
    {
        CALayer *parentLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height);
        
        CALayer *videoLayer = [CALayer layer];
        videoLayer.frame = parentLayer.frame;
        [parentLayer addSublayer:videoLayer];
        
        CGSize parentSize = parentLayer.bounds.size;
        if (MDOrientationIsSideward(adjustments.cropOrientation, NULL))
            parentSize = CGSizeMake(parentSize.height, parentSize.width);
        
        CGSize size = CGSizeMake(parentSize.width * transformedSize.width / cropRect.size.width, parentSize.height * transformedSize.height / cropRect.size.height);
        CGPoint origin = CGPointMake(-parentSize.width / cropRect.size.width * cropRect.origin.x,  -parentSize.height / cropRect.size.height * (transformedSize.height - cropRect.size.height - cropRect.origin.y));
        
        CALayer *rotationLayer = [CALayer layer];
        rotationLayer.frame = CGRectMake(0, 0, parentSize.width, parentSize.height);
        [parentLayer addSublayer:rotationLayer];
        
        UIImageOrientation orientation = MDMirrorSidewardOrientation(adjustments.cropOrientation);
        CATransform3D layerTransform = CATransform3DMakeTranslation(rotationLayer.frame.size.width / 2.0f, rotationLayer.frame.size.height / 2.0f, 0.0f);
        layerTransform = CATransform3DRotate(layerTransform, MDRotationForOrientation(orientation), 0.0f, 0.0f, 1.0f);
        layerTransform = CATransform3DTranslate(layerTransform, -parentLayer.bounds.size.width / 2.0f, -parentLayer.bounds.size.height / 2.0f, 0.0f);
        rotationLayer.transform = layerTransform;
        rotationLayer.frame = parentLayer.frame;
        
        CALayer *overlayLayer = [CALayer layer];
        overlayLayer.contents = (id)overlayImage.CGImage;
        overlayLayer.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        [rotationLayer addSublayer:overlayLayer];
        
        videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
    
    AVAssetReaderVideoCompositionOutput *output = [[AVAssetReaderVideoCompositionOutput alloc] initWithVideoTracks:[composition tracksWithMediaType:AVMediaTypeVideo] videoSettings:@{ (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) }];
    output.videoComposition = videoComposition;
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:composition];
    imageGenerator.videoComposition = videoComposition;
    imageGenerator.maximumSize = maxDimensions;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    [conversionContext addImageGenerator:imageGenerator];
    
    *outputSettings = [MDMediaVideoConversionPresetSettings videoSettingsForPreset:preset dimensions:outputDimensions];
    *dimensions = outputDimensions;
    
    return output;
}



+ (void)processWithConversionContext:(MDMediaVideoConversionContext *)context_ complete:(void(^)(NSError *error, CGFloat progress))complete
{
    MDMediaVideoConversionContext *context = context_;
    
    if (![context.assetReader startReading])
    {
        if (complete) {
            complete(context.assetReader.error, -1);
        }
        return;
    }
    
    if (![context.assetWriter startWriting])
    {
        if (complete) {
            complete(context.assetWriter.error, -1);
        }
        return;
    }
    
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    [context.assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    if (context.audioProcessor != nil)
    {
        dispatch_group_enter(dispatchGroup);
        [context.audioProcessor startWithTimeRange:context.timeRange progressBlock:nil completionBlock:^
        {
            dispatch_group_leave(dispatchGroup);
        }];
    }
    
    if (context.videoProcessor != nil)
    {
        dispatch_group_enter(dispatchGroup);
        
        [context.videoProcessor startWithTimeRange:context.timeRange progressBlock:^(CGFloat progress)
        {
            if (complete) {
                complete(nil, progress);
            }
        } completionBlock:^
        {
            dispatch_group_leave(dispatchGroup);
        }];
    }
    
    dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        MDMediaVideoConversionContext *context = context_;
        if (context.cancelled)
        {
            [context.assetReader cancelReading];
            [context.assetWriter cancelWriting];
        }
        else
        {
            bool audioProcessingFailed = false;
            bool videoProcessingFailed = false;
            
            if (context.audioProcessor != nil)
                audioProcessingFailed = !context.audioProcessor.succeed;
            
            if (context.videoProcessor != nil)
                videoProcessingFailed = !context.videoProcessor.succeed;
            
            if (!audioProcessingFailed && !videoProcessingFailed && context.assetReader.status != AVAssetReaderStatusFailed)
            {
                [context.assetWriter finishWritingWithCompletionHandler:^
                {
                    if (context.assetWriter.status != AVAssetWriterStatusFailed) {
                        if (complete) {
                            complete(nil, 1.0f);
                        }
                    } else {
                        if (complete) {
                            complete(context.assetWriter.error, -1);
                        }
                    }
                }];
            }
            else
            {
                if (complete) {
                    complete(context.assetReader.error, -1);
                }
            }
        }
        
    });
}

+ (MDMediaVideoConversionPreset)_presetFromAdjustments:(MDVideoEditAdjustments *)adjustments
{
    MDMediaVideoConversionPreset preset = adjustments.preset;
    if (preset == MDMediaVideoConversionPresetCompressedDefault)
    {
        return MDMediaVideoConversionPresetCompressedMedium;
    }
    return preset;
}

+ (MDMediaVideoConversionPreset)bestAvailablePresetForDimensions:(CGSize)dimensions
{
    MDMediaVideoConversionPreset preset = MDMediaVideoConversionPresetCompressedVeryHigh;
    CGFloat maxSide = MAX(dimensions.width, dimensions.height);
    for (NSInteger i = MDMediaVideoConversionPresetCompressedVeryHigh; i >= MDMediaVideoConversionPresetCompressedLow; i--)
    {
        CGFloat presetMaxSide = [MDMediaVideoConversionPresetSettings maximumSizeForPreset:(MDMediaVideoConversionPreset)i].width;
        preset = (MDMediaVideoConversionPreset)i;
        if (maxSide >= presetMaxSide)
            break;
    }
    return preset;
}


+ (CGSize)_renderSizeWithCropSize:(CGSize)cropSize
{
    const CGFloat blockSize = 16.0f;
    
    CGFloat renderWidth = CGFloor(cropSize.width / blockSize) * blockSize;
    CGFloat renderHeight = CGFloor(cropSize.height * renderWidth / cropSize.width);
    if (fmod(renderHeight, blockSize) != 0)
        renderHeight = CGFloor(cropSize.height / blockSize) * blockSize;
    return CGSizeMake(renderWidth, renderHeight);
}

@end
