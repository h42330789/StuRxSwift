//
//  GitHubSignupState.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import Foundation

// 状态
struct GitHubSignupState {
    var username: String? // 用户名
    var password: String? // 密码
    var repeatedPassword: String? // 再出输入密码
    var usernameValidationResult: ValidationResult // 用户名验证结果
    var passwordValidationResult: ValidationResult // 密码验证结果
    var repeatedPasswordValidationResult: ValidationResult // 重复密码验证结果
    var startSignup: Bool // 开始注册
    var signupResult: Bool? // 注册结果
     
    // 用户注册信息（只有开始注册状态下才有数据返回）
    var signupData: (username: String, password: String)? {
        return startSignup ? (username ?? "", password ?? "") : nil
    }
}

// 事件
enum GitHubSignupEvent {
    case usernameChanged(String) // 用户名输入
    case passwordChanged(String) // 密码输入
    case repeatedPasswordChanged(String) // 重复密码输入
    case usernameValidated(ValidationResult) // 用户名验证结束
    case signup // 用户注册
    case signupResponse(Bool) // 注册响应
}

extension GitHubSignupState {
    // 返回初始化状态
    static var empty: GitHubSignupState {
        return GitHubSignupState(username: nil, password: nil, repeatedPassword: nil,
                     usernameValidationResult: ValidationResult.empty,
                     passwordValidationResult: ValidationResult.empty,
                     repeatedPasswordValidationResult: ValidationResult.empty,
                     startSignup: false, signupResult: nil)
    }
     
    static func reduce(state: GitHubSignupState,
                       event: GitHubSignupEvent,
                       signupService: GitHubSignupService) -> GitHubSignupState {
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
    }
}
