//
//  MDVideoConvertHeader.m
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import "MDVideoConvertHeader.h"

bool MDOrientationIsSideward(UIImageOrientation orientation, bool *mirrored)
{
    if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight)
    {
        if (mirrored != NULL)
            *mirrored = false;
        
        return true;
    }
    else if (orientation == UIImageOrientationLeftMirrored || orientation == UIImageOrientationRightMirrored)
    {
        if (mirrored != NULL)
            *mirrored = true;
        
        return true;
    }
    
    return false;
}

CGSize MDFitSizeF(CGSize size, CGSize maxSize)
{
    if (size.width < 1)
        size.width = 1;
    if (size.height < 1)
        size.height = 1;
    
    if (size.width > maxSize.width)
    {
        size.height = (size.height * maxSize.width / size.width);
        size.width = maxSize.width;
    }
    if (size.height > maxSize.height)
    {
        size.width = (size.width * maxSize.height / size.height);
        size.height = maxSize.height;
    }
    return size;
}

CGAffineTransform MDVideoTransformForCrop(UIImageOrientation orientation, CGSize size, bool mirrored)
{
    if (MDOrientationIsSideward(orientation, NULL))
        size = CGSizeMake(size.height, size.width);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(size.width / 2.0f, size.height / 2.0f);
    switch (orientation)
    {
        case UIImageOrientationDown:
        {
            transform = CGAffineTransformRotate(transform, M_PI);
        }
            break;
            
        case UIImageOrientationRight:
        {
            transform = CGAffineTransformRotate(transform, M_PI_2);
        }
            break;
            
        case UIImageOrientationLeft:
        {
            transform = CGAffineTransformRotate(transform, -M_PI_2);
        }
            break;
            
        default:
            break;
    }
    
    if (mirrored)
        transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
    
    if (MDOrientationIsSideward(orientation, NULL))
        size = CGSizeMake(size.height, size.width);
    
    transform = CGAffineTransformTranslate(transform, -size.width / 2.0f, -size.height / 2.0f);

    return transform;
}


CGAffineTransform MDVideoTransformForOrientation(UIImageOrientation orientation, CGSize size, CGRect cropRect, bool mirror)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (mirror)
    {
        if (MDOrientationIsSideward(orientation, NULL))
        {
            cropRect.origin.y *= - 1;
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
        }
        else
        {
            cropRect.origin.x = size.height - cropRect.origin.x;
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
        }
    }
    
    switch (orientation)
    {
        case UIImageOrientationUp:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, size.height - cropRect.origin.x, 0 - cropRect.origin.y), (CGFloat)M_PI_2);
        }
            break;
            
        case UIImageOrientationDown:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, 0 - cropRect.origin.x, size.width - cropRect.origin.y), (CGFloat)-M_PI_2);
        }
            break;
            
        case UIImageOrientationRight:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, 0 - cropRect.origin.x, 0 - cropRect.origin.y), 0);
        }
            break;
            
        case UIImageOrientationLeft:
        {
            transform = CGAffineTransformRotate(CGAffineTransformTranslate(transform, size.width - cropRect.origin.x, size.height - cropRect.origin.y), (CGFloat)M_PI);
        }
            break;
            
        default:
            break;
    }
    
    return transform;
}

CGAffineTransform MDVideoCropTransformForOrientation(UIImageOrientation orientation, CGSize size, bool rotateSize)
{
    if (rotateSize && MDOrientationIsSideward(orientation, NULL))
        size = CGSizeMake(size.height, size.width);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation)
    {
        case UIImageOrientationDown:
        {
            transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(size.width, size.height), (CGFloat)M_PI);
        }
            break;
            
        case UIImageOrientationRight:
        {
            transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(size.width, 0), (CGFloat)M_PI_2);
        }
            break;
            
        case UIImageOrientationLeft:
        {
            transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, size.height), (CGFloat)-M_PI_2);
        }
            break;
            
        default:
            break;
    }
    
    return transform;
}

CGAffineTransform MDTransformForVideoOrientation(AVCaptureVideoOrientation orientation, bool mirrored)
{
    CGAffineTransform transform = mirrored ? CGAffineTransformMakeRotation((CGFloat)M_PI) : CGAffineTransformIdentity;
    
    switch (orientation)
    {
        case UIDeviceOrientationLandscapeRight:
        {
            transform = mirrored ? CGAffineTransformIdentity : CGAffineTransformMakeRotation((CGFloat)M_PI);
        }
            break;
            
        case UIDeviceOrientationPortrait:
        {
            transform = CGAffineTransformMakeRotation((CGFloat)M_PI_2);
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
        {
            transform = CGAffineTransformMakeRotation((CGFloat)M_PI_2 * 3);
        }
            break;
            
        default:
            break;
    }
    
    if (mirrored)
        transform = CGAffineTransformScale(transform, 1, -1);
    
    return transform;
}

UIImageOrientation MDVideoOrientationForAsset(AVAsset *asset, bool *mirrored)
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGAffineTransform t = videoTrack.preferredTransform;
    double videoRotation = atan2((float)t.b, (float)t.a);
    
    if (mirrored != NULL)
    {
        CGFloat scaleX = sqrt(t.a * t.a + t.c * t.c);
        CGFloat scaleY = sqrt(t.b * t.b + t.d * t.d);
        /*UIView *tempView = [[UIView alloc] init];
        tempView.transform = t;
        CGSize scale = CGSizeMake([[tempView.layer valueForKeyPath: @"transform.scale.x"] floatValue],
                                  [[tempView.layer valueForKeyPath: @"transform.scale.y"] floatValue]);*/
        CGSize scale = CGSizeMake(scaleX, scaleY);
        
        *mirrored = (scale.width < 0);
    }
    
    if (fabs(videoRotation - M_PI) < FLT_EPSILON)
        return UIImageOrientationLeft;
    else if (fabs(videoRotation - M_PI_2) < FLT_EPSILON)
        return UIImageOrientationUp;
    else if (fabs(videoRotation + M_PI_2) < FLT_EPSILON)
        return UIImageOrientationDown;
    else
        return UIImageOrientationRight;
}

UIImageOrientation MDMirrorSidewardOrientation(UIImageOrientation orientation)
{
    if (orientation == UIImageOrientationLeft)
        orientation = UIImageOrientationRight;
    else if (orientation == UIImageOrientationRight)
        orientation = UIImageOrientationLeft;
    
    return orientation;
}

CGFloat MDRotationForOrientation(UIImageOrientation orientation)
{
    switch (orientation)
    {
        case UIImageOrientationDown:
            return (CGFloat)-M_PI;
            
        case UIImageOrientationLeft:
            return (CGFloat)-M_PI_2;
            
        case UIImageOrientationRight:
            return (CGFloat)M_PI_2;
            
        default:
            break;
    }
    
    return 0.0f;
}

CGFloat progressOfSampleBufferInTimeRange(CMSampleBufferRef sampleBuffer, CMTimeRange timeRange)
{
    CMTime progressTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMTime sampleDuration = CMSampleBufferGetDuration(sampleBuffer);
    if (CMTIME_IS_NUMERIC(sampleDuration))
        progressTime = CMTimeAdd(progressTime, sampleDuration);
    return MAX(0.0f, MIN(1.0f, CMTimeGetSeconds(progressTime) / CMTimeGetSeconds(timeRange.duration)));
}

@implementation MDVideoConvertHeader




@end
