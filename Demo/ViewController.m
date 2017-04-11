//
//  ViewController.m
//  摄像
//
//  Created by 谢兴达 on 2017/3/1.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import "ViewController.h"
#import "SelectLabel.h"
#import "XDCamera.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self enterCameraUI];
}

//进入照相机
- (void)enterCameraUI {
    SelectLabel *enterCamera = [[SelectLabel alloc]initWithFrame:CGRectMake(15, 64, self.view.bounds.size.width - 30, 44)];
    enterCamera.backgroundColor = [UIColor redColor];
    enterCamera.text = @"照相机";
    enterCamera.clipsToBounds = YES;
    enterCamera.layer.cornerRadius = 5;
    enterCamera.textAlignment = NSTextAlignmentCenter;
    [enterCamera tapGestureBlock:^(id obj) {
        XDCamera *camera = [[XDCamera alloc]init];
        [self presentViewController:camera animated:YES completion:^{
            NSLog(@"进入照相机");
        }];
    }];
    [self.view addSubview:enterCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
