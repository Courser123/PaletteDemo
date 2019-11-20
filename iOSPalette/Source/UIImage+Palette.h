//
//  UIImage+Palette.h
//  Atom
//
//  Created by dylan.tang on 17/4/20.
//  Copyright © 2017年 dylan.tang All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UGCPalette.h"

typedef NS_ENUM(NSUInteger, UGCGetPaletteImageArea) {
    UGCGetPaletteImageAreaDefault = 0, // the whole image
    UGCGetPaletteImageAreaUP = 1 << 0,
    UGCGetPaletteImageAreaDOWN = 1 << 1,
    UGCGetPaletteImageAreaLEFT = 1 << 2,
    UGCGetPaletteImageAreaRIGHT = 1 << 3,
};

typedef void(^UGCGetColorBlock)(NSDictionary <NSNumber *,NSString *>*colorDict);

@interface UIImage (Palette)

- (void)getPaletteImageColor:(UGCGetColorBlock)block;

- (void)getPaletteImageColorWithArea:(UGCGetPaletteImageArea)area withCallBack:(UGCGetColorBlock)block;

@end
