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
@property (nonatomic, strong) YBPictureCutterView *cutterView;
@property (weak, nonatomic) IBOutlet UIImageView *tempImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgView.userInteractionEnabled = YES;
    [self.imgView addSubview:self.cutterView];
    
    UIView *v1 = [[UIView alloc] init];
    v1.frame = CGRectMake(50, 290, 100, 50);
    v1.backgroundColor = [UIColor redColor];
    [self.view addSubview:v1];
    
    UIView *v2 = [[UIView alloc] init];
    v2.frame = CGRectInset(v1.frame, -10, -10);
    v2.backgroundColor = [UIColor greenColor];
    [self.view addSubview:v2];
}

#pragma mark - pictureCutterView dataSource

- (UIImage *)imageForPictureCutterView:(YBPictureCutterView *)cutterView {
    return self.imgView.image;
}

- (void)pictureCutterView:(YBPictureCutterView *)cutterView didClippedImage:(UIImage *)image {
    self.tempImg.image = image;
    NSLog(@"%@", NSStringFromCGSize(image.size));
}

#pragma mark - actions

- (IBAction)sureClick:(id)sender {
    //
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
