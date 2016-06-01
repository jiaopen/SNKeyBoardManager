# SNKeyboardManager

[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jiaopen/MRRouter/blob/master/LICENSE.md)

## About
SNKeyboardManager is a extend of UITextField/UITextView, you can control the keyboard event with a boolean property of UITextFiled/UITextView automatically and conviniently.


## Usage
###tap or pan blank to turn of the keyboard：

```objc
    _textField.sn_keyboardManagerEnabled = YES;
    _textView.sn_keyboardManagerEnabled = YES;
```
![image](https://github.com/jiaopen/SNKeyBoardManager/blob/master/screenshot1.gif)

###Adjust the position of view when keyboard is showeing and dismissing：

```objc
    _textField.sn_autoAdjustFrameEnabled = YES;
```
![image](https://github.com/jiaopen/SNKeyBoardManager/blob/master/screenshot2.gif)

## Requirements
iOS 7.0+.

## License
SNKeyboardManager is licensed under the [MIT License](http://opensource.org/licenses/mit-license.php).
