//
//  JsonElement.swift
//  StuRxSwift
//
//  Created by abc on 12/19/22.
//

import UIKit

class JsonElement  {
    let name: String
    let jValue: String?
    
    lazy var asJson: () -> String = { [weak self] in
        if let text = self?.jValue {
            return "\(self?.name ?? ""): \(text)"
        }else {
            return "text is nil"
        }
    }
    
    init(name: String, text: String) {
        self.name = name
        self.jValue = text
        print("初始化闭包")
    }
    
    deinit {
        print("闭包释放")
    }
}
