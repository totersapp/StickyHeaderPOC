//
//  CollectionViewLayout.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 20/02/2020.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit

typealias Attributes = UICollectionViewLayoutAttributes

public final class CollectionViewLayout: UICollectionViewLayout {
    // MARK: - Introduced vars
    public var estimatedItemHeight: CGFloat = 100.0 {
        willSet {
            precondition(newValue >= 0)
        }
    }

    public var stickyHeaderMinHeight: CGFloat = 200.0 {
        didSet {
            // TODO: later
//            let invalidationContextClass: AnyClass = type(of: self).invalidationContextClass
//            guard let contextClass = invalidationContextClass as? UICollectionViewLayoutInvalidationContext.Type else {
//                return
//            }
//            let context = contextClass.init()
//            context.invalidateItems(at: [self.headerIndexPath])
//            self.invalidateLayout(with: context)
        }
    }

    // MARK: - Override
    override public class var invalidationContextClass: AnyClass {
        return CollectionViewInvalidationContext.self
    }

    override public func invalidateLayout() {
        print("INVALIDATE LAYOUT")
        super.invalidateLayout()
    }

    override public func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        defer { super.invalidateLayout(with: context) }
        guard let context = context as? CollectionViewInvalidationContext else {
            precondition(false)
            return
        }
        if context.invalidateEverything {
            self.data.prepareInitial(for: self.collectionView,
                                     estimatedItemHeight: self.estimatedItemHeight,
                                     minHeaderHeight: self.stickyHeaderMinHeight)
        } else {
            self.updateAccordingToInvalidation(context: context)
        }
        print("InvalidateLayout(with context:)\n" + (context as! CollectionViewInvalidationContext).debugDescr)
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let stickyAttrs = self.data.firstItemAttributes(for: self.collectionView, minHeight: self.stickyHeaderMinHeight)
        var adjustedRect = rect
//        stickyAttrs.flatMap {
//            adjustedRect.origin.y += $0.frame.height
//            adjustedRect.size.height -= $0.frame.height
//        }

        var attrs = self.data.allAttributes(in: adjustedRect).compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
        stickyAttrs.flatMap { sticky in
            if let foundIdx = attrs.firstIndex(where: { $0.indexPath == sticky.indexPath }) {
                attrs.remove(at: foundIdx)
            }
            attrs.append(sticky)
        }
        return attrs
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let rez = self.data.layoutAttributes(at: indexPath)
        print("Layout attr for item at: \(indexPath) - \(rez)")
//        return nil
        return rez
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                              at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }

    override public func layoutAttributesForDecorationView(ofKind elementKind: String,
                                                           at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }


    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        if self.data.shouldInvalidateOn(rect: newBounds) {
//            return true
//        }
//        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        return true
    }

    @available(iOS 7.0, *)
    override public func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let ctx = super.invalidationContext(forBoundsChange: newBounds)
        guard let context = ctx as? CollectionViewInvalidationContext else {
            return ctx
        }
        if (collectionView!.isDecelerating) {
            print("===== DECELERATING =====")
        }
        context.invalidatedDueToBoundsChange = true
        print("InvalidationContext(forBoundsChange newBounds: \(newBounds)\n" + (context as! CollectionViewInvalidationContext).debugDescr)
        return context
    }


    @available(iOS 8.0, *)
    override public func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
                                                withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        // NOTE: as for now we only take into account cells attributes
        guard originalAttributes.representedElementCategory == .cell else {
            return false
        }
        if self.data.shouldAvoidUpdaringPreffered(attributes: preferredAttributes) {
            return false
        }
