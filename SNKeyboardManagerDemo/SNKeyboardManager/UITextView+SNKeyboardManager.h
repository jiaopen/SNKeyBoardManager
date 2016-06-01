//
//  UITextView+SNKeyboardManager.h
//  SNKeyboardManager
//
//  Created by 苏合 on 16/2/14.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (SNKeyboardManager)

/** Default is NO. */
@property(nonatomic, assign, getter=isKeyboardManagerEnabled) BOOL sn_keyboardManagerEnabled;

@end
