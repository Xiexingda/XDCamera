//
//  Preview.m
//  摄像
//
//  Created by 谢兴达 on 2017/3/6.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import "Preview.h"
#import "SelectImageView.h"

@interface Preview ()
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) SelectImageView *cancel;
@property (nonatomic, strong) SelectImageView *submit;
@property (nonatomic, strong) SelectImageView *preview;

@property (nonatomic, strong) UIImage *previewImage;
@end

@implementation Preview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self creatMainUI];
    }
    return self;
}

/**
 照相机界面
 */
- (void)creatMainUI {
    _header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
    _header.backgroundColor = [UIColor greenColor];
    
    _cancel = [[SelectImageView alloc]initWithFrame:CGRectMake(15, 20, 40, 40)];
    _cancel.backgroundColor = [UIColor grayColor];
    [_header addSubview:_cancel];
    [_cancel tapGestureBlock:^(id obj) {
        if (_cancelBlock) {
            _cancelBlock();
        }
    }];
    
    _submit = [[SelectImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_header.frame) - 55, 20, 40, 40)];
    _submit.backgroundColor = [UIColor redColor];
    [_header addSubview:_submit];
    [_submit tapGestureBlock:^(id obj) {
        if (_submitBlock) {
            _submitBlock(_previewImage);
        }
    }];
    
    self.preview = [[SelectImageView alloc]initWithFrame:CGRectMake(0,
                                                                    CGRectGetMaxY(_header.frame),
                                                                    CGRectGetWidth(_header.frame),
                                                                    self.frame.size.height - CGRectGetHeight(_header.frame))];
    _preview.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.preview];
    [self addSubview:_header];
    [_preview tapGestureBlock:^(id obj) {
        NSLog(@"单机");
        
    }];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapClick)];
    gesture.numberOfTapsRequired = 2;
    [_preview addGestureRecognizer:gesture];
}

- (void)doubleTapClick {
    NSLog(@"shuangji");
    [UIView animateWithDuration:1 animations:^{
        _preview.transform=CGAffineTransformMakeScale(2, 2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            _preview.transform = CGAffineTransformIdentity;
        }];
    }];
    
}

- (void)submitImage:(UIImage *)image {
    _previewImage = image;
    self.preview.image = image;
}

@end
