//
//  TRIPPalette.h
//  Atom
//
//  Created by dylan.tang on 17/4/11.
//  Copyright © 2017年 dylan.tang All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UGCPaletteColorModel : NSObject

/** ColorHexString eg:"#FFC300" */
@property (nonatomic,copy) NSString *imageColorString;

@end

typedef void(^GetColorBlock)(UGCPaletteColorModel *recommendColor,NSDictionary *allModeColorDic,NSError *error);

@interface UGCPalette : NSObject

- (instancetype)initWithImage:(UIImage*)image;

- (void)startToAnalyzeImage:(GetColorBlock)block;

@end
