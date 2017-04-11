//
//  CameraUI.m
//  摄像
//
//  Created by 谢兴达 on 2017/3/3.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import "CameraUI.h"

@interface CameraUI ()
@property (nonatomic, strong) SelectImageView *onFlash;     //打开闪光灯
@property (nonatomic, strong) SelectImageView *autoFlash;   //自动闪光灯
@property (nonatomic, strong) SelectImageView *offFlash;    //关闭闪光灯
@property (nonatomic, strong) SelectImageView *changeBt;    //切换摄像头
@property (nonatomic, strong) SelectImageView *cameraBt;    //拍照按钮
@property (nonatomic, strong) SelectView *cameraLayerView;  //实时预览层
@property (nonatomic, strong) UIView *focusView;            //聚焦视图
@property (nonatomic, strong) UIView *headerContent;        //
@property (nonatomic, strong) UIView *footerContent;        //
@property (nonatomic, strong) SelectImageView *cancel;      //取消按钮
@end

@implementation CameraUI
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatMainUI];
    }
    return self;
}

- (void)creatMainUI {
    [self creatHeader];
}

- (void)creatHeader {
    _headerContent = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                             0,
                                                             self.frame.size.width,
                                                             60)];
    _headerContent.backgroundColor = [UIColor greenColor];
    [self addSubview:_headerContent];
    
    _cancel = [[SelectImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_headerContent.frame) + 15,
                                                               20,
                                                               40,
                                                               40)];
    _cancel.backgroundColor = [UIColor grayColor];
    [_headerContent addSubview:_cancel];
    [_cancel tapGestureBlock:^(id obj) {
        [self.delegate cancelClick];
    }];
    
    _onFlash = [[SelectImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_cancel.frame) + 15,
                                                                20,
                                                                40,
                                                                40)];
    _onFlash.backgroundColor = [UIColor whiteColor];
    [_headerContent addSubview:_onFlash];
    [_onFlash tapGestureBlock:^(id obj) {
        //闪光灯开
        [self.delegate onFlashClick];
    }];
    
    _autoFlash = [[SelectImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_onFlash.frame) + 5,
                                                                  20,
                                                                  40,
                                                                  40)];
    _autoFlash.backgroundColor = [UIColor blueColor];
    [_headerContent addSubview:_autoFlash];
    [_autoFlash tapGestureBlock:^(id obj) {
       //自动闪光灯
        [self.delegate autoFlashClick];
    }];
    
    _offFlash = [[SelectImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_autoFlash.frame) + 5,
                                                                 20,
                                                                 40,
                                                                 40)];
    _offFlash.backgroundColor = [UIColor blackColor];
    [_headerContent addSubview:_offFlash];
    [_offFlash tapGestureBlock:^(id obj) {
       //关闭闪光灯
        [self.delegate offFlashClick];
    }];
    
    _changeBt = [[SelectImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headerContent.frame) - 55,
                                                                 20,
                                                                 40,
                                                                 40)];
    _changeBt.backgroundColor = [UIColor redColor];
    [_headerContent addSubview:_changeBt];
    
    [_changeBt tapGestureBlock:^(id obj) {
        if ([self.delegate changeBtClick]) {
            NSLog(@"后置摄像头");
            
        } else {
            NSLog(@"前置摄像头");
        }
    }];
    
    [self creatLayerView];
}

- (void)creatLayerView {
    _cameraLayerView = [[SelectView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_headerContent.frame),
                                                                   CGRectGetMaxY(_headerContent.frame),
                                                                   CGRectGetWidth(_headerContent.frame),
                                                                   self.frame.size.height - 120)];
    _cameraLayerView.backgroundColor = [UIColor blackColor];
    [self addSubview:_cameraLayerView];
    [_cameraLayerView tapGestureBlock:^(UITapGestureRecognizer *gesture) {
        [self.delegate cameraLayerClick:_cameraLayerView gesture:gesture];
    }];
    
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    _focusView.backgroundColor = [UIColor yellowColor];
    _focusView.alpha = 0;
    [_cameraLayerView addSubview:_focusView];
    
    [self creatFooter];
}

- (void)creatFooter {
    _footerContent = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_cameraLayerView.frame),
                                                             CGRectGetMaxY(_cameraLayerView.frame),
                                                             CGRectGetWidth(_cameraLayerView.frame),
                                                             60)];
    _footerContent.backgroundColor = [UIColor greenColor];
    [self addSubview:_footerContent];
    
    _cameraBt = [[SelectImageView alloc]initWithFrame:CGRectMake(CGRectGetMidX(_footerContent.frame) - 40,
                                                                 10,
                                                                 80,
                                                                 40)];
    _cameraBt.backgroundColor = [UIColor grayColor];
    [_footerContent addSubview:_cameraBt];
    [_cameraBt tapGestureBlock:^(id obj) {
        [self.delegate cameraBtClick];
    }];
}

- (void)viewsLinkBlock:(neededViewBlock)block {
    if (block) {
        block(_focusView,_cameraLayerView);
    }
}
@end
