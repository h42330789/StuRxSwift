//
//  SportLightViewController.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import UIKit
import CoreSpotlight

class SportLightViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        deleteItems()
        addItems()
        
    }
    
    func deleteItems() {
        let sIndex = CSSearchableIndex.default()
        sIndex.deleteAllSearchableItems { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("删除成功")
            }
        }
    }
    
    func delete(byGroup groupId: String) {
        let sIndex = CSSearchableIndex.default()
        sIndex.deleteSearchableItems(withDomainIdentifiers: ["group1"], completionHandler: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("删除成功！")
            }
        })
    }
    
    func delete(byIds ids: [String]) {
        let sIndex = CSSearchableIndex.default()
        sIndex.deleteSearchableItems(withIdentifiers: ids, completionHandler: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("删除成功！")
            }
        })
    }
    
    func addItems() {
        // 判断设备支持情况
        guard CSSearchableIndex.isIndexingAvailable() else {
            print("该设备不支持添加Spotlight搜索!")
            return
        }
        
        var items = [CSSearchableItem]()
        for i in 0..<7 {
            // 创建索引属性
            let attributeSet: CSSearchableItemAttributeSet
            if #available(iOS 14.0, *) {
                attributeSet = CSSearchableItemAttributeSet(contentType: .data)
            } else {
                // Fallback on earlier versions
                attributeSet = CSSearchableItemAttributeSet(itemContentType: "data")
            }
            attributeSet.title = "hello.com title \(i)"
            attributeSet.contentDescription = "描述描述"
            attributeSet.fileSize = 0.15
            attributeSet.thumbnailData = UIImage(named: "2022")?.pngData()
            attributeSet.keywords = ["hello", "sportLight"]
            // 创建索引项
            let item = CSSearchableItem(uniqueIdentifier: "\(i)", domainIdentifier: "group1", attributeSet: attributeSet)
            items.append(item)
        }
        
        let sIndex = CSSearchableIndex.default()
        sIndex.indexSearchableItems(items) { error in
            if error != nil {
                print(error!)
            } else {
                print("添加索引成功")
            }
        }
    }

}
