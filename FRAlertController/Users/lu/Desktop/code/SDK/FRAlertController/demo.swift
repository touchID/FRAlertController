// 创建 alert controller
let alert = FRAlertController(title: "标题", message: "消息内容", preferredStyle: .alert)

// 添加文本输入框
alert.addTextField { textField in
    textField.placeholder = "请输入内容"
}

// 添加动作按钮
let cancelAction = UIAlertAction(title: "取消", style: .cancel) { action in
    print("取消操作")
}

let confirmAction = UIAlertAction(title: "确认", style: .default) { action in
    if let text = alert.textFields.first?.text {
        print("输入的内容: \(text)")
    }
}

// 设置首选动作
alert.preferredAction = confirmAction

// 添加动作
alert.addAction(cancelAction)
alert.addAction(confirmAction)

// 显示
alert.show()


- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;
