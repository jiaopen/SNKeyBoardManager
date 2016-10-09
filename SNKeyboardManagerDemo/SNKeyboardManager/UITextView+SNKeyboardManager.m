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

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation UITextView (SNKeyboardManager)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL selectors[] = {
            NSSelectorFromString(@"dealloc"),
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

- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    if(!self.isFirstResponder)
    {
        [self removeGestureRecognizer];
    }
    if (!self.tapGestureRecognizer)
    {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.tapGestureRecognizer.delegate = self;
        [self.sn_rootView addGestureRecognizer:self.tapGestureRecognizer];
    }
    if (!self.panGestureRecognizer)
    {
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        self.panGestureRecognizer.delegate = self;
        [self.sn_rootView addGestureRecognizer:self.panGestureRecognizer];
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
    self.tapGestureRecognizer = nil;
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self resignFirstResponder];
    [self.sn_rootView removeGestureRecognizer:gestureRecognizer];
    self.panGestureRecognizer = nil;
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
    objc_setAssociatedObject(self, @selector(isKeyboardManagerEnabled), @(sn_keyboardManagerEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

-(void)setPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    objc_setAssociatedObject(self, @selector(panGestureRecognizer), panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIPanGestureRecognizer *)panGestureRecognizer
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    objc_setAssociatedObject(self, @selector(tapGestureRecognizer), tapGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UITapGestureRecognizer *)tapGestureRecognizer
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)removeGestureRecognizer
{
    if (self.tapGestureRecognizer)
    {
        [self.sn_rootView removeGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer = nil;
    }
    if (self.panGestureRecognizer)
    {
        [self.sn_rootView removeGestureRecognizer:self.panGestureRecognizer];
        self.panGestureRecognizer = nil;
    }
}

@end
