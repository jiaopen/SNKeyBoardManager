//
//  UITextView+SNKeyboardManager.m
//  SNKeyboardManager
//
//  Created by 苏合 on 16/2/14.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "UITextView+SNKeyboardManager.h"
#import "UIView+SNRootView.h"
#import <objc/runtime.h>

@interface UITextView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *sn_tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *sn_panGestureRecognizer;

@end

@implementation UITextView (SNKeyboardManager)

+ (void)load {
    SEL selectors[] = {
        NSSelectorFromString(@"dealloc"),
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index)
    {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"sn_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

-(void)sn_dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeGestureRecognizer];
    [self sn_dealloc];
}

- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    if(!self.isFirstResponder)
    {
        [self removeGestureRecognizer];
    }
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
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    [self removeGestureRecognizer];
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
    objc_setAssociatedObject(self, @selector(isKeyboardManagerEnabled), @(sn_keyboardManagerEnabled), OBJC_ASSOCIATION_RETAIN);
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

-(void)setSn_panGestureRecognizer:(UIPanGestureRecognizer *)sn_panGestureRecognizer
{
    objc_setAssociatedObject(self, @selector(sn_panGestureRecognizer), sn_panGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
}

-(UIPanGestureRecognizer *)sn_panGestureRecognizer
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setSn_tapGestureRecognizer:(UITapGestureRecognizer *)sn_tapGestureRecognizer
{
    objc_setAssociatedObject(self, @selector(sn_tapGestureRecognizer), sn_tapGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
}

-(UITapGestureRecognizer *)sn_tapGestureRecognizer
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
    if (self.panGestureRecognizer)
    {
        [self.sn_rootView removeGestureRecognizer:self.sn_panGestureRecognizer];
        self.sn_panGestureRecognizer = nil;
    }
}

@end
