//
//  GitHubSignup+Feedback.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

struct GitHubSignupFeedback {
     // 验证用户名
     static func validateUsername(signupService: GitHubSignupService)
        -> (Driver<GitHubSignupState>) -> Signal<GitHubSignupEvent> {
         
        let query: (GitHubSignupState) -> String?
            = { $0.username }
         
        let effects: (String) -> Signal<GitHubSignupEvent>
            = { return signupService.validateUsername($0)
                .asSignal(onErrorRecover: { _ in .empty() })
                .map(GitHubSignupEvent.usernameValidated) }
         
        return react(request: query, effects: effects)
    }
     
    // 用户注册
//    static func signup(networkService: GitHubNetworkService)
//        -> (Driver<GitHubSignupState>) -> Signal<GitHubSignupEvent> {
//             
//            let query:(GitHubSignupState) -> (String, String)?
//                = { $0.signupData }
//             
//            let effects:(String, String) -> Signal<GitHubSignupEvent>
//                = { return networkService.signup($0, password: $1)
//                    .asSignal(onErrorRecover: { _ in .empty() })
//                    .map(GitHubSignupEvent.signupResponse) }
//             
//            return react(request: query, effects: effects)
//    }
}
