//
//  MarkListViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/16.
//

import UIKit

class MarkListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!
    var newsList = newsSettingManager.getNewsMarkList()
    var selectNewsUrl = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadDataAct()
        tableView.reloadData()
        checkYPosition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        checkYPosition(isShow: true)
    }
}

//MARK: Init
extension MarkListViewController {
    func initView() {
        leftButtonItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 25), .foregroundColor: UIColor.label], for: .disabled)
        leftButtonItem.isEnabled = false
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        let freshControl = UIRefreshControl()
        freshControl.addTarget(self, action: #selector(reloadDataAct), for: .valueChanged)
        tableView.refreshControl = freshControl
    }
}

//MARK: TableView
extension MarkListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        newsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell{
            let newsData = newsList[indexPath.row]
            cell.updateArticleInfo(activeVC: self, article: newsData)
            tableView.deselectRow(at: indexPath, animated: false)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let news = newsList[indexPath.row]
            newsSettingManager.deleteNewsMarkList(news)
            newsList = newsSettingManager.getNewsMarkList()
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        selectNewsUrl = newsList[indexPath.row].url
        performSegue(withIdentifier: "toWebView", sender: self)
        searchBar.resignFirstResponder()
    }
}

//MARK: News Cell Delegate
extension MarkListViewController: NewsCellDelegate {
    func reloadCell() {
        newsList = newsSettingManager.getNewsMarkList()
        tableView.reloadData()
    }
}

//MARK: SearchBar
extension MarkListViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchClick")
        guard let searchString = searchBar.searchTextField.text else {
            return
        }
        if !searchString.isEmpty {
            newsList = newsSettingManager.getNewsMarkList().filter({$0.author?.contains(searchString) ?? false || $0.content?.contains(searchString) ?? false || $0.description?.contains(searchString) ?? false || $0.title.contains(searchString)})
        } else {
            newsList = newsSettingManager.getNewsMarkList()
        }
        tableView.reloadData()
        searchBar.showsCancelButton = false
        view.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        newsList = newsSettingManager.getNewsMarkList()
        tableView.reloadData()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
}

extension MarkListViewController {
    @objc func reloadDataAct() {
        newsList = newsSettingManager.getNewsMarkList()
        tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
}

//MARK: ScrollView
extension MarkListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkYPosition()
    }

    func checkYPosition(isShow: Bool = false) {
        if isShow {
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.navigationBar.sizeToFit()
            return
        } else {
            if tableView.contentOffset.y > 0 {
                navigationController?.setNavigationBarHidden(true, animated: true)
            } else {
                navigationController?.setNavigationBarHidden(false, animated: true)
                navigationController?.navigationBar.sizeToFit()
            }
        }
    }
}

//MARK: Segue
extension MarkListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWebView", let webView = segue.destination as? WebViewViewController {
            webView.urlString = selectNewsUrl
        }
    }
}