//        let rez = super.shouldInvalidateLayout(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        return originalAttributes != preferredAttributes
    }

    @available(iOS 8.0, *)
    override public  func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
                                              withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        if let context = context as? CollectionViewInvalidationContext {
            context.updatedPreferredAttributes = preferredAttributes
        }
        print("InvalidationContext(forPreferredLayoutAttributes preferredAttributes):\n" + (context as! CollectionViewInvalidationContext).debugDescr)
        return context
    }

    override public var collectionViewContentSize: CGSize {
        return self.data.estimatedContentSize
    }

    override public func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        for item in updateItems {
            switch item.updateAction {
            case .insert:
                self.data.updateForInserted(
                    at: item.indexPathAfterUpdate.unsafelyUnwrapped,
                    on: self.collectionView,
                    estimatedHeight: self.estimatedItemHeight)
            case .delete:
                self.data.updateForDeleted(at: item.indexPathBeforeUpdate.unsafelyUnwrapped)
            case .move:
                self.data.updateForMoved(from: item.indexPathBeforeUpdate.unsafelyUnwrapped,
                                         to: item.indexPathAfterUpdate.unsafelyUnwrapped)
            case .reload, .none:
                break
            @unknown default:
                break
            }
        }
    }

    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                  withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let rez = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        print("TargetContentOffset: \(proposedContentOffset) - \(velocity) - \(rez)")
        return rez
    }

    @available(iOS 7.0, *)
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let rez = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        print("TargetContentOffset: \(proposedContentOffset) - \(rez)")
        return rez
    }

    override public func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.data.layoutAttributes(at: itemIndexPath)
    }

    override public func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.data.layoutAttributes(at: itemIndexPath)
    }

    // MARK: - Private
    private let headerIndexPath = IndexPath(item: 0, section: 0)
    private let data = CollectionViewLayoutData()

    private func updateAccordingToInvalidation(context: CollectionViewInvalidationContext) {
        if let updatedAttrs = context.updatedPreferredAttributes {
            self.data.updateForPreffered(attributes: updatedAttrs, in: self.collectionView, in: context)
        }
        if context.invalidatedDueToBoundsChange {
            self.data.updateDueToBoundsChange(on: self.collectionView)
        }
    }
}

final class AttributesDataHolder {
    private(set) var height: CGFloat
    private(set) var yOffset: CGFloat
    private var lazyAttributes: Attributes?

    private let xOffset: CGFloat
    private let width: CGFloat

    init(height: CGFloat, xOffset: CGFloat, yOffset: CGFloat, width: CGFloat) {
        self.height = height
        self.yOffset = yOffset
        self.xOffset = xOffset
        self.width = width
    }

    func adjustHeight(by diff: CGFloat) {
        self.height += diff
        guard let attrs = self.lazyAttributes else {
            return
        }
        attrs.frame.size.height += diff
    }

    func set(yOffset: CGFloat) {
        self.yOffset = yOffset
        guard let attrs = self.lazyAttributes else {
            return
        }
        attrs.frame.origin.y = yOffset
    }

    func adjustYOffset(by diff: CGFloat) {
        self.yOffset += diff
        guard let attrs = self.lazyAttributes else {
            return
        }
        attrs.frame.origin.y += diff
    }

    func set(indexPath: IndexPath?) {
        guard let indexPath = indexPath, let attrs = self.lazyAttributes else {
            return
        }
        attrs.indexPath = indexPath
    }

    func adjustRow(by diff: Int) {
        guard diff != 0 else { return }
        guard let attrs = self.lazyAttributes else {
            return
        }

        attrs.indexPath.item += diff
    }

    func attributes(for indexPath: IndexPath) -> Attributes {
        guard let attrs = self.lazyAttributes else {
            let attrs = self.makeAttributes(for: indexPath, yOffset: self.yOffset)
            self.lazyAttributes = attrs
            return attrs
        }
        precondition(attrs.indexPath == indexPath)
        return attrs
    }

    func intersectsWith(rect: CGRect) -> Bool {
        let maxY = self.maxY
        return
            (rect.minY <= self.yOffset && self.yOffset <= rect.maxY) ||
            (rect.minY <= maxY && maxY <= rect.maxY)
    }

