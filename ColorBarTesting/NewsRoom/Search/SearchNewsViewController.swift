//
//  SearchNewsViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/3.
//

import UIKit

class SearchNewsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchSettingTableView: UITableView!
    @IBOutlet weak var searchRecordTableView: UITableView!
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!
    
    var searchSettingHeader = ["搜尋內容", "搜尋語言地區", "搜尋排序"]
    var searchIn = ""
    var searchRecord: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        searchSettingTableView.reloadData()
        searchRecordTableView.reloadData()
    }
}

//MARK: Init
extension SearchNewsViewController {
    func viewInit() {
        leftButtonItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 25), .foregroundColor: UIColor.label], for: .disabled)
        leftButtonItem.isEnabled = false
        searchBar.delegate = self
        searchSettingTableView.clipsToBounds = true
        searchSettingTableView.layer.cornerRadius = 20
        searchSettingTableView.isScrollEnabled = false
        searchSettingTableView.delegate = self
        searchSettingTableView.dataSource = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSearchSettingVC))
        searchSettingTableView.addGestureRecognizer(tap)
        searchRecordTableView.delegate = self
        searchRecordTableView.dataSource = self
    }
}

//MARK: SearchBar
extension SearchNewsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchClick")
        guard let SearchContentVC = storyboard?.instantiateViewController(withIdentifier: "SearchContentViewController") as? SearchContentViewController, let searchString = searchBar.searchTextField.text else {
            return
        }
        newsSettingManager.updateSearchQuery(searchString)
        self.navigationController?.pushViewController(SearchContentVC, animated: true)
        view.endEditing(true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

//MARK: TableView Setting
extension SearchNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == searchSettingTableView {
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == searchSettingTableView {
            return searchSettingHeader[section]
        } else if tableView == searchRecordTableView {
            return "搜尋紀錄"
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == searchSettingTableView {
            return 3
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchSettingTableView {
            return 1
        } else if tableView == searchRecordTableView {
            return searchRecord.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var cellConfig = UIListContentConfiguration.cell()
        if tableView == searchSettingTableView {
            switch indexPath.section {
            case 0:
                cellConfig.text = newsSettingManager.getSearchIn(isForApi: false)
            case 1:
                cellConfig.text = newsSettingManager.getSearchLanguage().chineseName
            case 2:
                cellConfig.text = newsSettingManager.getSearchSortBy().chineseName
            default:
                break
            }
        } else if tableView == searchRecordTableView {
            // TODO: 搜尋紀錄
            cellConfig.text = "Record"
        }
        cell.contentConfiguration = cellConfig
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if tableView == searchSettingTableView {
            showSearchSettingVC()
        } else if tableView == searchRecordTableView {
            showNewsTableVC(indexPath: indexPath)
        }
    }
}

extension SearchNewsViewController: searchSettingDelegate {
    func reloadView() {
        searchSettingTableView.reloadData()
    }
}
//MARK: Prepare to next view
extension SearchNewsViewController {
    @IBAction func settingButtonClick(_ sender: Any) {
        showSearchSettingVC()
    }
    
    @objc func showSearchSettingVC() {
        guard let SearchSettingVC = storyboard?.instantiateViewController(withIdentifier: "SearchSettingViewController") as? SearchSettingViewController else {
            return
        }
        SearchSettingVC.delegate = self
        DispatchQueue.main.async {
            self.present(SearchSettingVC, animated: true)
        }
    }

    func showNewsTableVC(indexPath: IndexPath) {
        guard let SearchContentVC = storyboard?.instantiateViewController(withIdentifier: "SearchContentViewController") as? SearchContentViewController else {
            return
        }
        let searchString = searchRecord[indexPath.row]
        newsSettingManager.updateSearchQuery(searchString)
        self.navigationController?.pushViewController(SearchContentVC, animated: true)
    }
}
