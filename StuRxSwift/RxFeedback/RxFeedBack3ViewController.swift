//
//  RxFeedBack3ViewController.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

class RxFeedBack3ViewController: BaseViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // GitHub网络请求服务
        _ = GitHubNetworkService()
         
        // 用户注册服务
        _ = GitHubSignupService()
         
        // UI绑定
//        let bindUI: (Driver<GitHubSignupState>) -> Signal<GitHubSignupEvent> =
//            bind(self) { (me, state) in
//            //状态输出到页面控件上
//            let subscriptions = [
//                //用户名验证结果绑定
//                state.map{ $0.usernameValidationResult }
//                    .drive(me.nameLabel.rx.validationResult),
//                //密码验证结果绑定
//                state.map{ $0.passwordValidationResult }
//                    .drive(me.pwdLabel.rx.validationResult),
//                //重复密码验证结果绑定
//                state.map{ $0.repeatedPasswordValidationResult }
//                    .drive(me.repeatedPwdLabel.rx.validationResult),
//                //注册按钮是否可用
//                state.map{ $0.usernameValidationResult.isValid &&
//                    $0.passwordValidationResult.isValid &&
//                    $0.repeatedPasswordValidationResult.isValid}
//                    .drive(onNext: { valid  in
//                        me.registerBtn.isEnabled = valid
//                        me.registerBtn.alpha = valid ? 1.0 : 0.3
//                    }),
//                //活动指示器绑定
////                state.map{ $0.startSignup }
////                    .drive(me.signInActivityIndicator.rx.isAnimating),
//                //注册结果显示
//                state.map{ $0.signupResult }
//                    .filter{ $0 != nil }
//                    .drive(onNext: { result  in
//                        me.showMessage("注册" + (result! ? "成功" : "失败") + "!")
//                    })
//            ]
//            //将 UI 事件变成Event输入到反馈循环里面去
//            let events = [
//                //用户名输入
//                me.nameText.rx.text.orEmpty.changed
//                    .asSignal().map(GitHubSignupEvent.usernameChanged),
//                //密码输入
//                me.pwdText.rx.text.orEmpty.changed
//                    .asSignal().map(GitHubSignupEvent.passwordChanged),
//                //重复密码输入
//                me.repeatedPwdText.rx.text.orEmpty.changed
//                    .asSignal().map(GitHubSignupEvent.repeatedPasswordChanged),
//                //注册按钮点击
//                me.signupOutlet.rx.tap
//                    .asSignal().map{ _ in GitHubSignupEvent.signup },
//                ]
//
//            return Bindings(subscriptions: subscriptions, events: events)
//        }
//
//        Driver.system(
//            //初始状态
//            initialState: GitHubSignupState.empty,
//            //各个事件对状态的改变
//            reduce: { GitHubSignupState.reduce(state: $0, event: $1,
//                                        signupService: signupService) },
//            feedback: bindUI,
//                //非UI的自动反馈（用户名验证）
//                GitHubSignupFeedback.validateUsername(signupService: signupService)
////                ,
//                //非UI的自动反馈（用户注册）
////                GitHubSignupFeedback.signup(networkService: networkService)
//            )
//            .drive()
//            .disposed(by: disposeBag)
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