    var maxY: CGFloat {
        return self.yOffset + self.height
    }

    var indexPath: IndexPath? {
        return self.lazyAttributes?.indexPath
    }

    // MARK: - Private
    private func makeAttributes(for indexPath: IndexPath, yOffset: CGFloat) -> Attributes {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let frame = CGRect(
            origin: CGPoint(x: self.xOffset, y: yOffset),
            size: CGSize(width: self.width, height: self.height))
        attr.frame = frame
        return attr
    }
}

final class CollectionViewLayoutData {
    private struct StickyHeaderData {
        let indexPath: IndexPath
        let dataHolder: AttributesDataHolder
        var prefferedAttrsHeight: CGFloat?
    }
    private var stickyHeaderData: StickyHeaderData?
    private var stickyHeaderMinHeight: CGFloat?
    private var itemsCache = [[AttributesDataHolder]]()
    private(set) var estimatedContentSize: CGSize = .zero

    func prepareInitial(for collectionView: UICollectionView?, estimatedItemHeight: CGFloat, minHeaderHeight: CGFloat) {
        defer {
            // NOTE: force nil to surely get a new header data
            //       it's needed when collection view changes it's size so frame will be updated
            //       on captured item
            self.stickyHeaderData = nil
            self.updateStickyHeaderData()
            self.stickyHeaderMinHeight = minHeaderHeight
        }

        self.clear()
        guard let collectionView = collectionView else { return }
        collectionView.contentInset.top = minHeaderHeight

        let insets = collectionView.contentInset
        let (xOffset, _, width) = self.getInitialFrameData(from: collectionView)
        var yOffset: CGFloat = -minHeaderHeight
        var height: CGFloat = minHeaderHeight
        for i in 0..<collectionView.numberOfSections {
            var items = [AttributesDataHolder]()
            for _ in 0..<collectionView.numberOfItems(inSection: i) {
                items.append(AttributesDataHolder(
                    height: height,
                    xOffset: xOffset,
                    yOffset: yOffset,
                    width: width))
                yOffset += height
                height = estimatedItemHeight
            }
            self.itemsCache.append(items)
        }
        self.estimatedContentSize = CGSize(
            width: collectionView.bounds.width,
            height: yOffset + insets.bottom)
    }

    func allAttributes(in bounds: CGRect) -> [Attributes] {
        var result = [Attributes]()
        for sec in 0..<self.itemsCache.count {
            for row in 0..<self.itemsCache[sec].count {
                let item = self.itemsCache[sec][row]
                result.append(item.attributes(for: IndexPath(item: row, section: sec)))
            }
        }
        return result

//        let ip = self.findFirstClosestToTopItem(for: bounds)
//
//        var result = [Attributes]()
//        var rowStart = ip.row
//        for sec in ip.section..<self.itemsCache.count {
//            for row in rowStart..<self.itemsCache[sec].count {
//                let item = self.itemsCache[sec][row]
//                if item.intersectsWith(rect: bounds) {
//                    result.append(item.attributes(for: IndexPath(item: row, section: sec)))
//                }
//                if item.maxY > bounds.maxY {
//                    break
//                }
//            }
//            rowStart = 0
//        }
//        return result
    }

    func layoutAttributes(at indexPath: IndexPath) -> Attributes? {
        guard indexPath.section >= 0, indexPath.section < self.itemsCache.count else {
            return nil
        }
        let section = self.itemsCache[indexPath.section]
        guard indexPath.item >= 0, indexPath.item < section.count else {
            return nil
        }
        return section[indexPath.row].attributes(for: indexPath)
    }

