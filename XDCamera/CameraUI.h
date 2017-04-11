//
//  CameraUI.h
//  摄像
//
//  Created by 谢兴达 on 2017/3/3.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectView.h"
#import "SelectImageView.h"
typedef void (^neededViewBlock)(UIView *focusView, SelectView *previewView);

@protocol CameraUIDelegate <NSObject>
- (void)cancelClick;
- (void)onFlashClick;
- (void)autoFlashClick;
- (void)offFlashClick;
- (BOOL)changeBtClick;
- (void)cameraBtClick;
- (void)cameraLayerClick:(SelectView *)view gesture:(UITapGestureRecognizer *)gesture;
@end

@interface CameraUI : UIView
@property (nonatomic, weak) id<CameraUIDelegate> delegate;
- (void)viewsLinkBlock:(neededViewBlock)block;

@end
