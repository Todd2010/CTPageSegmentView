//
//  PageSegmentView.swift
//  CTPageSegmentView
//
//  Created by Todd Cheng on 16/10/24.
//  Copyright © 2016年 Todd Cheng. All rights reserved.
//


/**
 1、自定义构造函数: init(frame: CGRect, titles: [String])
 2、布局子控件
    2.1 containerScrollView
    2.2 titleLabels
    2.3 separatorLine
    2.4 scrollLine
 3、内部事件处理
    3.1 scrollLine点击之后位置的改变
    3.2 titleLabel点击之后文字颜色的改变
 4、外部事件处理
    4.1 scrollLine位置的改变
    4.2 titleLabel文字颜色的改变
    4.3 titleLabels过多，当事件触发之后containerScrollView的滚动处理
 */

import UIKit

protocol PageSegmentViewDelegate: class {
    func pageSegmentView(_ pageSegmentView: PageSegmentView, selectedIndex index: Int)
}

private let kTitleLabelFontSize: CGFloat = 20
private let kDefaultColor: (CGFloat, CGFloat, CGFloat) = (85, 85, 85)
private let kSelectedColor: (CGFloat, CGFloat, CGFloat) = (255, 128, 0)

class PageSegmentView: UIView {
    // MARK: Properties
    
    fileprivate var titles: [String]
    fileprivate var titleLabels: [UILabel] = [UILabel]()
    internal var currentIndex: Int = 0
    internal weak var delegate: PageSegmentViewDelegate?
    
    fileprivate var widthOfMixedTitles: CGFloat {
        var mixedTitles = ""
        for title in titles {
            mixedTitles += title
        }
        return self.calculateTextWidth(text: mixedTitles)
    }
    
    fileprivate lazy var containerScrollView: UIScrollView = { [unowned self] in
        let scrollView = UIScrollView()
        scrollView.frame = self.bounds
        scrollView.backgroundColor = UIColor.white
        scrollView.bounces = false
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // if titles are too many, scrollView should enable scroll horizontally
        // every titleLabel has 5 point left and right margin at least
        if self.widthOfMixedTitles > (self.frame.width - CGFloat(10 * self.titles.count)) {
            var widthOfTitleLabels: CGFloat = 0.0
            for title in self.titles {
                widthOfTitleLabels += self.calculateTextWidth(text: title) + 30
            }
            scrollView.contentSize = CGSize(width: widthOfTitleLabels, height: 0)
        }
        
        return scrollView
    }()
    
    fileprivate lazy var scrollLine: UIView = { [unowned self] in
        let scrollLine = UIView()
        scrollLine.backgroundColor = UIColor(red: kSelectedColor.0 / 255.0, green: kSelectedColor.1 / 255.0, blue: kSelectedColor.2 / 255.0, alpha: 1.0)
        return scrollLine
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

extension PageSegmentView {
    fileprivate func setupSubviews() {
        addSubview(containerScrollView)
        setupTitleLabels()
        setupSeparatorLine()
        
        guard let firstTitleLabel = titleLabels.first else { return }
        scrollLine.frame = CGRect(x: 0 , y: frame.height - 2, width: firstTitleLabel.frame.width, height: 2)
        containerScrollView.addSubview(scrollLine)
        firstTitleLabel.textColor = UIColor(red: kSelectedColor.0 / 255.0, green: kSelectedColor.1 / 255.0, blue: kSelectedColor.2 / 255.0, alpha: 1.0)
    }
    
    private func setupTitleLabels() {
        var sumWidthOfTitleLabels: CGFloat = 0.0
        for (index, title) in titles.enumerated() {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.numberOfLines = 1
            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor(red: kDefaultColor.0 / 255.0, green: kDefaultColor.1 / 255.0, blue: kDefaultColor.2 / 255.0, alpha: 1.0)
            titleLabel.font = UIFont.systemFont(ofSize: kTitleLabelFontSize)
            
            var widthOfTitleLabel: CGFloat = 0.0
            if widthOfMixedTitles > (frame.width - CGFloat(10 * titles.count)) {
                widthOfTitleLabel = calculateTextWidth(text: title) + 30
            } else {
                widthOfTitleLabel = calculateTextWidth(text: title) + (frame.width - widthOfMixedTitles) / CGFloat(titles.count)
            }
            titleLabel.frame = CGRect(x: sumWidthOfTitleLabels, y: 0, width: widthOfTitleLabel, height: frame.height)
            sumWidthOfTitleLabels += widthOfTitleLabel
            
            titleLabel.tag = index
            
            titleLabel.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClickTitleLabel(tapGestureRecognizer:)))
            titleLabel.addGestureRecognizer(tapGestureRecognizer)
            
            containerScrollView.addSubview(titleLabel)
            titleLabels.append(titleLabel)
        }
    }
    
    private func setupSeparatorLine() {
        let separatorLine = UIView()
        separatorLine.frame = CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5)
        separatorLine.backgroundColor = UIColor.lightGray
        addSubview(separatorLine)
    }
}


