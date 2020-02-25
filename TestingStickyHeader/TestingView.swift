//
//  TestingView.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 20/02/2020.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class TestingView: UIView, UIViewInjectable {
    // MARK: - UIViewInjectable
    struct ContentData {
        let prefix: String
        let color: UIColor
        let height: CGFloat
    }

    var data: ContentData!

    func configure(with data: ContentData) {
        self.data = data
        self.backgroundColor = data.color
        self.snp.updateConstraints {
            $0.height.equalTo(data.height).priority(999)
        }
        self.label.text = data.prefix + " - " + self.describe(data: data)
    }

    func voidConstraint() {
        self.snp.remakeConstraints {
            $0.height.greaterThanOrEqualTo(self.data.height).priority(500)
            $0.width.equalTo(122).priority(999)
        }
        self.snp.contentHuggingVerticalPriority = 150
    }

    // MARK: - Internal impl
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private
    private func setup() {
        self.addSubview(self.label)
        self.label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
        }
        self.snp.makeConstraints {
            $0.height.equalTo(44).priority(999).constraint
            $0.width.equalTo(122).priority(999)
        }
    }

    private func describe(data: ContentData) -> String {
        return "\(data.color.toHex() ?? "") - \(data.height)"
    }
}

extension TestingView: UIViewWidthSpecifiable {
    func set(width: CGFloat) {
        self.snp.updateConstraints {
            $0.width.equalTo(width).priority(999)
        }
    }
}