    func firstItemAttributes(for collectionView: UICollectionView?, minHeight: CGFloat) -> Attributes? {
        guard let collectionView = collectionView else { return nil }
        guard let data = self.stickyHeaderData else { return nil }
        guard let attrs = data.dataHolder.attributes(for: data.indexPath).copy() as? Attributes else { return nil }

        let contentOffset = collectionView.contentOffset
        var newFrame = attrs.frame
        if contentOffset.y < 0.0, -contentOffset.y > minHeight  {
            newFrame.size.height = abs(contentOffset.y)
        } else {
            newFrame.size.height = minHeight
        }
//        let topInset = min(data.prefferedAttrsHeight ?? newFrame.size.height, newFrame.size.height)
//        collectionView.contentInset.top = min(data.prefferedAttrsHeight ?? 0.0, newFrame.size.height)
//        let desiredHeight = max(newFrame.size.height - contentOffset.y, minHeight)
        newFrame.origin.y = contentOffset.y
//        if desiredHeight > newFrame.size.height {
//            newFrame.size.height = desiredHeight
//        } else {
//            newFrame.origin.y -= (newFrame.height - desiredHeight)
//        }
//        newFrame.size.height = max(newFrame.size.height - contentOffset.y, minHeight)
        attrs.frame = newFrame
        attrs.zIndex = 1

        return attrs
    }

    func updateForPreffered(attributes: Attributes,
                            in view: UICollectionView?,
                            in context: UICollectionViewLayoutInvalidationContext) {
        print("Attributes being update: \(attributes)")
        // NOTE: as for now we do only expect item view attributes to be updated
        precondition(attributes.representedElementCategory == .cell)
        let ip = attributes.indexPath
        let item = self.itemsCache[ip.section][ip.row]
        let diff = attributes.frame.height - item.height

        if let stickyHeaderIndexPath = self.stickyHeaderData?.indexPath,
            stickyHeaderIndexPath == attributes.indexPath {
            self.stickyHeaderData?.prefferedAttrsHeight = attributes.frame.height
            if attributes.frame.height < (self.stickyHeaderMinHeight ?? CGFloat.greatestFiniteMagnitude) {
                return
            }
//            item.adjustYOffset(by: -diff)
//            item.adjustHeight(by: diff)
//            context.contentOffsetAdjustment = CGPoint(x: 0, y: -diff)
            return
        }

        item.adjustHeight(by: diff)
        let affectedItems = self.adjustYOffset(by: diff, section: ip.section, row: ip.row + 1)
//        context.invalidateItems(at: [ip])
//        context.contentOffsetAdjustment = CGPoint(x: 0, y: diff)
//        context.contentSizeAdjustment = CGSize(width: 0, height: diff)
    }

    func updateForInserted(at indexPath: IndexPath, on collectionView: UICollectionView?, estimatedHeight: CGFloat) {
        guard let collectionView = collectionView else { return }
        defer { self.updateStickyHeaderData() }

        let (xOffset, yOffset, width) = self.getInitialFrameData(from: collectionView)
        let y: CGFloat
        if let hasMoving = self.getFirstDataHolder(atOrNext: indexPath) {
            y = hasMoving.yOffset
        } else if let hasBefore = self.getClosestDataHolder(before: indexPath) {
            y = hasBefore.maxY
        } else /* That's the first insertion in an empty set */ {
            y = yOffset
        }
        let attrsHolder = AttributesDataHolder(
            height: estimatedHeight,
            xOffset: xOffset,
            yOffset: y,
            width: width)
        self.itemsCache[indexPath.section].insert(attrsHolder, at: indexPath.row)
        self.adjustYOffset(
            by: estimatedHeight,
            section: indexPath.section,
            row: indexPath.row + 1)

        guard indexPath.row + 1 < self.itemsCache[indexPath.section].count else { return }

        for row in (indexPath.row + 1)..<self.itemsCache[indexPath.section].count {
            let item = self.itemsCache[indexPath.section][row]
            item.adjustRow(by: +1)
        }
    }

