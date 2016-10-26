//
//  PageCollectionView.swift
//  CTPageSegmentView
//
//  Created by Todd Cheng on 16/10/25.
//  Copyright © 2016年 Todd Cheng. All rights reserved.
//

import UIKit

protocol PageCollectionViewDelegate: class {
    func pageCollectionView(_ pageCollectionView: PageCollectionView, progress: CGFloat, fromIndex: Int, toIndex: Int)
}

private let kPageCollectionViewCellIdentifier = "kPageCollectionViewCellIdentifier"

class PageCollectionView: UIView {
    // MARK: Properties
    
    fileprivate var titles: [String]
    fileprivate var titleLabels: [UILabel] = [UILabel]()
    
    fileprivate var isDragging: Bool = true
    
    internal weak var delegate: PageCollectionViewDelegate?
    
    fileprivate lazy var containerCollectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        // public protocol UICollectionViewDelegate : UIScrollViewDelegate
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kPageCollectionViewCellIdentifier)
        
        return collectionView
    }()
    
    // MARK: Init Constructed Function
    
    init(frame: CGRect, titles: [String]) {
        self.titles = titles
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- Setup Subviews

extension PageCollectionView {
    fileprivate func setupSubviews() {
        addSubview(containerCollectionView)
    }
}

// MARK:- UICollectionViewDataSource

extension PageCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPageCollectionViewCellIdentifier, for: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let colorBackgroundView = UIView()
        colorBackgroundView.frame = cell.bounds
        colorBackgroundView.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256)) / 255.0,
                                            green: CGFloat(arc4random_uniform(256)) / 255.0,
                                            blue: CGFloat(arc4random_uniform(256)) / 255.0,
                                            alpha: 1.0)
        cell.contentView.addSubview(colorBackgroundView)
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: colorBackgroundView.frame.width, height: 30)
        titleLabel.center = colorBackgroundView.center
        titleLabel.text = titles[indexPath.row]
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 30)
        titleLabel.backgroundColor = UIColor.clear
        colorBackgroundView.addSubview(titleLabel)
        
        return cell
    }
}

// MARK:- UICollectionViewDelegate

extension PageCollectionView: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isDragging == false { return }
        if (scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.frame.width) == 0.0) { return }
        
        var progress: CGFloat = 0.0
        
        let firstIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        let secondIndex = firstIndex + 1
        progress = scrollView.contentOffset.x / scrollView.frame.width - CGFloat(Int(scrollView.contentOffset.x / scrollView.frame.width))
        
        delegate?.pageCollectionView(self, progress: progress, fromIndex: firstIndex, toIndex: secondIndex)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewDidEndDeceleratingAtIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        delegate?.pageCollectionView(self, progress: 1.0, fromIndex: scrollViewDidEndDeceleratingAtIndex, toIndex: scrollViewDidEndDeceleratingAtIndex)
    }
}

// MARK:- Open Functions

extension PageCollectionView {
    internal func scrollToView(atIndex index: Int) {
        isDragging = false
        containerCollectionView.setContentOffset(CGPoint(x: CGFloat(index) * containerCollectionView.frame.width, y: 0), animated: true)
    }
}
