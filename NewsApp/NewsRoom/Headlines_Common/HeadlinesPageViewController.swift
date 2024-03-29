//
//  HeadlinesPageViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/6.
//

import UIKit

protocol HeadlinesDelegate: AnyObject {
    func updateClassify(page: Int)
}

class HeadlinesPageViewController: UIPageViewController {

    private let displayMode: DisplayMode = newsSettingManager.getDisplayMode()
    private var page = {
        switch newsSettingManager.getDisplayMode() {
        case .headline:
            return newsSettingManager.getCategory().order
        case .search:
            return 0
        }
    }()
    private var maxPage: Int {
        get {
            switch displayMode {
            case .headline:
                return Category.getTotal()
            case .search:
                return 1
            }
        }
    }
    weak var headlinesDelegate: HeadlinesDelegate?
    var tableVCs: [Int: HeadlinesTableViewController] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        headlinesDelegate?.updateClassify(page: page)
    }
}

//MARK: Init
extension HeadlinesPageViewController {
    func initView() {
        self.dataSource = self
        self.delegate = self
        guard let tableVC = getContentViewController(page: page) else { return }
        self.setViewControllers([tableVC], direction: .forward, animated: false)
        if displayMode == .search {
            for subview in self.view.subviews {
                if let scrollView = subview as? UIScrollView {
                    scrollView.bounces = false
                }
            }
        }
    }
}

//MARK: PageView Setting
extension HeadlinesPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func updatePage(_ newPage: Int) {
        page = newPage
    }
    
    func getContentViewController(page: Int) -> HeadlinesTableViewController? {
        if page < 0 || page >= maxPage {
            return nil
        }
        
        if let tableVC = tableVCs[page] {
            tableVC.page = page
            return tableVC
        }
        
        guard let tableVC = storyboard?.instantiateViewController(withIdentifier: "headlinesTableViewController") as? HeadlinesTableViewController else {
            return nil
        }

        tableVC.page = page
        tableVCs[page] = tableVC
        return tableVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getContentViewController(page: page - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getContentViewController(page: page + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            guard let tableVC = viewControllers?.first as? HeadlinesTableViewController, let nowPage = tableVC.page else {
                return
            }
            
            self.page = nowPage
            if let category = Category.fromOrder(nowPage) {
                newsSettingManager.updateSettingStorage(data: category)
            }
            
            headlinesDelegate?.updateClassify(page: page)
            print("didFinishAnimating, self.page:\(self.page)")
        }
    }
}
