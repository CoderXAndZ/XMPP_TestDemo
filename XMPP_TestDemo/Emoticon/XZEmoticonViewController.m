//
//  XZEmoticonViewController.m
//  XMPP_TestDemo
//
//  Created by admin on 2018/6/25.
//  Copyright © 2018年 XZ. All rights reserved.
//

#import "XZEmoticonViewController.h"
#import "XZEmoticonTextView.h"
#import "XZEmoticonInputView.h"

@interface XZEmoticonViewController ()

@property (strong, nonatomic) XZEmoticonTextView *textView;

@end

@implementation XZEmoticonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  1. 设置用户标示 - 用于保存最近使用表情
    [XZEmoticonManager sharedManager].userIdentifier = @"t6";
    // 2. 设置表情输入视图
    [self setupTextView];
    // 3. 监听键盘通知
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillChanged:)
     name:UIKeyboardWillChangeFrameNotification
     object:nil];
    
    // 4. 通过表情描述字符串设置属性字符串
    NSString *text = @"[爱你]啊[爱你]";
    NSAttributedString *attributeText = [[XZEmoticonManager sharedManager]
                                         emoticonStringWithString:text
                                         font:_textView.font
                                         textColor:_textView.textColor];
    _textView.attributedText = attributeText;
    
    [self setupLeftItem];
    
}

#pragma mark - 监听方法
/// 切换输入视图
- (void)switchInputView {
    _textView.useEmoticonInputView = !_textView.isUseEmoticonInputView;
}

/// 显示转换后的表情符号文本，可以用户网络传输
- (void)sendMsg {
    NSLog(@"%@", _textView.emoticonText);
}

#pragma mark - 设置导航栏
- (void)setupLeftItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换键盘" style:UIBarButtonItemStyleDone target:self action:@selector(switchInputView)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendMsg)];;
}

- (void)setupTextView {
    self.textView = [[XZEmoticonTextView alloc] initWithFrame:CGRectMake(50, 100, 200, 40)];
    [self.view addSubview:self.textView];
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textView.layer.borderWidth = 1.0f;
    
    // 1> 使用表情视图
    _textView.useEmoticonInputView = YES;
    // 2> 设置占位文本
    _textView.placeholder = @"请输入...";
    // 3> 设置最大文本长度
    _textView.maxInputLength = 140;
}

#pragma mark --- 键盘的监听方法
- (void)keyboardWillChanged:(NSNotification *)notification {
    
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
//    _bottomConstraint.constant = self.view.bounds.size.height - rect.origin.y;
//    [UIView animateWithDuration:duration animations:^{
//        [self.view layoutIfNeeded];
//    }];
    self.textView.frame = CGRectMake(50, 100, 200, 40);
    
    CGFloat height = rect.size.height;
    
    NSLog(@"rect ======= %f",height);
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
