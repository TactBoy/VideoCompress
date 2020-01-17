//
//  MDMediaVideoConversionResult.h
//  VideoCompressTest
//
//  Created by Gavin on 2020/1/14.
//  Copyright © 2020 LRanger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MDMediaVideoConversionResult : NSObject

@property (nonatomic, readonly) NSURL *fileURL;
@property (nonatomic, readonly) NSUInteger fileSize;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) UIImage *coverImage;

+ (instancetype)resultWithFileURL:(NSURL *)fileUrl
                         fileSize:(NSUInteger)fileSize
                         duration:(NSTimeInterval)duration
                       dimensions:(CGSize)dimensions
                       coverImage:(UIImage *)coverImage;
                   

- (NSDictionary *)dictionary;

@end

