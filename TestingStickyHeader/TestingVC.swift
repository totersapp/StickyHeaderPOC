//
//  TestingVC.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 20/02/2020.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class TestingViewController: UIViewController {
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.data.append(SectionData(title: TestingSection.ContentData(title: "", height: 0),
                                     items: [TestingView.ContentData]()))
        self.data = self.generateRandomData()
        self.headerData = self.generateData()
        self.collectionView.reloadData()
//        self.startDeletingCarousel()
//        self.startInsertingCarousel()
//        self.startCarousel()
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
//            self.startMovingCarousel()
//        }
    }

    private func startInsertingCarousel() {
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                self?.startInsertingCarousel()
            }
        }
        var items = self.data[0].items
        let lastItem = items.count
        items.insert(TestingView.ContentData(
            prefix: "new",
            color: UIColor.random(),
            height: CGFloat.random(in: 200..<400).rounded()
        ), at: lastItem)
        self.data[0].items = items
        self.collectionView.insertItems(at: [IndexPath(item: lastItem, section: 0)])
    }

    private func startDeletingCarousel() {
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                self?.startDeletingCarousel()
            }
        }
        guard self.data[0].items.count > 0 else { return }
        let idx = 0
        self.data[0].items.remove(at: idx)
        self.collectionView.deleteItems(at: [IndexPath(item: idx, section: 0)])
    }

    private func startMovingCarousel() {
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
                self?.startMovingCarousel()
            }
        }

        var movingItem = self.data[0].items.last!
        self.data[0].items.remove(at: self.data[0].items.count - 1)
        self.data[0].items.insert(movingItem, at: 0)
        self.collectionView.moveItem(at: IndexPath(row: self.data[0].items.count - 1, section: 0),
                                     to: IndexPath(row: 0, section: 0))
    }

    private func startCarousel() {
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
//                self?.startCarousel()
            }
        }

        let indexPath = IndexPath(item: 0, section: 0)
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? CollectionCell<TestingHeader> else {
            return
        }
        let width = self.collectionView.bounds.width

        cell.configure(using: TestingHeader.ContentData(items: self.headerData, buttons: 5))
        cell.set(width: width)

        self.collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: [indexPath])
        })
    }

    // MARK: - Private
    private func setup() {
        self.setupCollectionView()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupCollectionView() {
        let layout = CollectionViewLayout()
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
        var title: TestingSection.ContentData
        var items: [TestingView.ContentData]
    }
    private var data: [SectionData] = [SectionData]()

    private func generateRandomData() -> [SectionData] {
        var sections = [SectionData]()
        for sec in 0..<5 {//Int.random(in: 1..<1) {
            let title = "Section: \(sec)"
            var items = [TestingView.ContentData]()
            for i in 0..<5 {//Int.random(in: 1..<1) {
                let data = TestingView.ContentData(
                    prefix: "\(i)",
                    color: UIColor.random(),
                    height: CGFloat.random(in: 200..<400).rounded()
                )
                items.append(data)
            }
            sections.append(SectionData(
                title: TestingSection.ContentData(title: title, height: 80),
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

extension TestingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.data.count + 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.data[section - 1].items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let width = collectionView.bounds.width
        if indexPath.section == 0 {
            let cell = collectionView.dequeue(cell: CollectionCell<TestingHeader>.self, for: indexPath)
            cell.configure(using: TestingHeader.ContentData(items: self.headerData, buttons: 5))
            cell.set(width: width)
            cell.view.delegate = self
            return cell
        }

        let cell = collectionView.dequeue(cell: CollectionCell<TestingView>.self, for: indexPath)
        cell.configure(using: self.data[indexPath.section - 1].items[indexPath.item])
        cell.set(width: width)
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView,
//                        viewForSupplementaryElementOfKind kind: String,
//                        at indexPath: IndexPath) -> UICollectionReusableView {
//        guard kind == UICollectionView.elementKindSectionHeader, indexPath.section != 0 else {
//            return collectionView.dequeue(reusableView: CollectionReusableView<TestingSection>.self,
//                                          ofKind: kind,
//                                          at: indexPath)
//        }
//        let width = collectionView.bounds.width
//        let view = collectionView.dequeue(reusableView: CollectionReusableView<TestingSection>.self,
//                                          ofKind: kind,
//                                          at: indexPath)
//        view.configure(using: self.data[indexPath.section - 1].title)
//        view.set(width: width)
//        return view
//    }
}

extension TestingViewController: UICollectionViewDelegate {
}

extension TestingViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    }
}

extension TestingViewController: TestingHeaderDelegate {
    func header(_ header: TestingHeader, didPressButtonAt index: Int) {
        let ip = IndexPath(item: 0, section: index)
//        self.collectionView.scrollRectToVisible(newBounds, animated: true)
        self.collectionView.scrollToItem(at: ip, at: .top, animated: true)
        print("Button pressed: \(index)")
    }
}