    func updateForDeleted(at indexPath: IndexPath) {
        defer { self.updateStickyHeaderData() }

        let item = self.itemsCache[indexPath.section][indexPath.row]
        self.itemsCache[indexPath.section].remove(at: indexPath.row)
        self.adjustYOffset(by: -item.height, section: indexPath.section, row: indexPath.row)
        for row in indexPath.row..<self.itemsCache[indexPath.section].count {
            let item = self.itemsCache[indexPath.section][row]
            item.adjustRow(by: -1)
        }
    }

    func updateForMoved(from: IndexPath, to: IndexPath) {
        guard from != to else { return }
        defer { self.updateStickyHeaderData() }

        let fromItem = self.itemsCache[from.section][from.item]
        let toItem = self.itemsCache[to.section][to.item]

        let isMovingLeft = (from > to)
        let diff = (isMovingLeft) ? fromItem.height : fromItem.height
        let advanceValue = (isMovingLeft) ? -1 : 1

        var curSec = from.section
        var curRow = from.item
        let startSec = curSec
        let endSec = to.section
        let endRow = to.item
        let isMoveInTheSameSection = curSec == endSec
        let sameSectionAdvance = (isMovingLeft) ? 1 : -1
        let otherSectionsStartSecAdvance = (isMovingLeft) ? 0 : 1
        let otherSectionsEndSecAdvance = (isMovingLeft) ? 1 : 0

        fromItem.set(yOffset: toItem.yOffset)
        fromItem.set(indexPath: toItem.indexPath)

        self.itemsCache[curSec].remove(at: curRow)
        self.itemsCache[endSec].insert(fromItem, at: endRow)

        repeat {
            if curRow < 0 || curRow >= self.itemsCache[curSec].count {
                curSec = curSec.advanced(by: advanceValue)
                curRow = (isMovingLeft) ? self.itemsCache[curSec].count : 0
                continue
            }

            let item = self.itemsCache[curSec][curRow]
            item.adjustYOffset(by: diff)

            curRow = curRow.advanced(by: advanceValue)
            guard !isMoveInTheSameSection else {
                item.adjustRow(by: sameSectionAdvance)
                continue
            }
            if curSec == startSec {
                item.adjustRow(by: otherSectionsStartSecAdvance)
            }
            if curSec == endSec {
                item.adjustRow(by: otherSectionsEndSecAdvance)
            }
        } while(!(curSec == endSec && curRow == endRow))

        let lastItemsInSection = isMovingLeft ? from.row + 1 : to.row + 1
        guard lastItemsInSection < self.itemsCache[to.section].count else {
            return
        }

        for row in lastItemsInSection..<self.itemsCache[to.section].count {
            let item = self.itemsCache[to.section][row]
            item.adjustRow(by: 1)
        }
    }

    func updateDueToBoundsChange(on collectionView: UICollectionView?) {
        guard let collectionView = collectionView else { return }
//        guard let headerData =  else { return }
        guard let headerPrefferedHeight = self.stickyHeaderData?.prefferedAttrsHeight else { return }
        guard let minHeaderHeight = self.stickyHeaderMinHeight else { return }

        let contentOffset = collectionView.contentOffset
        let topInset: CGFloat
        if contentOffset.y < -minHeaderHeight {
            topInset = min(headerPrefferedHeight, -contentOffset.y)
        } else {
            topInset = minHeaderHeight
        }
        if topInset != collectionView.contentInset.top {
//            collectionView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        }
    }

    func clear() {
        self.itemsCache.removeAll()
        self.estimatedContentSize = .zero
    }

    func shouldAvoidUpdaringPreffered(attributes: Attributes) -> Bool {
        guard let stickyHeaderData = self.stickyHeaderData else {
            return false
        }
        guard stickyHeaderData.indexPath == attributes.indexPath else {
            return false
        }
        guard let height = stickyHeaderData.prefferedAttrsHeight, height == attributes.frame.height else {
            return false
        }
        return true
    }

    // MARK: - Private
    private func updateStickyHeaderData() {
        guard let sectionItem = self.itemsCache.enumerated().first(where: { $0.element.count > 0 }) else {
            self.stickyHeaderData = nil
            return
        }
        guard let firstItem = self.itemsCache[sectionItem.offset].first else {
            self.stickyHeaderData = nil
            return
        }
        if let current = self.stickyHeaderData,
            current.indexPath.section == sectionItem.offset,
            current.indexPath.row == 0 {
            return
        }

        let ip = IndexPath(item: 0, section: sectionItem.offset)
        self.stickyHeaderData = StickyHeaderData(
            indexPath: ip,
            dataHolder: firstItem,
            prefferedAttrsHeight: nil)
    }

    private func getInitialFrameData(from view: UICollectionView) -> (xOffset: CGFloat, yOffset: CGFloat, width: CGFloat) {
        let insets = view.contentInset
        let xOffset = insets.left
        let width = view.bounds.width - xOffset - insets.right
        let yOffset: CGFloat
        if #available(iOS 11, *) {
            yOffset = view.adjustedContentInset.top
        } else {
            yOffset = insets.top
        }

        return (xOffset, yOffset, width)
    }

