//
//  Palette.m
//
//  Created by dylan.tang on 17/4/11.
//  Copyright © 2017年 dylan.tang All rights reserved.
//

#import "UGCPalette.h"

@implementation UGCPaletteColorModel

@end

@interface UGCPalette ()

@property (nonatomic,strong) UIImage *image;

/** the pixel count of the image */
@property (nonatomic,assign) NSInteger pixelCount;

/** callback */
@property (nonatomic,copy) GetColorBlock getColorBlock;

@end

@implementation UGCPalette

-(instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if (self){
        _image = image;
    }
    return self;
}

#pragma mark - Core code to analyze the main color of a image

- (void)startToAnalyzeImage:(GetColorBlock)block{
    if (!_image){
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation fail", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The image is nill.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check the image input please", nil)
                                   };
        NSError *nullImageError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:userInfo];
        block(nil,nil,nullImageError);
        return;
    }
    self.getColorBlock = block;
    [self startToAnalyzeImage];
}

- (void)startToAnalyzeImage{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Get raw pixel data from image
        unsigned char *rawData = [self rawPixelDataFromImage:self.image];
        if (!rawData || self.pixelCount <= 0){
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Operation fail", nil),
                                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The image is nill.", nil),
                                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check the image input please", nil)
                                           };
            NSError *nullImageError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:userInfo];
            self.getColorBlock(nil,nil,nullImageError);
            return;
        }
        
        NSInteger red,green,blue;
        NSInteger totalRed = 0;
        NSInteger totalGreen =  0;
        NSInteger totalBlue = 0;
        for (int pixelIndex = 0 ; pixelIndex < self.pixelCount; pixelIndex++){
            
            red   = (NSInteger)rawData[pixelIndex*4+0];
            green = (NSInteger)rawData[pixelIndex*4+1];
            blue  = (NSInteger)rawData[pixelIndex*4+2];
                    
            totalRed += red;
            totalGreen += green;
            totalBlue += blue;
            
        }
        
        NSInteger averageRed = (NSInteger)(totalRed / self.pixelCount);
        NSInteger averageGreen = (NSInteger)(totalGreen / self.pixelCount);
        NSInteger averageBlue= (NSInteger)(totalBlue / self.pixelCount);
        
        NSInteger color = averageRed << 2 * 8 | averageGreen << 8 | averageBlue;
        
        NSString *colorString = [self getColorStringWithColor:color];
        
        free(rawData);
        
        UGCPaletteColorModel *model = [UGCPaletteColorModel new];
        model.imageColorString = colorString;
        if (self.getColorBlock) {
            self.getColorBlock(model, nil, nil);
        }
    });

}

- (NSString*)getColorStringWithColor:(NSInteger)color {
    NSInteger red = [self approximateRed:color];
    
    NSInteger green = [self approximateGreen:color];
    
    NSInteger blue = [self approximateBlue:color];
    
    NSString *colorString = [NSString stringWithFormat:@"#%02lx%02lx%02lx",red,green,blue];
    return colorString;
}

- (NSInteger)approximateRed:(NSInteger)color{
    return (color >> (8 + 8)) & ((1 << 8) - 1);
}

- (NSInteger)approximateGreen:(NSInteger)color{
    return color >> 8 & ((1 << 8) - 1);
}

- (NSInteger)approximateBlue:(NSInteger)color{
    return color  & ((1 << 8) - 1);
}

#pragma mark - image compress

- (unsigned char *)rawPixelDataFromImage:(UIImage *)image{
    // Get cg image and its size
    
    CGImageRef cgImage = [image CGImage];
    NSUInteger width = CGImageGetWidth(cgImage);
    NSUInteger height = CGImageGetHeight(cgImage);
    
    // Allocate storage for the pixel data
    unsigned char *rawData = (unsigned char *)malloc(height * width * 4);
    
    // If allocation failed, return NULL
    if (!rawData) return NULL;
    
    // Create the color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Set some metrics
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    // Create context using the storage
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // Release the color space
    CGColorSpaceRelease(colorSpace);
    
    // Draw the image into the storage
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    
    // We are done with the context
    CGContextRelease(context);
    
    // Write pixel count to passed pointer
    self.pixelCount = (NSInteger)width * (NSInteger)height;
    
    // Return pixel data (needs to be freed)
    return rawData;
}

@end