// MARK:- Actions 

extension PageSegmentView {
    @objc fileprivate func onClickTitleLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let currentTitleLabel = tapGestureRecognizer.view as? UILabel else { return }
        let previousTitleLabel = titleLabels[currentIndex]
        
        guard currentTitleLabel != previousTitleLabel else { return }
        
        previousTitleLabel.textColor = UIColor(red: kDefaultColor.0 / 255.0, green: kDefaultColor.1 / 255.0, blue: kDefaultColor.2 / 255.0, alpha: 1.0)
        currentTitleLabel.textColor =  UIColor(red: kSelectedColor.0 / 255.0, green: kSelectedColor.1 / 255.0, blue: kSelectedColor.2 / 255.0, alpha: 1.0)
        
        UIView.animate(withDuration: 0.2) {
            self.scrollLine.frame = CGRect(x: currentTitleLabel.frame.origin.x, y: self.scrollLine.frame.origin.y,
                                           width: currentTitleLabel.frame.width, height: self.scrollLine.frame.height)
        }
        
        currentIndex = currentTitleLabel.tag
        
        delegate?.pageSegmentView(self, selectedIndex: currentIndex)
    }
}


// MARK:- Private Functions

extension PageSegmentView {
    fileprivate func calculateTextWidth(text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: kTitleLabelFontSize)
        let constraintRect = CGSize(width: 999, height: font.lineHeight)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSFontAttributeName: font],
                                            context: nil)
        
        return boundingBox.width
    }
}

// MARK:- Open Functions 

extension PageSegmentView {
    internal func scroll(progress: CGFloat, fromIndex: Int, toIndex: Int) {
        // scroll did end decelerating
        if progress == 1.0 && fromIndex == toIndex {
            currentIndex = toIndex
            
            let scrollEndTitleLabel = titleLabels[currentIndex]
            scrollLine.frame.origin.x = scrollEndTitleLabel.frame.origin.x
            scrollLine.frame.size.width = scrollEndTitleLabel.frame.size.width
            
            for titleLabel in titleLabels {
                titleLabel.textColor = UIColor(red: kDefaultColor.0 / 255.0, green: kDefaultColor.1 / 255.0, blue: kDefaultColor.2 / 255.0, alpha: 1.0)
            }
            scrollEndTitleLabel.textColor = UIColor(red: kSelectedColor.0 / 255.0, green: kSelectedColor.1 / 255.0, blue: kSelectedColor.2 / 255.0, alpha: 1.0)
            
            return
        }
        
        // scroll manually
        let sourceTitleLabel = titleLabels[fromIndex]
        let targetTitleLabel = titleLabels[toIndex]
        
        let distanceX = targetTitleLabel.frame.origin.x - sourceTitleLabel.frame.origin.x
        let distanceWidth = targetTitleLabel.frame.width - sourceTitleLabel.frame.width
        scrollLine.frame.origin.x = sourceTitleLabel.frame.origin.x + distanceX * progress
        scrollLine.frame.size.width = sourceTitleLabel.frame.size.width + distanceWidth * progress
        
        let distanceColor = (kSelectedColor.0 - kDefaultColor.0,
                             kSelectedColor.1 - kDefaultColor.1,
                             kSelectedColor.2 - kDefaultColor.2)
        // kSelectedColor --> kDefaultColor
        sourceTitleLabel.textColor = UIColor(red: (kSelectedColor.0 - distanceColor.0 * progress) / 255.0,
                                             green: (kSelectedColor.1 - distanceColor.1 * progress) / 255.0,
                                             blue: (kSelectedColor.2 - distanceColor.2 * progress) / 255.0,
                                             alpha: 1.0)
        // kDefaultColor --> kSelectedColor
        targetTitleLabel.textColor = UIColor(red: (kDefaultColor.0 + distanceColor.0 * progress) / 255.0,
                                             green: (kDefaultColor.1 + distanceColor.1 * progress) / 255.0,
                                             blue: (kDefaultColor.2 + distanceColor.2 * progress) / 255.0,
                                             alpha: 1.0)
        
        guard self.widthOfMixedTitles > (self.frame.width - CGFloat(10 * self.titles.count)) else { return }
        if min(sourceTitleLabel.frame.origin.x, targetTitleLabel.frame.origin.x) < containerScrollView.contentOffset.x {
            containerScrollView.setContentOffset(CGPoint(x: min(sourceTitleLabel.frame.origin.x, targetTitleLabel.frame.origin.x), y: 0), animated: true)
        }
        if targetTitleLabel.frame.origin.x - containerScrollView.contentOffset.x + targetTitleLabel.frame.width > containerScrollView.frame.width {
            containerScrollView.setContentOffset(CGPoint(x: containerScrollView.contentOffset.x + targetTitleLabel.frame.width, y: 0), animated: true)
        }
    }
}
