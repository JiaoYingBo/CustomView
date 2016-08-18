//
//  FirstViewController.m
//  PhotoCustom
//
//  Created by Mac on 16/6/6.
//  Copyright © 2016年 yb. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgView.image = self.image;
    self.height.constant = self.imgFrame.size.height;
    self.width.constant = self.imgFrame.size.width;
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
