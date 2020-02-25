//
//  StickyHeader.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 25/02/2020.
//  Copyright © 2020 Fantastik. All rights reserved.
//

import UIKit

public class StickyHeader: NSObject {

    /**
     The view containing the provided header.
     */
    private(set) lazy var contentView: StickyHeaderView = {
        let view = StickyHeaderView()
        view.parent = self
        view.clipsToBounds = true
        return view
    }()

    private weak var _scrollView: UIScrollView?

    /**
     The `UIScrollView` attached to the sticky header.
     */
    public weak var scrollView: UIScrollView? {
        get {
            return _scrollView
        }

        set {
            if _scrollView != newValue {
                _scrollView = newValue

                if let scrollView = scrollView {
                    scrollView.contentInset.top = self.height
                    //                    self.adjustScrollViewTopInset(top: scrollView.contentInset.top + self.minimumHeight)
                    scrollView.addSubview(self.contentView)
                }

                self.layoutContentView()
            }
        }
    }

    private var _view: UIView?

    /**
     The `UIScrollView attached to the sticky header.
     */
    public var view: UIView? {
        set {
            guard newValue != _view else { return }
            _view = newValue
            updateConstraints()
        }
        get {
            return _view
        }
    }

    private var _height: CGFloat = 0

    /**
     The height of the header.
     */
    public var height: CGFloat {
        get { return _height }
        set {
            guard newValue != _height else { return }

            if let scrollView = self.scrollView {
                scrollView.contentInset.top = newValue
                //                self.adjustScrollViewTopInset(top: scrollView.contentInset.top - height + newValue)
            }

            _height = newValue

            self.updateConstraints()
            self.layoutContentView()

        }
    }
    private var _minimumHeight: CGFloat = 0

    /**
     The minimum height of the header.
     */
    public var minimumHeight: CGFloat {
        get { return _minimumHeight }
        set {
            _minimumHeight = newValue
            layoutContentView()
        }
    }

    private func adjustScrollViewTopInset(top: CGFloat) {

        guard let scrollView = self.scrollView else { return }
        var inset = scrollView.contentInset

        //Adjust content offset
        var offset = scrollView.contentOffset
        offset.y += inset.top - top
        scrollView.contentOffset = offset

        //Adjust content inset
        inset.top = top
        scrollView.contentInset = inset

        self.scrollView = scrollView
    }

    private func updateConstraints() {
        guard let view = self.view else { return }

        view.removeFromSuperview()
        self.contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            view.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }

    private func layoutContentView() {
        var relativeYOffset: CGFloat = 0

        guard let scrollView = self.scrollView else { return }

        let height: CGFloat
        let topInset: CGFloat
        if scrollView.contentOffset.y <= -self.height {
            relativeYOffset = scrollView.contentOffset.y
            height = abs(scrollView.contentOffset.y)
            topInset = max(self.height, abs(scrollView.contentOffset.y) - self.minimumHeight)
            print("EXTENDED: \(topInset)")
        } else if scrollView.contentOffset.y < -self.minimumHeight {
            relativeYOffset = -self.height
            height = self.height
            topInset = abs(scrollView.contentOffset.y)
            print("STANDARD: \(topInset) - \(scrollView.contentOffset.y)")
        } else {
            let compensation: CGFloat = -self.minimumHeight - scrollView.contentOffset.y
            relativeYOffset = -self.height - compensation
            height = self.height
            scrollView.contentInset.top = self.minimumHeight
            print("MIN")
        }
        //        print("off - y - height: \(scrollView.contentOffset.y) - \(relativeYOffset) - \(height)")
        let frame = CGRect(x: 0, y: relativeYOffset, width: scrollView.frame.size.width, height: height)

        self.contentView.layer.borderWidth = 3
        self.contentView.layer.borderColor = UIColor.green.cgColor
        self.contentView.frame = frame
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let path = keyPath, context == &StickyHeaderView.KVOContext && path == "contentOffset" {
            self.layoutContentView()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
