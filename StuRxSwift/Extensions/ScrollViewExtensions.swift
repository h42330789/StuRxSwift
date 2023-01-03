//
//  ScrollViewExtensions.swift
//  StuRxSwift
//
//  Created by aaa on 12/30/22.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    
    // 视图滚动到底部检测序列
    var reachedBottom: Signal<()> {
        return contentOffset.asDriver()
            .flatMap { [weak base] contentOffset -> Signal<()> in
                guard let scrollView = base else {
                    return Signal.empty()
                }
                
                // 可视区域
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                // 滚动条最大位置
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                // 如果当前位置超出最大位置，则发出一个事件
                let y = contentOffset.y + scrollView.contentInset.top
                return y > threshold ? Signal.just(()) : Signal.empty()
            }
    }
}
