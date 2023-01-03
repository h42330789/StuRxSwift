//
//  RxFeedBack2ViewController.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

class RxFeedBack2ViewController: BaseViewController {

    lazy var nameText = createTextField(preView: nil, placeHolder: "请输入用户名")
    lazy var nameLabel = createLabel(preView: nameText)
    lazy var pwdText = createTextField(preView: nameLabel, placeHolder: "密码")
    lazy var pwdLabel = createLabel(preView: pwdText)
    lazy var repeatedPwdText = createTextField(preView: pwdLabel, placeHolder: "再次输入密码")
    lazy var repeatedPwdLabel = createLabel(preView: repeatedPwdText)
    lazy var registerBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 10, y: repeatedPwdLabel.frame.maxY + 20, width: view.bounds.size.width-20, height: 40))
        btn.backgroundColor = .blue
        btn.setTitle("注册", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        view.addSubview(btn)
        return btn
    }()
    
    struct State {
        var username: String? // 用户名
        var password: String? // 密码
        var repeatedPassword: String? // 再次输入密码
        var usernameValidationResult: ValidationResult // 用户名验证结果
        var passwordValidationResult: ValidationResult // 密码验证结果
        var repeatedPasswordValidationResult: ValidationResult // 再次输入密码验证结果
        var startSignup: Bool // 开始注册
        var signupResult: Bool? // 注册结果
        
        var signupData: (username: String, password: String)? {
            return startSignup ? (username ?? "", password ?? "") : nil
        }
        
        // 返回初始化状态
        static var empty: State {
            return State(username: nil,
                         password: nil,
                         repeatedPassword: nil,
                         usernameValidationResult: ValidationResult.empty,
                         passwordValidationResult: ValidationResult.empty,
                         repeatedPasswordValidationResult: ValidationResult.empty,
                         startSignup: false,
                         signupResult: nil)
        }
    }
    
    // 事件
    enum Event {
        case usernameChanged(String) // 用户名输入
        case passwordChanged(String) // 密码输入
        case repeatedPasswordChanged(String) // 重复密码输入
        case usernameValidated(ValidationResult) // 用户名验证结束
        case signup // 用户注册
        case signupResponse(Bool) // 注册响应
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "注册"
        
        // GitHub网络请求服务
        _ = GitHubNetworkService()
         
        // 用户注册服务
        let signupService = GitHubSignupService()
        
        Driver.system(
            initialState: State.empty,
            reduce: { (state, event) in
                switch event {
                case .usernameChanged(let value):
                    var result = state
                    result.username = value
                    result.signupResult = nil // 防止弹出框重复弹出
                    return result
                case .passwordChanged(let value):
                    var result = state
                    result.password = value
                    // 验证密码
                    result.passwordValidationResult =
                        signupService.validatePassword(result.password ?? "")
                    // 验证密码重复输入
                    if result.repeatedPassword != nil {
                        result.repeatedPasswordValidationResult =
                            signupService.validateRepeatedPassword(
                                result.password ?? "",
                                repeatedPassword: result.repeatedPassword ?? ""
                        )
                    }
                    result.signupResult = nil
                    return result
                case .repeatedPasswordChanged(let value):
                    var result = state
                    result.repeatedPassword = value
                    // 验证密码重复输入
                    result.repeatedPasswordValidationResult =
                        signupService.validateRepeatedPassword(
                            result.password ?? "",
                            repeatedPassword: result.repeatedPassword ?? ""
                        )
                    result.signupResult = nil
                    return result
                case .usernameValidated(let value):
                    var result = state
                    result.usernameValidationResult = value
                    result.signupResult = nil
                    return result
                case .signup:
                    var result = state
                    result.startSignup = true
                    result.signupResult = nil
                    return result
                case .signupResponse(let value):
                    var result = state
                    result.startSignup = false
                    result.signupResult = value
                    return result
                }
            },
            // UI反馈
            feedback: bind(self) { (me, state) -> Bindings<RxFeedBack2ViewController.Event> in
                // 状态输出到页面控件上
                let subscriptions: [Disposable] = [

                    // 用户名验证结果绑定
                    state.map { $0.usernameValidationResult }
                        .drive(me.nameLabel.rx.validationResult),
                    // 密码验证结果绑定
                    state.map { $0.passwordValidationResult }
                        .drive(me.pwdLabel.rx.validationResult),
                    // 重复密码验证结果绑定
                    state.map { $0.repeatedPasswordValidationResult }
                        .drive(me.repeatedPwdLabel.rx.validationResult),
                    // 注册按钮是否可用
                    state.map { $0.usernameValidationResult.isValid &&
                               $0.passwordValidationResult.isValid &&
                               $0.repeatedPasswordValidationResult.isValid}
                        .drive(onNext: { valid  in
                            me.registerBtn.isEnabled = valid
                            me.registerBtn.alpha = valid ? 1.0 : 0.3
                        }),
                    // 活动指示器绑定
                   // state.map{ $0.startSignup }
                   //     .drive(me.signInActivityIndicator.rx.isAnimating),
                    // 注册结果显示
                    state.map { $0.signupResult }
                        .filter { $0 != nil }
                        .drive(onNext: { result  in
                            me.showMessage("注册" + (result! ? "成功" : "失败") + "!")
                        })
                ]
                // 将 UI 事件变成Event输入到反馈循环里面去
                let events = [
                    // 用户名输入
                    me.nameText.rx.text.orEmpty.changed
                        .asSignal().map(Event.usernameChanged),
                    // 密码输入
                    me.pwdText.rx.text.orEmpty.changed
                        .asSignal().map(Event.passwordChanged),
                    // 重复密码输入
                    me.repeatedPwdText.rx.text.orEmpty.changed
                        .asSignal().map(Event.repeatedPasswordChanged),
                    // 注册按钮点击
                    me.registerBtn.rx.tap
                        .asSignal().map { _ in Event.signup }
                ]
                return Bindings(subscriptions: subscriptions, events: events)
            }
            ,
            // 非UI的自动反馈（用户名验证）
            react(request: { $0.username }, effects: { username  in
                return signupService.validateUsername(username)
                    .asSignal(onErrorRecover: { _ in .empty() })
                    .map(Event.usernameValidated)
            })
//            ,react(request: { $0.signupData }, effects: { (username, password)  in
//                return networkService.signup(username, password: password)
//                    .asSignal(onErrorRecover: { _ in .empty() })
//                    .map(Event.signupResponse)
//            })
        )
        .drive()
        .disposed(by: disposeBag)
    }
    
    // 详细提示框
    func showMessage(_ message: String) {
        let alertController = UIAlertController(title: nil,
                                    message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func createTextField(preView: UIView?, placeHolder: String) -> UITextField {
        let y = preView?.frame.maxY ?? 100
        let field = UITextField(frame: CGRect(x: 10, y: y+10, width: view.frame.size.width-20, height: 40))
        field.borderStyle = .bezel
        field.placeholder = placeHolder
        view.addSubview(field)
        return field
    }
    
    func createLabel(preView: UIView) -> UILabel {
        let y = preView.frame.maxY
        let label = UILabel(frame: CGRect(x: 10, y: y+10, width: view.frame.size.width-20, height: 40))
        view.addSubview(label)
        return label
    }
}
