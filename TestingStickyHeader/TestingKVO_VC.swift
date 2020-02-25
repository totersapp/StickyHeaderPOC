//
//  TestingKVO_VC.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 25/02/2020.
//  Copyright © 2020 Fantastik. All rights reserved.
//

import UIKit
import SnapKit

private var xoStickyHeaderKey: UInt8 = 0
extension UIScrollView {

    public var stickyHeader: StickyHeader! {

        get {
            var header = objc_getAssociatedObject(self, &xoStickyHeaderKey) as? StickyHeader

            if header == nil {
                header = StickyHeader(in: self)
                objc_setAssociatedObject(self, &xoStickyHeaderKey, header, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return header!
        }
    }
}

class TestingKVO_VC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Outlets
    @IBOutlet var table: UITableView!

    // MARK: Properties
    var navigationView = UIView()
    var header: TestingHeader!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        self.view.addSubview(table)
        table.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        table.delegate = self
        table.dataSource = self

        if #available(iOS 11, *) {
            table.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        self.header = TestingHeader()
        self.header.delegate = self
        self.header.configure(with: TestingHeader.ContentData(items: self.generateData(), buttons: 5))
        self.header.set(width: self.view.bounds.width)
        table.stickyHeader.attach(view: self.header, height: header.frame.height, minHeight: 64)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.startCarousel()
    }

    private func startCarousel() {
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                self.startCarousel()
            }
        }

        self.header.configure(with: TestingHeader.ContentData(items: self.generateData(), buttons: 5))
        self.header.set(width: self.view.bounds.width)
        self.table.stickyHeader.updateViewHeightIfNeeded()
    }

    // MARK: Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")!
        cell.textLabel?.text = "\(indexPath) - My loving row"
        return cell
    }

    // MARK: Scrollview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offset = scrollView.contentOffset.y

        let changeStartOffset: CGFloat = -180
        let changeSpeed: CGFloat = 100
        navigationView.alpha = min(1.0, (offset - changeStartOffset) / changeSpeed)
    }
}

extension TestingKVO_VC: TestingHeaderDelegate {
    func header(_ header: TestingHeader, didPressButtonAt index: Int) {
        let ip = IndexPath(item: 0, section: index)
        self.table.stickyHeader.minimizeHeader()
        self.table.scrollToRow(at: ip, at: .top, animated: true)
        print("Button pressed: \(index)")
    }
}