    private func findFirstClosestToTopItem(for bounds: CGRect) -> IndexPath {
        let section = self.findFirstClosestSection(for: bounds)
        guard section > self.itemsCache.count else { return IndexPath(item: 0, section: 0) }
        let items = self.itemsCache[section]

        var row = 0
        var left = 0
        var right = items.count - 1

        var diff: CGFloat
        if left < right, let firstItem = items.first {
            diff = bounds.minY - firstItem.yOffset
        } else {
            diff = CGFloat.greatestFiniteMagnitude
        }

        while left <= right {
            let middle = Int(floor(Double(left + right) / 2.0))

            let item = items[middle]
            let newDiff = bounds.minY - item.yOffset
            if newDiff >= 0.0 && diff > newDiff {
                diff = newDiff
                row = middle
            }

            if 0.0 < newDiff {
                left = middle + 1
            } else if 0.0 > newDiff {
                right = middle - 1
            } else {
                break
            }
        }

        return IndexPath(row: row, section: section)
    }

    private func findFirstClosestSection(for bounds: CGRect) -> Int {
        let nonEmptySections = self.itemsCache.indices.filter { self.itemsCache[$0].count > 0 }
        var left = 0
        var right = nonEmptySections.count - 1

        var result = 0
        var diff: CGFloat
        if left < right, let firstItem = self.itemsCache[nonEmptySections[0]].first {
            diff = bounds.minY - firstItem.yOffset
        } else {
            diff = CGFloat.greatestFiniteMagnitude
        }

        while left <= right {
            let middle = Int(floor(Double(left + right) / 2.0))
            let item = self.itemsCache[nonEmptySections[middle]].first.unsafelyUnwrapped
            let newDiff = bounds.minY - item.yOffset
            if newDiff >= 0.0 && diff > newDiff {
                diff = newDiff
                result = middle
            }

            if 0.0 < newDiff {
                left = middle + 1
            } else if 0.0 > newDiff {
                right = middle - 1
            } else {
                return result
            }
        }

        return result
    }

    private func getFirstDataHolder(atOrNext indexPath: IndexPath) -> AttributesDataHolder? {
        if indexPath.item < self.itemsCache[indexPath.section].count {
            return self.itemsCache[indexPath.section][indexPath.row]
        }

        let nextSection = indexPath.section + 1
        guard nextSection < self.itemsCache.count else { return nil }

        for sec in nextSection..<self.itemsCache.count {
            if let item = self.itemsCache[sec].first {
                return item
            }
        }
        return nil
    }

    private func getClosestDataHolder(before indexPath: IndexPath) -> AttributesDataHolder? {
        let previous = indexPath.item - 1
        if previous >= 0, previous < self.itemsCache[indexPath.section].count {
            return self.itemsCache[indexPath.section][previous]
        }

        let closestSection = indexPath.section - 1
        guard closestSection > 0 else { return nil }

        for sec in (0..<closestSection).reversed() {
            if let item = self.itemsCache[sec].last {
                return item
            }
        }
        return nil
    }

