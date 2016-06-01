//
//  UIView+SNExtensions.h
//  SNKeyboardManager
//
//  Created by 苏合 on 16/1/21.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SNRootView)

/** 当前view所在的rootView，window的下一级 */
@property (nonatomic, strong, readonly) UIView *sn_rootView;

/** 当前view的容器view，如果当前view是rootview的subview，则直接返回当前view */
@property (nonatomic, strong, readonly) UIView *sn_containerView;

+ (UIViewAnimationOptions)sn_animationOptionsForCurve:(UIViewAnimationCurve)curve;

@end
