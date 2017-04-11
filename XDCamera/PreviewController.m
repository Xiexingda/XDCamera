//
//  PreviewController.m
//  摄像
//
//  Created by 谢兴达 on 2017/3/6.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import "PreviewController.h"
#import "Preview.h"

@interface PreviewController ()

@end

@implementation PreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self creatMainUI];
}

- (void)creatMainUI {
    Preview *view = [[Preview alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [view submitImage:_previewImage];
    [self clickBlockOnView:view];
    [self.view addSubview:view];
}

- (void)clickBlockOnView:(Preview *)view {
    view.cancelBlock = ^{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    
    view.submitBlock = ^(UIImage *image) {
        [self dismissViewControllerAnimated:YES completion:^{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
