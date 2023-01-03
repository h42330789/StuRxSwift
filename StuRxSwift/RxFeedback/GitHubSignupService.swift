//
//  GitHubSignupService.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

// 用户注册服务
class GitHubSignupService {
    // 密码最少位数
    let minPasswordCount = 5
    // 网络请求服务
    lazy var networkService = GitHubNetworkService()
    
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        // 判断用户名是否为空
        if username.isEmpty {
            return Observable.just(.empty)
        }
        
        // 判断用户名是否只有数字和字母
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "用户名只能包含数字和字母"))
        }
        
        return networkService.usernameAvailable(username)
            .map {
                if $0 {
                    return .ok(message: "用户名可用")
                } else {
                    return .failed(message: "用户名已存在")
                }
            }
            .startWith(.validating)
    }
    
    // 验证密码
    func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return .empty
        }
        if password.count < minPasswordCount {
            return .failed(message: "密码至少需要 \(minPasswordCount) 个字符")
        }
        
        return .ok(message: "密码有效")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        if repeatedPassword.isEmpty {
            return .empty
        }
        if repeatedPassword == password {
            return .ok(message: "密码有效")
        } else {
            return .failed(message: "两次输入的密码不一致")
        }
    }
}

enum ValidationResult {
    case validating // 正在验证中
    case empty // 输入为空
    case ok(message: String) // 验证通过
    case failed(message: String) // 验证失败
    
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
    
    var description: String {
        switch self {
        case .validating:
            return "正在验证。。。"
        case .empty:
            return ""
        case .ok(let message):
            return message
        case .failed(let message):
            return message
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .validating:
            return UIColor.gray
        case .empty:
            return UIColor.black
        case .ok:
            return UIColor(red: 0/255, green: 130/255, blue: 0/255, alpha: 1)
        case .failed:
            return UIColor.red
        }
    }
}

extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

extension Reactive where Base: UILabel {
    var validationResult: Binder<ValidationResult> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}
