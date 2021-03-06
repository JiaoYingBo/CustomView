//
//  ViewController.m
//  PhotoCustom
//
//  Created by Mac on 16/6/6.
//  Copyright © 2016年 yb. All rights reserved.
//

#import "ViewController.h"
#import "YBPictureCutterView.h"

@interface ViewController () <YBPictureCutterViewDataSource, YBPictureCutterViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *tempImg;
@property (nonatomic, strong) YBPictureCutterView *cutterView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgView.userInteractionEnabled = YES;
    [self.imgView addSubview:self.cutterView];
}

#pragma mark - pictureCutterView dataSource & delegate

- (UIImage *)imageForPictureCutterView:(YBPictureCutterView *)cutterView {
    return self.imgView.image;
}

- (void)pictureCutterView:(YBPictureCutterView *)cutterView didClippedImage:(UIImage *)image {
    self.tempImg.image = image;
    NSLog(@"%@", NSStringFromCGSize(image.size));
}

#pragma mark - getter

- (YBPictureCutterView *)cutterView {
    if (!_cutterView) {
        _cutterView = [[YBPictureCutterView alloc] init];
        _cutterView.frame = self.imgView.bounds;
        _cutterView.dataSource = self;
        _cutterView.delegate = self;
    }
    return _cutterView;
}

@end
