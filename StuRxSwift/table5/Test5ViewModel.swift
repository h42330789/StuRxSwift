//
//  Test5ViewModel.swift
//  StuRxSwift
//
//  Created by abc on 12/22/22.
//

import Foundation
import RxSwift
import RxCocoa

enum TableEditingCommand {
    case setItems(items: [String]) // 设置表格数据
    case addItem(item: String) // 新增数据
    case moveItem(from: IndexPath, to: IndexPath) // 移动数据
    case deleteItem(indexPath: IndexPath) // 删除数据
}

struct Test5ViewModel {

    // 表格数据
    fileprivate var items: [String]
    
    init(items: [String] = []) {
        self.items = items
    }
    
    func execute(command: TableEditingCommand) -> Test5ViewModel {
        switch command {
        case .setItems(let items):
            print("设置表格数据。")
            return Test5ViewModel(items: items)
        case .addItem(let item):
            print("新增数据项")
            var items = self.items
            items.append(item)
            return Test5ViewModel(items: items)
        case .moveItem(let from, let to):
            var items = self.items
            items.insert(items.remove(at: from.row), at: to.row)
            return Test5ViewModel(items: items)
        case .deleteItem(let indexPath):
            print("删除数据项。")
            var items = self.items
            items.remove(at: indexPath.row)
            return Test5ViewModel(items: items)
        }
    
    }
}
