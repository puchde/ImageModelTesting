//
//  HeadlinesTableViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/6.
//

import UIKit
import SafariServices
import NVActivityIndicatorView
import Toast
import SwiftProtobuf


class HeadlinesTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var defaultCoverView: UIView!
    private let displayMode: DisplayMode = newsSettingManager.getDisplayMode()
    let freshControl = UIRefreshControl()
    var customFreshControl: UIView!
    var freshControlAct = false
    var articles = [Article]()
    var filterArticles = [Article]()
    var page: Int?
    var articlesNumber = 0
    var selectNewsUrl = ""
    var isLoading = false
    var newsCountry: CountryCode = newsSettingManager.getCountry()

    var searchQuery: String {
        get {
            newsSettingManager.getSearchQuery()
        }
    }
    var apiLoading = false
    
    var backgroundView: UIView?
    var loadingCover: NVActivityIndicatorView?
    
    var dataReloadTime: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSearchNotification()
        setupLoadingView()
        loadNewsData()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setDisappear()
    }
    
    deinit {
        print("\(String(describing: page)) is deinit")
    }
}

//MARK: Init
extension HeadlinesTableViewController {
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        freshControl.tintColor = .clear
        freshControl.backgroundColor = .clear
        tableView.refreshControl = freshControl
        loadCustomRefresh()
        defaultCoverView.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: Notification.Name("\(displayMode) - ScrollToTop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataAct), name: Notification.Name("\(displayMode) - ReloadNewsData"), object: nil)
    }
    
    func loadCustomRefresh() {
        customFreshControl = UIView(frame: freshControl.frame)
        let arrowUpImage = UIImageView(frame: CGRect(x: 0, y: freshControl.frame.width * 0.2, width: self.view.frame.width, height: self.view.frame.width * 0.2))
        arrowUpImage.image = UIImage(systemName: "arrow.triangle.2.circlepath")?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        arrowUpImage.contentMode = .scaleAspectFit
        customFreshControl.addSubview(arrowUpImage)
        freshControl.addSubview(customFreshControl)
        freshControl.clipsToBounds = true
    }
    
    func setupLoadingView() {
        if backgroundView == nil {
            let centerY = self.parent?.view.center.y ?? self.view.center.y
            loadingCover = NVActivityIndicatorView(frame: CGRect(origin: CGPoint(x: (UIScreen.main.bounds.size.width / 2) - 50, y: centerY - 50), size: CGSize(width: 100, height: 100)), type: .ballRotateChase, color: traitCollection.userInterfaceStyle == .dark ? .white : .systemGray3)
            self.view.addSubview(loadingCover!)
            backgroundView = UIView(frame: tableView.frame)
            backgroundView?.backgroundColor = .systemBackground
            backgroundView?.addSubview(loadingCover!)
            backgroundView?.isHidden = true
            self.view.addSubview(backgroundView!)
        }
    }
    
    func loadingCoverAction(start: Bool) {
        if start {
            loadingCover?.startAnimating()
        } else {
            loadingCover?.stopAnimating()
        }
        tableView.isScrollEnabled = start ? false : true
        backgroundView?.isHidden = start ? false : true
    }
}

//MARK: Disappear
extension HeadlinesTableViewController {
    func setDisappear() {
        if displayMode == .search {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("\(displayMode) - ReloadNewsData"), object: nil)
            print("setDisappear")
        }
        loadingCoverAction(start: false)
    }

    func setSearchNotification() {
        if displayMode == .search {
            NotificationCenter.default.addObserver(self, selector: #selector(reloadDataAct), name: Notification.Name("\(displayMode) - ReloadNewsData"), object: nil)
        }
    }
}

//MARK: TableView Data
extension HeadlinesTableViewController {

    @objc func reloadDataAct() {
        updateReloadSetting()
    }

    func updateReloadSetting() {
        switch displayMode {
        case .headline:
            if newsCountry == newsSettingManager.getCountry() {
                if Date.now < dataReloadTime.addingTimeInterval(3 * 60) {
                    print("reload time return")
                    filterBlockedSource()
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                    return
                }
            } else {
                newsCountry = newsSettingManager.getCountry()
                updateReloadSetting()
            }
            break
        case .search:
            break
        }
        articles.removeAll()
        loadNewsData()
    }
    
