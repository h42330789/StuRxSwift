//
//  Table8StateTool.swift
//  StuRxSwift
//
//  Created by abc on 12/24/22.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

typealias KeyType = (Int, Int)
typealias ContentType = (CGPoint, CGSize)

struct Table8ToolOffsetState {
    var type: KeyType
    var content: ContentType
}

class Table8CellModel: IdentifiableType, Equatable {
    typealias Identity = String
    var key: String?
    var name: String?
    var playTitleList: [String]?
    var playContentList: [String]?
    
    var identity: Identity {
        return key ?? ""
    }
    static func == (lhs: Table8CellModel, rhs: Table8CellModel) -> Bool {
        return lhs.key == rhs.key
    }
}

public class Table8StateTool {
    var playOffsetRelay: BehaviorRelay<[String: Table8ToolOffsetState]> = BehaviorRelay(value: [:])
    
    static let shared = Table8StateTool()
    private let disposeBag = DisposeBag()
    
    static func offsetTypeKey(_ type: KeyType) -> String {
        return "\(type)"
    }
    
    static func offsetDict(type: KeyType?, content: ContentType) -> [String: Table8ToolOffsetState] {
        
        var offsetDict = Table8StateTool.shared.playOffsetRelay.value
        guard let type = type else {
            return offsetDict
        }
        let key = Table8StateTool.offsetTypeKey(type)
        let model = Table8ToolOffsetState(type: type, content: content)
        offsetDict[key] = model
        return offsetDict
    }
    
    static func playContent(type: KeyType?) -> ContentType {
        guard let type = type else {
            return (.zero, .zero)
        }
        let offsetDict = Table8StateTool.shared.playOffsetRelay.value
        let key = Table8StateTool.offsetTypeKey(type)
        let model = offsetDict[key]
        let result = model?.content ?? (.zero, .zero)
        return result
    }
    static func playOffset(type: KeyType?) -> CGPoint {
        return playContent(type: type).0
    }
    static func playContentSize(type: KeyType?) -> CGSize {
        return playContent(type: type).1
    }
    
}
