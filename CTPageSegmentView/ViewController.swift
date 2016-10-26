//
//  ViewController.swift
//  CTPageSegmentView
//
//  Created by Todd Cheng on 16/10/24.
//  Copyright © 2016年 Todd Cheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Properties
    
    private var titles: [String] = ["Title0", "Title1", "Title2", "Title3", "Title4", "Title5", "Title6"]

    fileprivate lazy var pageSegmentView: PageSegmentView = { [unowned self] in
        let pageSegmentViewFrame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 44)
        let pageSegmentView = PageSegmentView(frame: pageSegmentViewFrame, titles: self.titles)
        pageSegmentView.delegate = self
        
        return pageSegmentView
    }()
    
    
    fileprivate lazy var pageCollectionView: PageCollectionView = { [unowned self] in
        let pageCollectionViewFrame = CGRect(x: 0, y: 64 + 44, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64 - 44)
        let pageCollectionView = PageCollectionView(frame: pageCollectionViewFrame, titles: self.titles)
        pageCollectionView.delegate = self
        
        return pageCollectionView
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(pageSegmentView)
        view.addSubview(pageCollectionView)
    }
}

// MARK:- PageSegmentViewDelegate

extension ViewController: PageSegmentViewDelegate {
    func pageSegmentView(_ pageSegmentView: PageSegmentView, selectedIndex index: Int) {
        pageCollectionView.scrollToView(atIndex: index)
    }
}

// MARK:- PageCollectionViewDelegate

extension ViewController: PageCollectionViewDelegate {
    func pageCollectionView(_ pageCollectionView: PageCollectionView, progress: CGFloat, fromIndex: Int, toIndex: Int) {
        pageSegmentView.scroll(progress: progress, fromIndex: fromIndex, toIndex: toIndex)
    }
    
}
