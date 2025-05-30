//
//  FRAlertController.m
//  FRAlertController
//
//  Created by 1860 on 2016/12/10.
//  Copyright © 2016年 FanrongQu. All rights reserved.
//

#import "FRAlertController.h"

@interface UIAlertAction (FRAdditionsPrivate)
@property (nonatomic, copy, readwrite, nullable) void (^actionBlock)(UIAlertAction *action);
@end

@implementation UIAlertAction (FRAdditionsPrivate)
@dynamic actionBlock;

- (void)setActionBlock:(void (^)(UIAlertAction *))actionBlock {
    objc_setAssociatedObject(self, @selector(actionBlock), actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIAlertAction *))actionBlock {
    return objc_getAssociatedObject(self, @selector(actionBlock));
}
@end

@interface FRAlertController ()

/** alert类型 */
@property (nonatomic, assign) FRAlertControllerStyle alertPreferredStyle;
/** 背景 */
@property (nonatomic, strong) UIView *contentView;
/** 标题标签 */
@property (nonatomic, strong) UILabel *titleLabel;
/** 消息标签 */
@property (nonatomic, strong) UILabel *messageLabel;
/** 动作按钮数组 */
@property (nonatomic, strong) NSMutableArray<UIAlertAction *> *mutableActions;
/** 文本输入框数组 */
@property (nonatomic, strong) NSMutableArray<UITextField *> *mutableTextFields;
/** 按钮数组 */
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
/** 首选动作 */
@property (nonatomic, strong, nullable) UIAlertAction *preferredAction;

@end

@implementation FRAlertController

#pragma mark - Initialization

- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(FRAlertControllerStyle)preferredStyle {
    self = [super init];
    if (self) {
        _title = title;
        _message = message;
        _alertPreferredStyle = preferredStyle;
        _mutableActions = [NSMutableArray array];
        _mutableTextFields = [NSMutableArray array];
        _buttons = [NSMutableArray array];
        
        // 弹出的视图透明
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        } else {
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
    }
    return self;
}

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(FRAlertControllerStyle)preferredStyle {
    return [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
}

#pragma mark - Getters

- (NSArray<UIAlertAction *> *)actions {
    return [self.mutableActions copy];
}

- (NSArray<UITextField *> *)textFields {
    return [self.mutableTextFields copy];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
    
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 显示视图时背景色渐显
    if (self.alertPreferredStyle == FRAlertControllerStyleActionSheet) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.1 animations:^{
                weakSelf.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
            }];
        });
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    }
    
    // 布局视图
    [self layoutViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
}

#pragma mark - Setup UI

- (void)setupSubviews {
    // 背景视图
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 13.0;
    self.contentView.layer.masksToBounds = YES;
    [self.view addSubview:self.contentView];
    
    // 标题标签
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];
    
    // 消息标签
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.numberOfLines = 0;
    [self.contentView addSubview:self.messageLabel];
    
    // 设置文本
    self.titleLabel.text = self.title;
    self.messageLabel.text = self.message;
}

#pragma mark - Actions

- (void)addAction:(UIAlertAction *)action {
    [self.mutableActions addObject:action];
    
    // 创建按钮并设置样式
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:action.title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    
    if (action.style == UIAlertActionStyleDestructive) {
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    } else if (action.style == UIAlertActionStyleCancel) {
        [button setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    } else {
        [button setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    }
    
    // 设置首选动作样式
    if (action == self.preferredAction) {
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    }
    
    [button addTarget:self action:@selector(actionButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = self.buttons.count;
    [self.buttons addObject:button];
    [self.contentView addSubview:button];
}

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler {
    UITextField *textField = [[UITextField alloc] init];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.mutableTextFields addObject:textField];
    [self.contentView addSubview:textField];
    
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

- (void)actionButtonDidClicked:(UIButton *)sender {
    // 根据 tag 取到 handler
    UIAlertAction *action = self.actions[sender.tag];
    if (action.actionBlock) {
        action.actionBlock(action);
    }
    
    // 点击 button 后自动 dismiss
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Show

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:YES completion:nil];
    });
}

#pragma mark - Layout

- (void)layoutViews {
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if (self.alertPreferredStyle == FRAlertControllerStyleActionSheet) {
        // ActionSheet 样式
        [NSLayoutConstraint activateConstraints:@[
            [self.contentView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
            [self.contentView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10],
            [self.contentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-10]
        ]];
    } else {
        // Alert 样式
        [NSLayoutConstraint activateConstraints:@[
            [self.contentView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [self.contentView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
            [self.contentView.widthAnchor constraintLessThanOrEqualToConstant:300]
        ]];
    }
    
    // 布局标题和消息
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:(self.title && self.message) ? 10 : 0],
        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16]
    ]];
    
    // 布局文本输入框
    UIView *lastView = self.messageLabel;
    for (UITextField *textField in self.textFields) {
        [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [NSLayoutConstraint activateConstraints:@[
            [textField.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:10],
            [textField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [textField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [textField.heightAnchor constraintEqualToConstant:36]
        ]];
        lastView = textField;
    }
    
    // 按钮数量为2且样式为Alert时按钮水平布局
    if (2 == self.buttons.count && FRAlertControllerStyleAlert == _alertPreferredStyle) {
        [self layoutButtonsHorizontally];
    } else {
        [self layoutButtonsVertically];
    }
}

- (void)layoutButtonsHorizontally {
    UIButton *leftButton = self.buttons[0];
    UIButton *rightButton = self.buttons[1];
    UIView *topView = self.textFields.lastObject ?: self.messageLabel;
    
    [leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rightButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [NSLayoutConstraint activateConstraints:@[
        [leftButton.topAnchor constraintEqualToAnchor:topView.bottomAnchor constant:14],
        [leftButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [leftButton.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-12],
        [leftButton.heightAnchor constraintEqualToConstant:44],
        
        [rightButton.leadingAnchor constraintEqualToAnchor:leftButton.trailingAnchor constant:10],
        [rightButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [rightButton.centerYAnchor constraintEqualToAnchor:leftButton.centerYAnchor],
        [rightButton.widthAnchor constraintEqualToAnchor:leftButton.widthAnchor]
    ]];
}

- (void)layoutButtonsVertically {
    UIView *lastView = self.textFields.lastObject ?: self.messageLabel;
    
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [NSLayoutConstraint activateConstraints:@[
            [button.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:(i == 0) ? 14 : 0.5],
            [button.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [button.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [button.heightAnchor constraintEqualToConstant:44]
        ]];
        
        if (i == self.buttons.count - 1) {
            [button.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
        }
        
        lastView = button;
    }
}

@end