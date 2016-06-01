//
//  SecondViewController.m
//  SNKeyboardManagerDemo
//
//  Created by 苏合 on 16/2/15.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "SecondViewController.h"
#import "UITextField+SNKeyboardManager.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];;
    _scrollview.contentSize = CGSizeMake(_scrollview.frame.size.width, 1000);
    _textField.sn_keyboardManagerEnabled = YES;
    _textField.sn_autoAdjustFrameEnabled = YES;
}

@end
