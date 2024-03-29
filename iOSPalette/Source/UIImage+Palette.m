//
//  UIImage+Palette.m
//  Atom
//
//  Created by dylan.tang on 17/4/20.
//  Copyright © 2017年 dylan.tang All rights reserved.
//

#import "UIImage+Palette.h"

#define UGCPaletteRatio 0.1
#define UGCSizeRatio 50

@implementation UIImage (Palette)

- (void)getPaletteImageColor:(UGCGetColorBlock)block{
    [self getPaletteImageColorWithArea:UGCGetPaletteImageAreaDefault withCallBack:block];
    
}

- (void)getPaletteImageColorWithArea:(UGCGetPaletteImageArea)area withCallBack:(UGCGetColorBlock)block {
    NSMutableDictionary <NSNumber *,UIImage *>*tmpDict = [NSMutableDictionary dictionary];
    if (area == UGCGetPaletteImageAreaDefault) {
        UIImage *image = [self compressedAspectFitToSize:CGSizeMake(UGCSizeRatio, UGCSizeRatio)];
        if (image) {
            [tmpDict setObject:image forKey:@(UGCGetPaletteImageAreaDefault)];
        }
    }else {
        if (area & UGCGetPaletteImageAreaUP) {
            UIImage *image = [self compressedAspectFitToSize:CGSizeMake(UGCSizeRatio, UGCSizeRatio)];
            image = [image croppedWithRect:CGRectMake(0, 0, image.size.width, image.size.height * UGCPaletteRatio) angle:0];
            if (image) {
                [tmpDict setObject:image forKey:@(UGCGetPaletteImageAreaUP)];
            }
        }
        if (area & UGCGetPaletteImageAreaDOWN) {
            UIImage *image = [self compressedAspectFitToSize:CGSizeMake(UGCSizeRatio, UGCSizeRatio)];
            image = [image croppedWithRect:CGRectMake(0, image.size.height * (1 - UGCPaletteRatio), image.size.width, image.size.height * UGCPaletteRatio) angle:0];
            if (image) {
                [tmpDict setObject:image forKey:@(UGCGetPaletteImageAreaDOWN)];
            }
        }
        if (area & UGCGetPaletteImageAreaLEFT) {
            UIImage *image = [self compressedAspectFitToSize:CGSizeMake(UGCSizeRatio, UGCSizeRatio)];
            image = [image croppedWithRect:CGRectMake(0, 0, image.size.width * UGCPaletteRatio, image.size.height) angle:0];
            if (image) {
                [tmpDict setObject:image forKey:@(UGCGetPaletteImageAreaLEFT)];
            }
        }
        if (area & UGCGetPaletteImageAreaRIGHT) {
            UIImage *image = [self compressedAspectFitToSize:CGSizeMake(UGCSizeRatio, UGCSizeRatio)];
            image = [image croppedWithRect:CGRectMake(image.size.width * (1 - UGCPaletteRatio), 0, image.size.width * UGCPaletteRatio, image.size.height) angle:0];
            if (image) {
                [tmpDict setObject:image forKey:@(UGCGetPaletteImageAreaRIGHT)];
            }
        }
    }
    
    dispatch_group_t group = dispatch_group_create();
    NSMutableDictionary *colorDict = [NSMutableDictionary dictionary];
    [tmpDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIImage * _Nonnull image, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UGCPalette *palette = [[UGCPalette alloc]initWithImage:image];
            [palette startToAnalyzeImage:^(UGCPaletteColorModel *recommendColor, NSDictionary *allModeColorDic, NSError *error) {
                if (recommendColor.imageColorString) {
                    [colorDict setObject:recommendColor.imageColorString forKey:key];
                }
                dispatch_group_leave(group);
            }];
        });
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (block) {
            block(colorDict.copy);
        }
    });
}

- (UIImage *)compressedAspectFitToSize:(CGSize)size {
    
    CGFloat width = self.size.width, height = self.size.height;
    
    if (!width || !height || !size.width || !size.height) {
        NSLog(@"invalid parameter");
        return self;
    }
    if (width <= size.width && height <= size.height) {
        NSLog(@"no need to compress.");
        return self;
    }
    
    CGFloat wScale = size.width / width, hScale = size.height / height;
    CGSize targetSize = CGSizeZero;
    if (wScale < hScale) {
        targetSize.width = size.width;
        targetSize.height = wScale * height;
    }else {
        targetSize.height = size.height;
        targetSize.width = hScale * width;
    }
    targetSize = CGSizeMake(ceil(targetSize.width), ceil(targetSize.height));
    return [self compressedFillToSize:targetSize];
}

- (UIImage *)compressedFillToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return compressedImage;
}

- (UIImage *)croppedWithRect:(CGRect)frame
                       angle:(NSInteger)angle {
    UIImage *croppedImage = nil;
    angle = angle % 360;
    UIGraphicsBeginImageContextWithOptions(frame.size, ![self hasAlpha], self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //To conserve memory in not needing to completely re-render the image re-rotated,
    //map the image to a view and then use Core Animation to manipulate its rotation
    if (angle != 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
        imageView.layer.minificationFilter = kCAFilterNearest;
        imageView.layer.magnificationFilter = kCAFilterNearest;
        imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle * (M_PI/180.0));
        CGRect rotatedRect = CGRectApplyAffineTransform(imageView.bounds, imageView.transform);
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, rotatedRect.size}];
        [containerView addSubview:imageView];
        imageView.center = containerView.center;
        CGContextTranslateCTM(ctx, -frame.origin.x, -frame.origin.y);
        [containerView.layer renderInContext:ctx];
    }else {
        CGContextTranslateCTM(ctx, -frame.origin.x, -frame.origin.y);
        [self drawAtPoint:CGPointZero];
    }
    croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithCGImage:croppedImage.CGImage scale:self.scale orientation:UIImageOrientationUp];
}

- (BOOL)hasAlpha {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    return (alphaInfo == kCGImageAlphaLast || alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaPremultipliedLast || alphaInfo == kCGImageAlphaPremultipliedFirst);
}

@end
