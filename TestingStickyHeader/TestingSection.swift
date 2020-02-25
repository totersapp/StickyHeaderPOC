//
//  TestingSection.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 20/02/2020.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class TestingSection: UIView, UIViewInjectable {
    // MARK: - UIViewInjectable
    struct ContentData {
        let title: String
        let height: CGFloat
    }

    var data: ContentData!

    func configure(with data: ContentData) {
        self.snp.updateConstraints {
            $0.height.equalTo(data.height).priority(999)
        }
        self.label.text = data.title
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
        self.backgroundColor = .green
        self.addSubview(self.label)
        self.label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
        }
        self.snp.makeConstraints {
            $0.height.equalTo(44).priority(999)
            $0.width.equalTo(122).priority(999)
        }
    }
}

extension TestingSection: UIViewWidthSpecifiable {
    func set(width: CGFloat) {
        self.snp.updateConstraints {
            $0.width.equalTo(width).priority(999)
        }
    }
}
