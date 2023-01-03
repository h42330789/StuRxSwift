//
//  UNNotificationViewController.swift
//  StuRxSwift
//
//  Created by aaa on 12/31/22.
//

import UIKit
import RxSwift
import RxCocoa

class UNNotificationViewController: BaseViewController {

    lazy var btn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 60))
        btn.setTitle("通知", for: .normal)
        btn.setTitleColor(.orange, for: .normal)
        view.addSubview(btn)
        return btn
    }()
    
    lazy var sendLocalBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 100, y: btn.frame.maxY+10, width: 100, height: 60))
        btn.setTitle("本地通知", for: .normal)
        btn.setTitleColor(.orange, for: .normal)
        view.addSubview(btn)
        return btn
    }()
    
    lazy var showLocalBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 100, y: sendLocalBtn.frame.maxY+10, width: 100, height: 60))
        btn.setTitle("print", for: .normal)
        btn.setTitleColor(.orange, for: .normal)
        view.addSubview(btn)
        return btn
    }()
    
    lazy var showLabel: UILabel = {
        let v = UILabel(frame: CGRect(x: 100, y: showLocalBtn.frame.maxY+10, width: 100, height: 80))
        v.numberOfLines = 0
        v.textColor = .black
        view.addSubview(v)
        return v
    }()
    
    lazy var nameField: UITextField = {
        let v = UITextField(frame: CGRect(x: 100, y: showLabel.frame.maxY+10, width: 200, height: 30))
        v.borderStyle = .roundedRect
        v.placeholder = "请输入姓名"
        view.addSubview(v)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.checkSetting()
        }).disposed(by: disposeBag)
        
        sendLocalBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.sendLocalNoti()
        }).disposed(by: disposeBag)
        
        showLocalBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.showNotify()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UITextField.textDidChangeNotification, object: nameField)
            .subscribe(onNext: { [weak self] notify in
                guard let textField = notify.object as? UITextField,
                      textField == self?.nameField else {
                    return
                }
                
                if let range: UITextRange = textField.markedTextRange,
                   !range.isEmpty {
                    // 不存在markedRange才处理，有markedRange属于输入过程中，比如输入中文时使用拼音输入的中间过程
                    return
                }
                
                // 当前光标的位置（后面会对其做修改）
                let cursorPostion = textField.offset(from: textField.endOfDocument,
                                                     to: textField.selectedTextRange!.end)
                // 判断非中文的正则表达式
                var pattern = "[^\\u4E00-\\u9FA5]"
                pattern = "[^0-9]"
                
                // 替换后的字符串（过滤调非中文字符）
                var text = textField.text ?? ""
                text = text.pregReplace(pattern: pattern, with: "")
                if text.count > 5 {
                    text = String(text.prefix(5))
                }
                textField.text = text
                 
                // 让光标停留在正确位置
                let targetPostion = textField.position(from: textField.endOfDocument,
                                                       offset: cursorPostion)!
                textField.selectedTextRange = textField.textRange(from: targetPostion,
                                                                  to: targetPostion)
            })
            .disposed(by: disposeBag)
    }
    
    func showNotify() {
        guard let appdele = UIApplication.shared.delegate as? AppDelegate,
              let notiContent = appdele.notiContent else {
            return
        }
        appdele.notiContent = nil
        print(notiContent.title)
        print(notiContent.body)
        // 获取通知附加数据
        let userInfo = notiContent.userInfo
        print(userInfo)
        
        showLabel.text = notiContent.title
    }
    
    func sendLocalNoti() {
        // 设置推送内容
        let content = UNMutableNotificationContent()
        content.title = "hello.com"
        content.body = "body 内容--"
        content.userInfo = ["userName": "hangge", "articleId": 10086]
         
        // 设置通知触发器
//        let trigger1 = UNTimeIntervalNotificationTrigger(timeInterval:1, repeats: false)
//        let dis = Date().timeIntervalSince1970 - (trigger1.nextTriggerDate()?.timeIntervalSince1970 ?? 0)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // 设置请求标识符
        let requestIdentifier = "com.hello.testNotification"
         
        // 设置一个通知请求
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
         
        // 将通知请求添加到发送中心
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                print("Time Interval Notification scheduled: \(requestIdentifier)")
            }
        }
    }
    
    func checkSetting() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("authorized")
                self?.checkAllowSettingList(settings)
            case .notDetermined:
                // 没有设置过
                // 请求授权
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { accepted, _ in
                    if !accepted {
                        print("用户不允许通知")
                    }
                }
            case .denied:
                self?.goSetting()
            case .provisional:
                print("provisional")
            case .ephemeral:
                print("ephemeral")
            @unknown default:
                print("")
            }
        
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func checkAllowSettingList(_ settings: UNNotificationSettings) {
        var message = "是否允许通知："
        switch settings.authorizationStatus {
        case .authorized:
            message.append("允许")
        case .notDetermined:
            message.append("未确定")
        case .denied:
            message.append("不允许")
        case .provisional:
            message.append("provisional")
        case .ephemeral:
            message.append("ephemeral")
        @unknown default:
            message.append("---")
        }
         
        message.append("\n声音：")
        switch settings.soundSetting {
        case .enabled:
            message.append("开启")
        case .disabled:
            message.append("关闭")
        case .notSupported:
            message.append("不支持")
        @unknown default:
            message.append("---")
        }
         
        message.append("\n应用图标标记：")
        switch settings.badgeSetting {
        case .enabled:
            message.append("开启")
        case .disabled:
            message.append("关闭")
        case .notSupported:
            message.append("不支持")
        @unknown default:
            message.append("---")
        }
         
        message.append("\n在锁定屏幕上显示：")
        switch settings.lockScreenSetting {
        case .enabled:
            message.append("开启")
        case .disabled:
            message.append("关闭")
        case .notSupported:
            message.append("不支持")
        @unknown default:
            message.append("---")
        }
         
        message.append("\n在历史记录中显示：")
        switch settings.notificationCenterSetting {
        case .enabled:
            message.append("开启")
        case .disabled:
            message.append("关闭")
        case .notSupported:
            message.append("不支持")
        @unknown default:
            message.append("---")
        }
         
        message.append("\n横幅显示：")
        switch settings.alertSetting {
        case .enabled:
            message.append("开启")
        case .disabled:
            message.append("关闭")
        case .notSupported:
            message.append("不支持")
        @unknown default:
            message.append("---")
        }
         
        message.append("\n显示预览：")
        switch settings.showPreviewsSetting {
        case .always:
            message.append("始终（默认）")
        case .whenAuthenticated:
            message.append("解锁时")
        case .never:
            message.append("从不")
        @unknown default:
            message.append("---")
        }
        
        print(message)
    }
    // swiftlint:enable cyclomatic_complexity
    
    func goSetting() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "消息推送已关闭",
                                                    message: "想要及时获取消息。点击“设置”，开启通知。",
                                                    preferredStyle: .alert)
                         
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
             
            let settingsAction = UIAlertAction(title: "设置",
                                               style: .default,
                                               handler: { _ -> Void in
                let url = URL(string: UIApplication.openSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url,
                                                  options: [:],
                                                  completionHandler: { _ in
                        })
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            })
             
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
             
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension String {
    // 使用正则表达式替换
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try? NSRegularExpression(pattern: pattern, options: options)
        return regex?.stringByReplacingMatches(in: self,
                                               options: [],
                                               range: NSRange(location: 0, length: self.count),
                                              withTemplate: with) ?? ""
    }
}