    // NOTE: returns affected index paths
    private func adjustYOffset(by diff: CGFloat, section: Int, row: Int) -> [IndexPath] {
        var result = [IndexPath]()
        var rowStart = row
        for sec in section..<self.itemsCache.count {
            if rowStart >= self.itemsCache[sec].count {
                rowStart = 0
                continue
            }

            for row in rowStart..<self.itemsCache[sec].count {
                let item = self.itemsCache[sec][row]
                result.append(IndexPath(item: row, section: sec))
                item.adjustYOffset(by: diff)
            }

            rowStart = 0
        }
        self.estimatedContentSize.height += diff
        return result
    }
}
























/////////////////////////////////////////////////////////////////////////////
final class CollectionViewInvalidationContext: UICollectionViewLayoutInvalidationContext {
    var invalidatedDueToBoundsChange: Bool = false
    var updatedPreferredAttributes: UICollectionViewLayoutAttributes?

    var debugDescr: String {
        var values = [String]()
        if self is AnyObject {
            values.append("***** \(type(of: self)) - <\(Unmanaged.passUnretained(self as! AnyObject).toOpaque())>*****")
        } else {
            values.append("***** \(type(of: self)) *****")
        }
        values.append("updatedPreferredAttributes: \(self.updatedPreferredAttributes)")
        values.append("invalidateEverything: \(self.invalidateEverything)")
        values.append("invalidateDataSourceCounts: \(self.invalidateDataSourceCounts)")
        values.append("invalidatedItemIndexPaths: \(self.invalidatedItemIndexPaths)")
        values.append("invalidatedSupplementaryIndexPaths: \(self.invalidatedSupplementaryIndexPaths)")
        values.append("invalidatedDecorationIndexPaths: \(self.invalidatedDecorationIndexPaths)")
        values.append("contentOffsetAdjustment: \(self.contentOffsetAdjustment)")
        values.append("contentSizeAdjustment: \(self.contentSizeAdjustment)")
        values.append("previousIndexPathsForInteractivelyMovingItems: \(self.previousIndexPathsForInteractivelyMovingItems)")
        values.append("targetIndexPathsForInteractivelyMovingItems: \(self.targetIndexPathsForInteractivelyMovingItems)")
        values.append("interactiveMovementTarget: \(self.interactiveMovementTarget)")
        return values.joined(separator: "\n") + "\n\n\n"
    }
}

private extension UICollectionViewLayoutAttributes {
    func printDiff(for another: UICollectionViewLayoutAttributes) {
        var diffs = [String]()
        if self.frame != another.frame {
            diffs.append("Frame: \(self.frame) | \(another.frame)")
        }
        if self.center != another.center {
            diffs.append("Center: \(self.center) | \(another.center)")
        }
        if self.size != another.size {
            diffs.append("Size: \(self.size) | \(another.size)")
        }
        if self.bounds != another.bounds {
            diffs.append("Bounds: \(self.bounds) | \(another.bounds)")
        }
        if self.transform != another.transform {
            diffs.append("Transform: \(self.transform) | \(another.transform)")
        }
        if self.alpha != another.alpha {
            diffs.append("Alpha: \(self.alpha) | \(another.alpha)")
        }
        if self.zIndex != another.zIndex {
            diffs.append("zIndex: \(self.zIndex) | \(another.zIndex)")
        }
        if self.isHidden != another.isHidden {
            diffs.append("IsHidden: \(self.isHidden) | \(another.isHidden)")
        }
        if self.indexPath != another.indexPath {
            diffs.append("IndexPath: \(self.indexPath) | \(another.indexPath)")
        }
        print(diffs.joined(separator: "\n"))
        print("\n\n")
    }
}
