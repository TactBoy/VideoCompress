//
//  ViewController.m
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/8.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import "ViewController.h"
//#import "SSignalKit/SSignalKit.h"
#import "MDVideoConvert.h"
#import "SSignalKit.h"
#import <AVFoundation/AVFoundation.h>
#import "MDVideoConvert.h"

@interface TestB : NSObject

- (void)enums:(void(^)(void))e;

@property(nonatomic, strong) void(^block)(void);

@end

@implementation TestB

- (void)enums:(void(^)(void))e {
    _block = e;
}

@end

@interface Test : NSObject
{
    NSString *_text;
    TestB *_test;
}
@end

@implementation Test

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _text = @"1234";
        
        [self->_text enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
           
            [self->_text length];
            
        }];
        
        _test = [TestB new];
        [self->_test enums:^{
           
            [self->_test description];
            
        }];
        
    }
    return self;
}

- (void)dealloc
{
    
}

@end

@interface ViewController ()

@property(nonatomic, strong) SSignal *sig;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [Test new];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"MDTest" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVAsset assetWithURL:url];
//    SSignal *sg = [MDVideoConvert convertAVAsset:asset];
    
//    [sg startWithNext:^(id next) {
//
//        NSLog(@"%@", next);
//    } error:^(id error) {
//
//        NSLog(@"%@", error);
//    } completed:^{
//
//        NSLog(@"complete");
//    }];
    
//    SSignal *s2 = [TGMediaVideoConverter convertAVAsset:asset adjustments:nil watcher:nil];
//
//    [s2 startWithNext:^(TGMediaVideoConversionResult *next) {
//
//        if ([next isKindOfClass:TGMediaVideoConversionResult.class]) {
//            NSLog(@"%@", next.dictionary);
//        } else  {
//            NSLog(@"%@", next);
//        }
//
//    } error:^(id error) {
//
//        NSLog(@"%@", error);
//    } completed:^{
//
//        NSLog(@"complete");
//    }];
    
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize dimension = track.naturalSize;
 
    MDVideoEditAdjustments *ad = [MDVideoEditAdjustments
                                  editAdjustmentsWithOriginalSize:CGSizeZero
                                  cropRect:CGRectZero
                                  cropOrientation:UIImageOrientationUp
                                  cropLockedAspectRatio:0
                                  cropMirrored:false
                                  trimStartValue:0
                                  trimEndValue:100
                                  paintingData:nil
                                  sendAsGif:false
                                  preset:MDMediaVideoConversionPresetCompressedMedium];
    
    
    __block CGFloat p = 0;
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/tmp_%d.mp4", ad.preset];

    
//    [MDVideoConvert convertAVAsset:asset outputURL:[NSURL fileURLWithPath:filePath] adjustments:ad inhibitAudio:false complete:^(NSError *error, CGFloat progress, MDMediaVideoConversionResult *result, void (^cancel)(void)) {
//
//        if (error || progress == -1) {
//            NSLog(@"%@", error);
//        } else if (result) {
//            NSLog(@"%@", result.dictionary);
//        } else {
//            if (progress - p > 0.2 || progress == 1) {
//                NSLog(@"progress: %f", progress);
//                p = progress;
//            }
//        }
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (cancel) {
////                cancel();
//            }
//        });
//
//    }];
    
    MDVideoOrientationForAsset(asset, NULL);
    NSLog(@"%@", NSStringFromCGAffineTransform(MDVideoTransformForCrop(UIImageOrientationLeft, CGSizeMake(100, 200), false)));
    
}

/*
 
 原视频: 15.6M
 
 size: {886, 1920}
 
 
 veryLow:
 
 size: 597KB
 AverageBitRate = 400000;
 AVVideoWidthKey = 208
 AVVideoHeightKey = 480;
 AVEncoderBitRateKey = 32000;
 AVNumberOfChannelsKey = 1;

 low:
 
 size: 997KB
 AverageBitRate = 700000;
 AVVideoWidthKey = 288;
 AVVideoHeightKey = 640;
 AVEncoderBitRateKey = 32000;
 AVNumberOfChannelsKey = 1;
 
 medium:
 
 size: 1.5MB
 AverageBitRate = 1100000;
 AVVideoWidthKey = 384;
 AVVideoHeightKey = 848;
 AVEncoderBitRateKey = 64000;
 AVNumberOfChannelsKey = 2;
 
 high:
 
 size: 3.3MB
 AverageBitRate = 2500000;
 AVVideoWidthKey = 576;
 AVVideoHeightKey = 1280;
 AVEncoderBitRateKey = 64000;
 AVNumberOfChannelsKey = 2;
 
 veryHigh:
 
 size: 4.8MB
 AverageBitRate = 4000000;
 AVVideoWidthKey = 880;
 AVVideoHeightKey = 1920;
 AVEncoderBitRateKey = 64000;
 AVNumberOfChannelsKey = 2;
 
 
 
 */

@end