    func loadNewsData() {
        if isLoading {
            print("Loading啦")
            return
        } else {
            if articles.count < articlesNumber || articles.count == 0 {
                isLoading = true
                
                self.tableView.refreshControl?.endRefreshing()
                loadingCoverAction(start: true)
                self.defaultCoverView.isHidden = true
                
                switch displayMode {
                case .headline:
                    guard let page, let category = Category.fromOrder(page)?.rawValue else {
                        loadingCoverAction(start: false)
                        return
                    }
                    APIManager.topHeadlines(country: newsCountry.rawValue, category: category) { result in
                        self.resultCompletion(result: result)
                        self.loadingCoverAction(start: false)
                    }
                    break
                case .search:
                    let language = newsSettingManager.getSearchLanguage().rawValue
                    APIManager.searchNews(query: searchQuery, language: language) { result in
                        self.resultCompletion(result: result)
                        self.loadingCoverAction(start: false)
                    }
                    break
                }
            } else {
                loadingCoverAction(start: false)
                self.tableView.refreshControl?.endRefreshing()
                filterBlockedSource()
            }
        }
    }

    func resultCompletion(result: (Result<NewsAPIProtobufResponse, Error>)) -> Void {
        switch result {
        case .success(let success):
            if success.status == "OK" {
                self.articlesNumber = success.totalResults
                do {
                    let articles = try ArticlesTotalProtobuf(serializedData: success.articles)
                    articles.articles.forEach { a in
                        let source = Source(id: a.source.id, name: a.source.name)
                        let article = Article(source: source, author: a.author, title: a.title, description: a.description_p, url: a.url, urlToImage: a.urlToImage, publishedAt: a.publishedAt, content: a.content)
                        self.articles.append(article)
                    }
                    filterBlockedSource()
                } catch {
                    print(error)
                }
                self.defaultCoverView.isHidden = self.articles.isEmpty ? false : true
                dataReloadTime = Date.now
            } else {
                self.view.makeToast("取得資料錯誤")
            }
        case .failure(let failure):
            print(failure)
            self.view.makeToast("取得資料失敗")
        }
        self.isLoading = false
        self.tableView.reloadData()
    }
    
    func filterBlockedSource() {
        let source = newsSettingManager.getBlockedSource()
        filterArticles = articles.filter{!source.contains($0.author ?? "")}
    }
}

//MARK: TableView
extension HeadlinesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell, !articles.isEmpty {
            let newsData = filterArticles[indexPath.row]
            cell.updateArticleInfo(activeVC: self, article: newsData)
            tableView.deselectRow(at: indexPath, animated: false)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        selectNewsUrl = filterArticles[indexPath.row].url
//        performSegue(withIdentifier: "toWebView", sender: self)
        if let url = URL(string: selectNewsUrl) {
            let vc = getSafariVC(url: url, delegateVC: self)
            self.present(vc, animated: true)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    @objc func scrollToTop() {
        if !articles.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

// MARK: - TableView Cell Preview
extension HeadlinesTableViewController: NewsTableViewProtocal {
    var newsTableView: UITableView {
        self.tableView
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            self.makePreviewMenu(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration, isShow: true)
    }

    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration, isShow: false)
    }
}

//MARK: News Cell Delegate
extension HeadlinesTableViewController: NewsCellDelegate {
    func reloadCell() {
        filterBlockedSource()
        if let indexPaths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
}

//MARK: ScrollView
extension HeadlinesTableViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let screenHeight = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        
        if offsetY < 0 && !freshControlAct {
            // MARK: - 下拉動畫
            customFreshAnimation(offsetY: offsetY)
        } else if -1 <= offsetY && freshControlAct {
            // MARK: - 動畫結束重設參數
            freshControlAct = false
        } else {
            if contentHeight != 0 && offsetY + screenHeight > (contentHeight) {
                print("一半啦")
                loadNewsData()
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if freshControl.isRefreshing {
            reloadDataAct()
            customFreshAnimation()
            freshControlAct = true
        }
    }
    
    func customFreshAnimation(offsetY: CGFloat = 0) {
        let viewHeight = self.customFreshControl.frame.height
        let viewTranslationY = -viewHeight < offsetY ? offsetY : -viewHeight
        let isSwipe = offsetY == 0.0 ? false : true
        let arrowView = self.customFreshControl.subviews[0]
        
        if isSwipe {
            UIView.animate(withDuration: 0.15) {
                arrowView.transform = CGAffineTransform(translationX: 0, y: viewTranslationY)
                self.customFreshControl.subviews[0].alpha = 1
            }
            
            if arrowView.layer.animationKeys() == nil {
                arrowView.startRotationAnimate()
            }
        } else if offsetY == 0 {
            UIView.animate(withDuration: 0.15) {
                arrowView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.customFreshControl.subviews[0].alpha = 0
            } completion: { _ in
                arrowView.removeAnimate()
            }
        }
    }
}

//MARK: Segue
extension HeadlinesTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWebView", let webView = segue.destination as? WebViewViewController {
            webView.urlString = selectNewsUrl
        }
    }
}

extension HeadlinesTableViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return []
    }
}
