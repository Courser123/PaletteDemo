//
//  ViewController.m
//  PaletteDemo
//
//  Created by Courser on 2019/11/14.
//  Copyright © 2019 Courser. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Palette.h"
#import "UIColor+Hex.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *topColorString;
@property (nonatomic, strong) NSString *bottomColorString;
@property (nonatomic, strong) CAGradientLayer *layer;

@property (nonatomic,strong) UIButton *chooseImageBtn;
@property (nonatomic,strong) ALAssetsLibrary *assetLibrary;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView = [UIImageView new];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = self.view.bounds;
    [self.view addSubview:self.imageView];
    
    _chooseImageBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_chooseImageBtn setTitle:@"选择照片" forState:UIControlStateNormal];
    [_chooseImageBtn sizeToFit];
    _chooseImageBtn.frame = CGRectMake((self.view.bounds.size.width - _chooseImageBtn.bounds.size.width)/2, 50.0f, _chooseImageBtn.bounds.size.width,  _chooseImageBtn.bounds.size.height);
    [_chooseImageBtn addTarget:self action:@selector(goToChooseImage) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_chooseImageBtn];
}

- (ALAssetsLibrary*)assetLibrary{
    if (!_assetLibrary){
        _assetLibrary = [[ALAssetsLibrary alloc]init];
    }
    return _assetLibrary;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view bringSubviewToFront:self.chooseImageBtn];
}

- (void)goToChooseImage{
    UIImagePickerController *vc = [[UIImagePickerController alloc]init];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [self dismissViewControllerAnimated:YES completion:nil];

    NSString *type = [info objectForKey:@"UIImagePickerControllerMediaType"];
    if (![type isEqualToString:@"public.image"]){
        NSLog(@"请选择图片格式");
    }
    NSURL *assetUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    if (!assetUrl){
        NSLog(@"出现未知错误");
    }
    
    __weak typeof (self) weakSelf = self;
    [self.assetLibrary assetForURL:assetUrl resultBlock:^(ALAsset *asset) {
        CGImageRef fullRef = asset.defaultRepresentation.fullResolutionImage;
        UIImage *image =  [UIImage imageWithCGImage:fullRef];
        
        weakSelf.imageView.image = image;
//        dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
//        UIImage *topImage = [image croppedWithRect:CGRectMake(0, 0, image.size.width, image.size.height * 0.2) angle:0];
//        dispatch_async(queue, ^{
//            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//            [topImage getPaletteImageColorWithMode:ALL_MODE_PALETTE withCallBack:^(PaletteColorModel *recommendColor, NSDictionary *allModeColorDic, NSError *error) {
//                weakSelf.topColorString = recommendColor.imageColorString;
//                dispatch_semaphore_signal(semaphore);
//            }];
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        });
//
//        UIImage *bottomImage = [image croppedWithRect:CGRectMake(0, image.size.height * 0.8, image.size.width, image.size.height * 0.2) angle:0];
//        dispatch_async(queue, ^{
//            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//            [bottomImage getPaletteImageColorWithMode:ALL_MODE_PALETTE withCallBack:^(PaletteColorModel *recommendColor, NSDictionary *allModeColorDic, NSError *error) {
//                weakSelf.bottomColorString = recommendColor.imageColorString;
//                dispatch_semaphore_signal(semaphore);
//            }];
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        });
//
//        dispatch_barrier_async(queue, ^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf.layer removeFromSuperlayer];
//                weakSelf.layer = [weakSelf setGradualChangingColor:weakSelf.view fromColor:weakSelf.topColorString toColor:weakSelf.bottomColorString];
//                [weakSelf.view.layer insertSublayer:weakSelf.layer below:weakSelf.imageView.layer];
//            });
//        });
        [image getPaletteImageColorWithArea:UGCGetPaletteImageAreaUP | UGCGetPaletteImageAreaDOWN withCallBack:^(NSDictionary *colorDict) {
            [colorDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *  _Nonnull key, NSString * _Nonnull colorString, BOOL * _Nonnull stop) {
                if ([key integerValue] == UGCGetPaletteImageAreaDefault) {
                    self.topColorString = self.bottomColorString = colorString;
                }else {
                    if ([key integerValue] == UGCGetPaletteImageAreaUP) {
                        weakSelf.topColorString = colorString;
                    }else if ([key integerValue] == UGCGetPaletteImageAreaDOWN) {
                        weakSelf.bottomColorString = colorString;
                    }else if ([key integerValue] == UGCGetPaletteImageAreaLEFT) {
                        weakSelf.topColorString = colorString;
                    }else if ([key integerValue] == UGCGetPaletteImageAreaRIGHT) {
                        weakSelf.bottomColorString = colorString;
                    }
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.layer removeFromSuperlayer];
                weakSelf.layer = [weakSelf setGradualChangingColor:weakSelf.view fromColor:weakSelf.topColorString toColor:weakSelf.bottomColorString];
                [weakSelf.view.layer insertSublayer:weakSelf.layer below:weakSelf.imageView.layer];
            });

        }];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"出错了");
    }];
}

//绘制渐变色颜色的方法
- (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr{

//    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;

    //  创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:fromHexColorStr].CGColor,(__bridge id)[UIColor colorWithHexString:toHexColorStr].CGColor];

    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
//    gradientLayer.startPoint = CGPointMake(0, 1);
//    gradientLayer.endPoint = CGPointMake(1, 1);
    
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];

    return gradientLayer;
}

@end
