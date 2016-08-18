//
//  ViewController.m
//  PhotoCustom
//
//  Created by Mac on 16/6/6.
//  Copyright © 2016年 yb. All rights reserved.
//

#import "ViewController.h"
#import "YBPhotoCutView.h"
#import "FirstViewController.h"

@interface ViewController ()<YBPhotoCutViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) UIImage *shotImage;
@property (nonatomic, strong) YBPhotoCutView *customView;
@property (nonatomic, assign) CGRect shotFrame;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shotFrame = CGRectMake(50, 150, 275, 275);
    
    self.customView = [[YBPhotoCutView alloc] initWithFrame:self.imgView.frame pictureFrame:self.shotFrame];
    self.customView.delegate = self;
    self.customView.minWidth = 100;
    self.customView.minHeight = 100;
    [self.view addSubview:self.customView];
    
}

#pragma mark - YBPhotoCutViewDelegate
- (void)photoCutView:(YBPhotoCutView *)customView shotFrame:(CGRect)frame {
    NSLog(@"%@",NSStringFromCGRect(frame));
    self.shotFrame = frame;
}

- (IBAction)shoot:(id)sender {
    // 按比例计算图片上的frame
    CGFloat x = self.shotFrame.origin.x / self.imgView.frame.size.width * self.imgView.image.size.width;
    CGFloat y = self.shotFrame.origin.y / self.imgView.frame.size.height * self.imgView.image.size.height;
    CGFloat w = self.shotFrame.size.width / self.imgView.frame.size.width * self.imgView.image.size.width;
    CGFloat h = self.shotFrame.size.height / self.imgView.frame.size.height * self.imgView.image.size.height;
    
    // 截图
    CGRect cropRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.imgView.image CGImage], cropRect) ;
    self.shotImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    FirstViewController *vc = [[FirstViewController alloc] init];
    vc.image = self.shotImage;
    vc.imgFrame = self.shotFrame;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
