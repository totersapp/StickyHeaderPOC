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
                header = StickyHeader()
                header!.scrollView = self
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

        let headerView = Bundle.main.loadNibNamed("MyHeaderView", owner: nil, options: nil)?.first as! MyHeaderView
        headerView.layer.borderColor = UIColor.red.cgColor
        headerView.layer.borderWidth = 5
        table.stickyHeader.height = headerView.frame.height
        table.stickyHeader.minimumHeight = 64
        table.stickyHeader.view = headerView

        //        navigationView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        //        navigationView.backgroundColor = .green
        //        navigationView.alpha = 0
        //        table.stickyHeader.view = navigationView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            //            self.table.scrollToRow(at: IndexPath(row: 0, section: 49), at: .top, animated: true)
        }
    }

    // MARK: Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 50
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 200
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

