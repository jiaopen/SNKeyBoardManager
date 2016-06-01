//
//  ViewController.m
//  SNKeyboardManagerDemo
//
//  Created by 苏合 on 16/2/14.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "ViewController.h"
#import "UITextField+SNKeyboardManager.h"
#import "UITextView+SNKeyboardManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *textField2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textField.sn_keyboardManagerEnabled = YES;
    _textField.sn_autoAdjustFrameEnabled = YES;
    _textView.sn_keyboardManagerEnabled = YES;
    _textField2.sn_keyboardManagerEnabled = YES;
    _textField2.sn_autoAdjustFrameEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
