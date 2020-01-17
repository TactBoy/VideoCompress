//
//  MDMediaVideoConversionPresetSettings.m
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import "MDMediaVideoConversionPresetSettings.h"

@implementation MDMediaVideoConversionPresetSettings


+ (CGSize)maximumSizeForPreset:(MDMediaVideoConversionPreset)preset
{
    switch (preset)
    {
        case MDMediaVideoConversionPresetCompressedVeryLow:
            return (CGSize){ 480.0f, 480.0f };
            
        case MDMediaVideoConversionPresetCompressedLow:
            return (CGSize){ 640.0f, 640.0f };
            
        case MDMediaVideoConversionPresetCompressedMedium:
            return (CGSize){ 848.0f, 848.0f };
            
        case MDMediaVideoConversionPresetCompressedHigh:
            return (CGSize){ 1280.0f, 1280.0f };
            
        case MDMediaVideoConversionPresetCompressedVeryHigh:
            return (CGSize){ 1920.0f, 1920.0f };
            
        case MDMediaVideoConversionPresetVideoMessage:
            return (CGSize){ 240.0f, 240.0f };
            
        default:
            return (CGSize){ 640.0f, 640.0f };
    }
}

+ (bool)keepAudioForPreset:(MDMediaVideoConversionPreset)preset
{
    return preset != MDMediaVideoConversionPresetAnimation;
}

+ (NSDictionary *)audioSettingsForPreset:(MDMediaVideoConversionPreset)preset
{
    NSInteger bitrate = [self _audioBitrateKbpsForPreset:preset];
    NSInteger channels = [self _audioChannelsCountForPreset:preset];
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = channels > 1 ? kAudioChannelLayoutTag_Stereo : kAudioChannelLayoutTag_Mono;
    
    return @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVSampleRateKey: @44100.0f,
    AVEncoderBitRateKey: @(bitrate * 1000),
    AVNumberOfChannelsKey: @(channels),
    AVChannelLayoutKey: [NSData dataWithBytes:&acl length:sizeof(acl)]
    };
}

+ (NSDictionary *)videoSettingsForPreset:(MDMediaVideoConversionPreset)preset dimensions:(CGSize)dimensions
{
    NSDictionary *videoCleanApertureSettings = @
    {
    AVVideoCleanApertureWidthKey: @((NSInteger)dimensions.width),
    AVVideoCleanApertureHeightKey: @((NSInteger)dimensions.height),
    AVVideoCleanApertureHorizontalOffsetKey: @10,
    AVVideoCleanApertureVerticalOffsetKey: @10
    };
    
    NSDictionary *videoAspectRatioSettings = @
    {
    AVVideoPixelAspectRatioHorizontalSpacingKey: @3,
    AVVideoPixelAspectRatioVerticalSpacingKey: @3
    };
    
    NSDictionary *codecSettings = @
    {
    AVVideoAverageBitRateKey: @([self _videoBitrateKbpsForPreset:preset] * 1000),
    AVVideoCleanApertureKey: videoCleanApertureSettings,
    AVVideoPixelAspectRatioKey: videoAspectRatioSettings
    };
    
    return @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoCompressionPropertiesKey: codecSettings,
    AVVideoWidthKey: @((NSInteger)dimensions.width),
    AVVideoHeightKey: @((NSInteger)dimensions.height)
    };
}

+ (NSInteger)_videoBitrateKbpsForPreset:(MDMediaVideoConversionPreset)preset
{
    switch (preset)
    {
        case MDMediaVideoConversionPresetCompressedVeryLow:
            return 400;
            
        case MDMediaVideoConversionPresetCompressedLow:
            return 700;
            
        case MDMediaVideoConversionPresetCompressedMedium:
            return 1100;
            
        case MDMediaVideoConversionPresetCompressedHigh:
            return 2500;
            
        case MDMediaVideoConversionPresetCompressedVeryHigh:
            return 4000;
        
        case MDMediaVideoConversionPresetVideoMessage:
            return 300;

        default:
            return 700;
    }
}

+ (NSInteger)_audioBitrateKbpsForPreset:(MDMediaVideoConversionPreset)preset
{
    switch (preset)
    {
        case MDMediaVideoConversionPresetCompressedVeryLow:
            return 32;
            
        case MDMediaVideoConversionPresetCompressedLow:
            return 32;
            
        case MDMediaVideoConversionPresetCompressedMedium:
            return 64;
            
        case MDMediaVideoConversionPresetCompressedHigh:
            return 64;
            
        case MDMediaVideoConversionPresetCompressedVeryHigh:
            return 64;
            
        case MDMediaVideoConversionPresetVideoMessage:
            return 32;
            
        default:
            return 32;
    }
}

+ (NSInteger)_audioChannelsCountForPreset:(MDMediaVideoConversionPreset)preset
{
    switch (preset)
    {
        case MDMediaVideoConversionPresetCompressedVeryLow:
            return 1;
            
        case MDMediaVideoConversionPresetCompressedLow:
            return 1;
            
        case MDMediaVideoConversionPresetCompressedMedium:
            return 2;
            
        case MDMediaVideoConversionPresetCompressedHigh:
            return 2;
            
        case MDMediaVideoConversionPresetCompressedVeryHigh:
            return 2;
            
        default:
            return 1;
    }
}


@end
