//
//  ViewController.swift
//  TestingStickyHeader
//
//  Created by Dmytro Koriakin on 20/02/2020.
//  Copyright © 2020. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func handleTap() {
        let testingVC = TestingViewController()
        self.navigationController?.pushViewController(testingVC, animated: true)
    }

    @IBAction func handleTesingTap() {
        let testingVC = TestingAnotherVC()
        self.navigationController?.pushViewController(testingVC, animated: true)
    }

    @IBAction func handleTesingScrollingTap() {
        let testingVC = TestingCVScrollingVC()
        self.navigationController?.pushViewController(testingVC, animated: true)
    }

    @IBAction func handleTesingTableViewScrollingTap() {
        let testingVC = TestingTVScrollingVC()
        self.navigationController?.pushViewController(testingVC, animated: true)
    }

    @IBAction func handleTesingKVOTableViewTap() {
        let testingVC = TestingKVO_VC()
        self.navigationController?.pushViewController(testingVC, animated: true)
    }
}

