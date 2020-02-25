//
//  TestingAnotherVC.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 20/02/2020.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit

protocol TestingHeaderDelegate: AnyObject {
    func header(_ header:TestingHeader, didPressButtonAt: Int)
}

final class TestingHeader: UIView, UIViewInjectable {
    // MARK: - UIViewInjectable
    struct ContentData {
        let items: [TestingView.ContentData]
        let buttons: Int
    }

    var data: ContentData!
    weak var delegate: TestingHeaderDelegate?
    func configure(with data: ContentData) {
        self.stackView.arrangedSubviews.reversed().forEach {
            self.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (i, item) in data.items.enumerated() {
            let view = TestingView()
            view.configure(with: item)
            if i == 0 {
                view.voidConstraint()
            }
            self.stackView.addArrangedSubview(view)
        }
        self.stackView.addArrangedSubview(self.makeButtons(num: data.buttons))

        if let view = self.stackView.arrangedSubviews.first as? TestingView {
            view.voidConstraint()
        }
    }

    // MARK: - Internal impl
    private let stackView = UIStackView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private
    private func setup() {
        self.addSubview(self.stackView)
        self.stackView.distribution = .fill
        self.stackView.axis = .vertical
        self.layer.borderWidth = 10
        self.layer.borderColor = UIColor.red.cgColor
        self.stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().priority(750)
        }
        self.snp.makeConstraints {
            $0.width.equalTo(122).priority(999)
        }
    }

    private func makeButtons(num: Int) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        for i in 0..<num {
            let button = UIButton()
            button.backgroundColor = .gray
            button.setTitle("\(i)", for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
            button.snp.makeConstraints {
                $0.height.equalTo(40)
            }
            stackView.addArrangedSubview(button)
        }
        return stackView
    }

    @objc private func handleButtonPressed(_ object: UIButton) {
        self.delegate?.header(self, didPressButtonAt: object.tag)
    }
}

extension TestingHeader: UIViewWidthSpecifiable {
    func set(width: CGFloat) {
        self.snp.updateConstraints {
            $0.width.equalTo(width).priority(999)
        }
        self.stackView.arrangedSubviews.forEach {
            ($0 as? UIViewWidthSpecifiable)?.set(width: width)
        }
    }
}


class TestingAnotherVC: UIViewController {
    private var header: TestingHeader!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startConfiguring()
    }

    // MARK: - Private
    private func setup() {
        self.header = TestingHeader()
        self.view.addSubview(self.header)
        self.view.backgroundColor = .white
        self.header.snp.makeConstraints {
            $0.centerY.equalTo(self.view.snp.centerY)
            $0.left.equalTo(self.view.snp.left)
            $0.right.equalTo(self.view.snp.right)
        }
        self.header.set(width: self.view.bounds.width)
    }

    private func generateData() -> [TestingView.ContentData] {
        var items = [TestingView.ContentData]()
        for i in 0..<Int.random(in: 2..<10) {
            let data = TestingView.ContentData(
                prefix: "\(i)",
                color: UIColor.random(),
                height: CGFloat.random(in: 20..<100).rounded()
            )
            print("\(data.color.toHex() ?? "") - \(data.height)")
            items.append(data)
        }
        return items
    }

    private func startConfiguring() {
        self.header.configure(with: TestingHeader.ContentData(items: self.generateData(), buttons: 5))
        self.header.set(width: self.view.bounds.width)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            self?.startConfiguring()
        }
    }
}
