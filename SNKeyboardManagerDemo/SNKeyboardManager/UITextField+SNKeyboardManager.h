//
//  UITextField+SNKeyboardManager.h
//  SNKeyboardManager
//
//  Created by 苏合 on 16/2/14.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (SNKeyboardManager)

/** Default is NO. */
@property(nonatomic, assign, getter=isKeyboardManagerEnabled) BOOL sn_keyboardManagerEnabled;

/** Whether enable adjust the frame automatically, default is NO. */
@property(nonatomic, assign, getter=isAutoAdjustFrameEnabled) BOOL sn_autoAdjustFrameEnabled;

/** The distance between keyboard with text field after adjust frame, default is 10.f. */
@property(nonatomic, assign) CGFloat sn_keyboardDistance;

@end
