//
//  DemoShowColorSingleView.h
//  iOSPalette
//
//  Created by 凡铁 on 17/6/6.
//  Copyright © 2017年 DylanTang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UGCPaletteColorModel.h"

@interface DemoShowColorViewCell : UICollectionViewCell

- (void)configureData:(UGCPaletteColorModel*)model andKey:(NSString*)modeKey;

@end
