//
//  Preview.h
//  摄像
//
//  Created by 谢兴达 on 2017/3/6.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Preview : UIView
@property (nonatomic, copy) void (^cancelBlock)(void);
@property (nonatomic, copy) void (^submitBlock)(UIImage *image);
- (void)submitImage:(UIImage *)image;
@end
