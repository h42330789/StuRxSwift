//
//  Table8CollectionViewCell.swift
//  StuRxSwift
//
//  Created by abc on 12/24/22.
//

import UIKit

class Table8TitleCollectionCell: UICollectionViewCell {
    lazy var label: UILabel = {
        let l = UILabel(frame: .init(x: 0, y: 0, width: 60, height: 20))
        l.textAlignment = .center
        l.textColor = UIColor(red: 139/255.0, green: 139/255.0, blue: 139/255.0, alpha: 1.0)
        l.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(l)
        return l
    }()
}

class Table8CollectionCell: UICollectionViewCell {
    lazy var label: UILabel = {
        let l = UILabel(frame: .init(x: 0, y: 0, width: 60, height: 40))
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(l)
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
