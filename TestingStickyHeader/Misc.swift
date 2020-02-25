//
//  Misc.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 20/02/2020.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol ReuseIdentifierTrait: AnyObject {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifierTrait {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

protocol NibRegister {
    static var nibName: String { get }
    static var bundle: Bundle { get }
}

extension NibRegister {
    static var nibName: String {
        return String(describing: Self.self)
    }
}

extension NibRegister where Self: AnyObject {
    static var bundle: Bundle {
        return Bundle(for: Self.self)
    }
}


extension UICollectionView {
    func register<T: UICollectionViewCell>(cell ofType: T.Type) where T: ReuseIdentifierTrait {
        self.register(ofType, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UICollectionViewCell>(cell ofType: T.Type) where T: ReuseIdentifierTrait & NibRegister {
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        self.register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func dequeue<T: UICollectionViewCell>(cell ofType: T.Type, for indexPath: IndexPath) -> T where T: ReuseIdentifierTrait{
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func register<T: UICollectionReusableView>(reusableView ofType: T.Type, kind: String) where T: ReuseIdentifierTrait {
        self.register(ofType, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UICollectionReusableView>(reusableView ofType: T.Type, ofKind kind: String) where T: ReuseIdentifierTrait & NibRegister {
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        self.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    func dequeue<T: UICollectionReusableView>(reusableView ofType: T.Type, ofKind kind: String, at indexPath: IndexPath) -> T where T: ReuseIdentifierTrait {
        return self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

extension UITableView {
    func register<T: ReuseIdentifierTrait>(cell ofType: T.Type) {
        self.register(ofType, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UITableViewCell>(cell ofType: T.Type) where T: ReuseIdentifierTrait & NibRegister {
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func dequeue<T: UITableViewCell>(cell ofType: T.Type, for indexPath: IndexPath) -> T where T: ReuseIdentifierTrait {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func register<T: ReuseIdentifierTrait>(headerFooter ofType: T.Type) {
        self.register(ofType, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UIView>(headerFooter ofType: T.Type) where T: ReuseIdentifierTrait & NibRegister {
        let nib = UINib(nibName: T.nibName, bundle: T.bundle)
        self.register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func dequeue<T: UIView>(headerFooter ofType: T.Type) -> T where T: ReuseIdentifierTrait{
        return self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}

protocol UIViewInjectable: AnyObject {
    associatedtype ContentData
    var data: ContentData! { get }
    init()
    func configure(with data: ContentData)
}

extension UIViewInjectable where Self: UIView {
    init() {
        self.init(frame: .zero)
    }
}

extension UIViewInjectable where Self: UIView, Self.ContentData == Swift.Void {
    var data: Swift.Void {
        return ()
    }

    func configure(with data: Swift.Void) {}
}

protocol UIViewWidthSpecifiable {
    func set(width: CGFloat)
}

final class TableCell<T: UIView & UIViewInjectable>: UITableViewCell, ReuseIdentifierTrait {
    static var reuseIdentifier: String {
        return "\(self).\(T.self)"
    }

    let view: T
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let view = T()
        self.view = view
        super.init(style: .default, reuseIdentifier: Self.reuseIdentifier)
        self.contentView.addSubview(self.view)
        self.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        // TODO: configure from settings
        self.selectionStyle = .none
    }

    func configure(using data: T.ContentData) {
        self.view.configure(with: data)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class TableHeaderFooterView<T: UIView & UIViewInjectable>: UITableViewHeaderFooterView, ReuseIdentifierTrait {
    static var reuseIdentifier: String {
        return "\(self).\(T.self)"
    }

    let view: T
    override init(reuseIdentifier: String?) {
        let view = T()
        self.view = view
        super.init(reuseIdentifier: Self.reuseIdentifier)
        self.contentView.addSubview(self.view)
        self.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(using data: T.ContentData) {
        self.view.configure(with: data)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class CollectionCell<T: UIView & UIViewInjectable>: UICollectionViewCell, ReuseIdentifierTrait {
    static var reuseIdentifier: String {
        return "\(self).\(T.self)"
    }

    let view: T

    override init(frame: CGRect) {
        let view = T()
        self.view = view
        super.init(frame: frame)
        self.contentView.addSubview(self.view)
        self.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.view.setNeedsLayout()
    }

    func configure(using data: T.ContentData) {
        self.view.configure(with: data)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        self.view.layoutIfNeeded()
        return super.preferredLayoutAttributesFitting(layoutAttributes)
    }
}

extension CollectionCell: UIViewWidthSpecifiable where T: UIViewWidthSpecifiable {
    func set(width: CGFloat) {
        self.view.set(width: width)
    }
}

final class CollectionReusableView<T: UIView & UIViewInjectable>: UICollectionReusableView, ReuseIdentifierTrait {
    static var reuseIdentifier: String {
        return "\(self).\(T.self)"
    }

    let view: T

    override init(frame: CGRect) {
        let view = T()
        self.view = view
        super.init(frame: frame)
        self.addSubview(self.view)
        self.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.view.setNeedsLayout()
    }

    func configure(using data: T.ContentData) {
        self.view.configure(with: data)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectionReusableView: UIViewWidthSpecifiable where T: UIViewWidthSpecifiable {
    func set(width: CGFloat) {
        self.view.set(width: width)
    }
}

extension UIColor {
    var toHex: String? {
        return toHex()
    }

    // MARK: - From UIColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0..<1),
            green: CGFloat.random(in: 0..<1),
            blue: CGFloat.random(in: 0..<1),
            alpha: 1
        )
    }
}
