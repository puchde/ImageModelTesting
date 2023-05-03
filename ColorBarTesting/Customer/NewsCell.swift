//
//  NewsCell.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import UIKit
import Kingfisher

protocol NewsCellDelegate {
    func reloadCell()
}

class NewsCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var NewsDateLabel: UILabel!
    @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!

    var article: Article? {
        didSet {
            newsUrl = article!.url
            author = article?.author ?? ""
            title = article?.title ?? ""
            newsDate = String(article?.publishedAt.prefix(10) ?? "")
            newsImageUrl = article?.urlToImage ?? ""
            updateMarkIcon()
        }
    }
    var isMark = false
    var activeVC: UIViewController?
    var newsUrl: String = ""
    var author: String = "" {
        didSet {
            authorLabel.text = author
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var newsDate: String = "" {
        didSet {
            NewsDateLabel.text = newsDate
        }
    }
    
    var newsImageUrl: String = "" {
        didSet {
            updateImage()
        }
    }

    var delegate: NewsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // code init
    //    required init(author: String, title: String, newsDate: String) {
    //        self.author = author
    //        self.title = title
    //        self.newsDate = newsDate
    //        super.init(style: .default, reuseIdentifier: "NewsCell")
    //    }
    
    func updateArticleInfo(activeVC: UIViewController, article: Article) {
        self.activeVC = activeVC
        self.delegate = activeVC as? any NewsCellDelegate
        self.article = article
    }
    
    func updateImage() {
        let placeholderImage = UIImage(named: "noPhoto")
        let placeholderColorImage = placeholderImage?.withTintColor(.secondaryLabel)
        cellImage.image = placeholderColorImage
        guard let url = URL(string: newsImageUrl) else { return }
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url, placeholder: placeholderColorImage)
    }

    @IBAction func saveNews(_ sender: Any) {
        if isMark {
            let alert = UIAlertController(title: "刪除標籤", message: "", preferredStyle: .alert)
            let cancelAct = UIAlertAction(title: "取消", style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
            let comfirm = UIAlertAction(title: "刪除", style: .destructive) { _ in
                newsSettingManager.deleteNewsMarkList(self.article!)
                self.updateMarkIcon()
                self.delegate?.reloadCell()
            }
            alert.addAction(cancelAct)
            alert.addAction(comfirm)
            activeVC?.present(alert, animated: true)

        } else {
            newsSettingManager.updateNewsMarkList(self.article!)
            delegate?.reloadCell()
        }
    }

    @IBAction func shareNews(_ sender: Any) {
        let textToShare = title
        let urlToShare = URL(string: newsUrl)
        let objectsToShare = [textToShare, urlToShare!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
        guard let activeVC else { return }
        activityViewController.popoverPresentationController?.sourceView = activeVC.view
        activeVC.present(activityViewController, animated: true, completion: nil)

    }

    func updateMarkIcon() {
        self.isMark = newsSettingManager.isMark(news: self.article!)
        if isMark {
            markButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            markButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
    }
}