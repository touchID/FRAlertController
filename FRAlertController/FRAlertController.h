//
//  FRAlertController.h
//  FRAlertController
//
//  Created by 1860 on 2016/12/10.
//  Copyright © 2016年 FanrongQu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FRAlertControllerStyle) {
    FRAlertControllerStyleActionSheet = 0,
    FRAlertControllerStyleAlert
} NS_ENUM_AVAILABLE_IOS(8_0);

@interface UIAlertAction (FRAdditions)
@property (nonatomic, copy, nullable) void (^actionBlock)(UIAlertAction *action);
@end

@interface FRAlertController : UIViewController

- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(FRAlertControllerStyle)preferredStyle;

/**
 创建一个 alert controller 对象

 @param title 标题
 @param message 消息内容
 @param preferredStyle 样式
 @return alert controller 实例
 */
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(FRAlertControllerStyle)preferredStyle;

/**
 添加一个动作按钮

 @param action 动作
 */
- (void)addAction:(UIAlertAction *)action;

/**
 添加一个文本输入框

 @param configurationHandler 配置处理闭包
 */
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;

/**
 显示 alert controller
 */
- (void)show;

/**
 标题
 */
@property (nonatomic, copy, nullable) NSString *title;

/**
 消息内容
 */
@property (nonatomic, copy, nullable) NSString *message;

/**
 样式
 */
@property (nonatomic, readonly) FRAlertControllerStyle preferredStyle;

/**
 动作按钮数组
 */
@property (nonatomic, readonly, copy) NSArray<UIAlertAction *> *actions;

/**
 文本输入框数组
 */
@property (nonatomic, readonly, copy) NSArray<UITextField *> *textFields;

/**
 首选动作（默认为 nil）
 */
@property (nonatomic, strong, nullable) UIAlertAction *preferredAction API_AVAILABLE(ios(9.0));

@end

NS_ASSUME_NONNULL_END