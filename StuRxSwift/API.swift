//
//  API.swift
//  StuRxSwift
//
//  Created by abc on 12/9/22.
//

import Foundation

struct UserInfo {
    
}

enum API1 {
    static func token(username: String,
                      password: String,
                      success: (String) -> Void,
                      failure: (Error) -> Void) {
        
    }
    
    static func userInfo(token: String,
                         success: (UserInfo) -> Void,
                         failure: (Error) -> Void) {
        
    }
    
    static func testDo() {
        API1.token(username: "", password: "") { token in
            API1.userInfo(token: token) { userInfo in
                print("获取用户信息成功: \(userInfo)")
            } failure: { error in
                print("用户用户信息失败：\(error)")
            }

        } failure: { error in
            print("获取token失败：\(error)")
        }

    }
}

import RxSwift

enum API2 {
    
//    static func token(username: String, password: String) -> Observable<String> {
//       return nil
//    }
//
//    static func userInfo(token: String) -> Observable<UserInfo> {
//
//    }
//
//    static func testDo() {
//        API2.token(username: "", password: "")
//            .flatMapLatest(API2.userInfo)
//            .subscribe(onNext: { userInfo in
//                print("获取用户信息成功：\(userInfo)")
//            }, onError: { error in
//                print("获取用户信息失败：\(error)")
//            })
//            .disposed(by: <#T##DisposeBag#>)
//
//    }
}
