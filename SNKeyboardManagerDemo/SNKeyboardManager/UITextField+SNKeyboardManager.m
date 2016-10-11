//
//  UITextField+SNKeyboardManager.m
//  SNKeyboardManager
//
//  Created by 苏合 on 16/2/14.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "UITextField+SNKeyboardManager.h"
#import "UIView+SNRootView.h"
#import <objc/runtime.h>

#define kDEFAULT_KEYBORAD_DISTANCE 10.f


@interface UITextField ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *sn_tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *sn_panGestureRecognizer;
@property (nonatomic, assign, getter=isRectAdjusted) BOOL rectAdjusted;
@property (nonatomic, assign) BOOL haveOtherResponder;


@end

@implementation UITextField (SNKeyboardManager)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL selectors[] = {
            NSSelectorFromString(@"dealloc"),
            @selector(becomeFirstResponder),
            @selector(resignFirstResponder),
        };
        
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"sn_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            
            Method originalMethod = class_getInstanceMethod(self, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
            
            BOOL addedSuccess = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
            if (addedSuccess)
            {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            }
            else
            {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

-(void)sn_dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeGestureRecognizer];
    [self sn_dealloc];
}

-(void)sn_becomeFirstResponder
{
    [self sn_becomeFirstResponder];
}

-(void)sn_resignFirstResponder
{
    [self sn_resignFirstResponder];
    if (!CGRectEqualToRect(self.sn_rootView.frame, self.window.frame)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.haveOtherResponder) {
                [UIView animateWithDuration:0.2
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     self.sn_rootView.frame = self.window.frame;
                                 }
                                 completion:^(BOOL finished) {
                                     self.rectAdjusted = NO;
                                 }];
            }
        });
    }
}


- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    if (!self.window)
    {
        return;
    }
    if(!self.isFirstResponder)
    {
        self.haveOtherResponder = YES;
        [self removeGestureRecognizer];
        return;
    }
    self.haveOtherResponder = NO;
    if (!self.sn_tapGestureRecognizer)
    {
        self.sn_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.sn_tapGestureRecognizer.delegate = self;
        [self.sn_rootView addGestureRecognizer:self.sn_tapGestureRecognizer];
    }
    if (!self.sn_panGestureRecognizer)
    {
        self.sn_panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        self.sn_panGestureRecognizer.delegate = self;
        [self.sn_rootView addGestureRecognizer:self.sn_panGestureRecognizer];
    }
    
    if (self.isAutoAdjustFrameEnabled)
    {
        CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardRect = [self.sn_rootView convertRect:keyboardRect fromView:nil];
        CGRect rectInWindow = [self convertRect:self.bounds toView:self.window];
        rectInWindow = CGRectMake(0, rectInWindow.origin.y, self.window.frame.size.width, rectInWindow.size.height);
        
        CGRect rectOutsideKeyboard = CGRectMake(0.f, 64.f, keyboardRect.size.width, keyboardRect.origin.y - 64.f);
        double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        if (!CGRectContainsRect(rectOutsideKeyboard, rectInWindow))
        {
            CGFloat yOffset = self.sn_keyboardDistance + (rectInWindow.origin.y + rectInWindow.size.height) - keyboardRect.origin.y;
            [UIView animateWithDuration:duration
                                  delay:0.0f
                                options:[UIView sn_animationOptionsForCurve:curve]
                             animations:^{
                                 self.rectAdjusted = YES;
                                 self.sn_rootView.frame = CGRectOffset(self.sn_rootView.frame, 0, -yOffset);
                             }
                             completion:^(BOOL finished) {
                             }];
        }
    }
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    if (!self.sn_tapGestureRecognizer && !CGRectEqualToRect(self.sn_rootView.frame, self.window.frame)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 self.sn_rootView.frame = self.window.frame;
                             }
                             completion:^(BOOL finished) {
                                 self.rectAdjusted = NO;
                             }];
        });
    }
    [self removeGestureRecognizer];
}

- (void)handleDidHideKeyboard:(NSNotification *)notification
{
    self.haveOtherResponder = NO;
}

-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
}

#pragma mark GestureRecognizerHandle

- (void)tap:(UITapGestureRecognizer *)gestureRecognizer
{
    [self resignFirstResponder];
    [self.sn_rootView removeGestureRecognizer:gestureRecognizer];
    self.sn_tapGestureRecognizer = nil;
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self resignFirstResponder];
    [self.sn_rootView removeGestureRecognizer:gestureRecognizer];
    self.sn_panGestureRecognizer = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self.gestureRecognizers containsObject:otherGestureRecognizer])
    {
        return NO;
    }
    return YES;
}

#pragma mark - setter & getter

-(void)setSn_keyboardManagerEnabled:(BOOL)sn_keyboardManagerEnabled
{
    objc_setAssociatedObject(self, @selector(isKeyboardManagerEnabled), @(sn_keyboardManagerEnabled), OBJC_ASSOCIATION_ASSIGN);
    if (sn_keyboardManagerEnabled)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleWillShowKeyboard:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleWillHideKeyboard:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDidHideKeyboard:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
        
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

-(BOOL)isKeyboardManagerEnabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setSn_autoAdjustFrameEnabled:(BOOL)sn_autoAdjustFrameEnabled
{
    objc_setAssociatedObject(self, @selector(isAutoAdjustFrameEnabled), @(sn_autoAdjustFrameEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isAutoAdjustFrameEnabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSn_keyboardDistance:(CGFloat)sn_keyboardDistance
{
    objc_setAssociatedObject(self, @selector(sn_keyboardDistance), @(sn_keyboardDistance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)sn_keyboardDistance
{
    NSNumber *distance = objc_getAssociatedObject(self, _cmd);
    if (distance)
    {
        return [distance floatValue];
    }
    else
    {
        return kDEFAULT_KEYBORAD_DISTANCE;
    }
}

- (void)setRectAdjusted:(BOOL)rectAdjusted
{
    objc_setAssociatedObject(self, @selector(isRectAdjusted), @(rectAdjusted), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isRectAdjusted
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setHaveOtherResponder:(BOOL)haveOtherResponder
{
    objc_setAssociatedObject(self, @selector(haveOtherResponder), @(haveOtherResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)haveOtherResponder
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}


- (void)setSn_panGestureRecognizer:(UIPanGestureRecognizer *)sn_panGestureRecognizer
{
    objc_setAssociatedObject(self, @selector(sn_panGestureRecognizer), sn_panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIPanGestureRecognizer *)sn_panGestureRecognizer
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSn_tapGestureRecognizer:(UITapGestureRecognizer *)sn_tapGestureRecognizer
{
    objc_setAssociatedObject(self, @selector(sn_tapGestureRecognizer), sn_tapGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITapGestureRecognizer *)sn_tapGestureRecognizer
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)removeGestureRecognizer
{
    if (self.sn_tapGestureRecognizer)
    {
        [self.sn_rootView removeGestureRecognizer:self.sn_tapGestureRecognizer];
        self.sn_tapGestureRecognizer = nil;
    }
    if (self.sn_panGestureRecognizer)
    {
        [self.sn_rootView removeGestureRecognizer:self.sn_panGestureRecognizer];
        self.sn_panGestureRecognizer = nil;
    }
}

@end
