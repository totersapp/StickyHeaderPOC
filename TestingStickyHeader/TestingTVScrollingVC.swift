//
//  TestingTVScrollingVC.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 25/02/2020.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class TestingTVScrollingVC: UIViewController {
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.data = self.generateRandomData()
        self.tableView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.tableView.scrollToRow(at: IndexPath(item: 0, section: 4), at: .top, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self.tableView.scrollToRow(at: IndexPath(item: 0, section: 4), at: .top, animated: true)
            }
        }
    }

    // MARK: - Private
    private func setup() {
        self.setupTableView()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupTableView() {
        self.tableView = UITableView()
        if #available(iOS 13, *) {
            self.tableView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        if #available(iOS 11, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.tableView.register(
            cell: TableCell<TestingView>.self
        )
        self.tableView.register(
            cell: TableCell<TestingHeader>.self
        )
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.prefetchDataSource = self
    }

    // MARK: - Private data generation
    private struct SectionData {
        var items: [TestingView.ContentData]
    }
    private var data: [SectionData] = [SectionData]()

    private func generateRandomData() -> [SectionData] {
        var sections = [SectionData]()
        for sec in 0..<50 {
            let title = "Section: \(sec)"
            var items = [TestingView.ContentData]()
            for i in 0..<50 {
                let data = TestingView.ContentData(
                    prefix: "\(i)",
                    color: UIColor.random(),
                    height: CGFloat.random(in: 200..<400).rounded()
                )
                items.append(data)
            }
            sections.append(SectionData(
                items: items)
            )
        }
        return sections
    }

    var headerData: [TestingView.ContentData] = [TestingView.ContentData]()
    private func generateData() -> [TestingView.ContentData] {
        print("\n\n\n\n\n\n")
        var items = [TestingView.ContentData]()
        for i in 0..<Int.random(in: 2..<5) {
            let data = TestingView.ContentData(
                prefix: "\(i)",
                color: UIColor.random(),
                height: CGFloat.random(in: 120..<200).rounded()
            )
            print("\(data.color.toHex() ?? "") - \(data.height)")
            items.append(data)
        }
        print("Total: \(items.count)")
        return items
    }
}

extension TestingTVScrollingVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(cell: TableCell<TestingView>.self, for: indexPath)
        cell.configure(using: self.data[indexPath.section].items[indexPath.item])
        return cell
    }
}

extension TestingTVScrollingVC: UITableViewDelegate {
}

extension TestingTVScrollingVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    }
}
