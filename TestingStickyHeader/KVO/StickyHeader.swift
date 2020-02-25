//
//  StickyHeader.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 25/02/2020.
//  Copyright © 2020 Fantastik. All rights reserved.
//

import UIKit

public class StickyHeader: NSObject {
    private(set) lazy var contentView: StickyHeaderView = {
        let view = StickyHeaderView()
        view.parent = self
        view.clipsToBounds = true
        return view
    }()

    private weak var scrollView: UIScrollView?
    init(in scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init()
        scrollView.contentInset = .zero
        scrollView.addSubview(self.contentView)
    }

    private var view: UIView?
    private var height: CGFloat = 0
    private var minHeight: CGFloat = 0

    public func attach(view: UIView, height: CGFloat, minHeight: CGFloat) {
        guard self.view != view else { return }
        if let currentView = self.view {
            currentView.removeFromSuperview()
        }

        view.removeFromSuperview()
        view.translatesAutoresizingMaskIntoConstraints = false

        let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultLow)
        self.view = view
        self.height = size.height
        self.minHeight = minHeight

        self.contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            view.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])

        self.scrollView?.contentOffset.y = -self.height
        self.scrollView?.contentInset = UIEdgeInsets(top: self.height, left: 0, bottom: 0, right: 0)
    }

    public func updateViewHeightIfNeeded() {
        guard let view = self.view else { return }
        guard let scrollView = self.scrollView else { return }

        let size = view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize,
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .defaultLow)

        self.height = size.height
        let offsetY = scrollView.contentOffset.y
        let isHeaderCollapsed = (offsetY >= 0.0 || offsetY >= -self.minHeight)
        if isHeaderCollapsed {
            self.layoutContentView()
        } else {
            scrollView.contentInset = UIEdgeInsets(top: self.height, left: 0, bottom: 0, right: 0)
            scrollView.contentOffset.y = -size.height
        }


//        self.layoutContentView()
    }

    public func minimizeHeader() {
        self.scrollView?.contentInset = UIEdgeInsets(top: self.minHeight, left: 0, bottom: 0, right: 0)
    }

    private func layoutContentView() {
        var relativeYOffset: CGFloat = 0

        guard let scrollView = self.scrollView else { return }

        let height: CGFloat
        let topInset: CGFloat
        if scrollView.contentOffset.y <= -self.height {
            relativeYOffset = scrollView.contentOffset.y
            height = abs(scrollView.contentOffset.y)
            topInset = self.height
            print("EXTENDED: \(topInset)")
        } else if scrollView.contentOffset.y < -self.minHeight {
            relativeYOffset = -self.height
            height = self.height
            topInset = self.height
            print("STANDARD: \(topInset) - \(scrollView.contentOffset.y)")
        } else {
            let compensation: CGFloat = -self.minHeight - scrollView.contentOffset.y
            relativeYOffset = -self.height - compensation
            height = self.height
            topInset = self.minHeight
            print("MIN")
        }
        if scrollView.contentInset.top != topInset {
            scrollView.contentInset.top = topInset
        }

        let frame = CGRect(x: 0, y: relativeYOffset, width: scrollView.frame.size.width, height: height)
        self.contentView.frame = frame
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &StickyHeaderView.KVOContext, let path = keyPath else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        switch path {
        case "contentOffset":
            self.layoutContentView()
        default:
            return
        }
    }
}
