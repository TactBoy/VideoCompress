//
//  MDMediaVideoConversionResult.m
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import "MDMediaVideoConversionResult.h"

@implementation MDMediaVideoConversionResult

+ (instancetype)resultWithFileURL:(NSURL *)fileUrl fileSize:(NSUInteger)fileSize duration:(NSTimeInterval)duration dimensions:(CGSize)dimensions coverImage:(UIImage *)coverImage
{
    MDMediaVideoConversionResult *result = [[MDMediaVideoConversionResult alloc] init];
    result->_fileURL = fileUrl;
    result->_fileSize = fileSize;
    result->_duration = duration;
    result->_dimensions = dimensions;
    result->_coverImage = coverImage;
    return result;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"fileUrl"] = self.fileURL;
    dict[@"dimensions"] = [NSValue valueWithCGSize:self.dimensions];
    dict[@"duration"] = @(self.duration);
    if (self.coverImage != nil)
        dict[@"previewImage"] = self.coverImage;
    return dict;
}

@end
