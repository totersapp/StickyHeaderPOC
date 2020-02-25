//
//  TestingCVScrollingVC.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 25/02/2020.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class TestingCVScrollingVC: UIViewController {
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.data = self.generateRandomData()
        self.collectionView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 4), at: .top, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 4), at: .top, animated: true)
            }
        }
    }

    // MARK: - Private
    private func setup() {
        self.setupCollectionView()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = CGSize(width: self.view.bounds.width, height: 200)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        if #available(iOS 13, *) {
            self.collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        if #available(iOS 11, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.collectionView.register(
            cell: CollectionCell<TestingView>.self
        )
        self.collectionView.register(
            cell: CollectionCell<TestingHeader>.self
        )
        self.collectionView.register(
            reusableView: CollectionReusableView<TestingSection>.self,
            kind: UICollectionView.elementKindSectionHeader
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.prefetchDataSource = self
        self.collectionView.backgroundColor = .gray
    }

    // MARK: - Private data generation
    private struct SectionData {
        var items: [TestingView.ContentData]
    }
    private var data: [SectionData] = [SectionData]()

    private func generateRandomData() -> [SectionData] {
        var sections = [SectionData]()
        for sec in 0..<5 {
            let title = "Section: \(sec)"
            var items = [TestingView.ContentData]()
            for i in 0..<5 {
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

extension TestingCVScrollingVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.data.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.data[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let width = collectionView.bounds.width
        let cell = collectionView.dequeue(cell: CollectionCell<TestingView>.self, for: indexPath)
        cell.configure(using: self.data[indexPath.section].items[indexPath.item])
        cell.set(width: width)
        return cell
    }
}

extension TestingCVScrollingVC: UICollectionViewDelegate {
}

extension TestingCVScrollingVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    }
}
