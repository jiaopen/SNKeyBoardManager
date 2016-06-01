//
//  UIView+SNExtensions.m
//  SNKeyboardManager
//
//  Created by 苏合 on 16/1/21.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "UIView+SNRootView.h"
#import <objc/runtime.h>

@implementation UIView (SNRootView)

- (UIView *)sn_rootView
{
    UIView *superView = self.superview;
    if ([NSStringFromClass([superView class]) isEqualToString:@"UIViewControllerWrapperView"])
    {
          return self;
    }
    else
    {
        return superView.sn_rootView;
    }
}

- (UIView *)sn_containerView
{
    UIView *superView = self.superview;
    if (superView == self.sn_rootView)
    {
        return self;
    }
    else
    {
        return superView.sn_containerView;
    }
}

+ (UIViewAnimationOptions)sn_animationOptionsForCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
    }
    
    return kNilOptions;
}

@end
