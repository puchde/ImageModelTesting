//
//  NewsCell.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import UIKit
import Kingfisher

class NewsCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var NewsDateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    var author: String {
        didSet {
            authorLabel.text = author
        }
    }
    
    var title: String {
        didSet {
            titleLabel.text = title
        }
    }
    
    var newsDate: String {
        didSet {
            NewsDateLabel.text = newsDate
        }
    }
    
    var newsUrl: String = "" {
        didSet {
            updateImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
  
    required init?(coder aDecoder: NSCoder) {
        self.author = ""
        self.title = ""
        self.newsDate = ""
        super.init(coder: aDecoder)
    }
    
    // code init
    //    required init(author: String, title: String, newsDate: String) {
    //        self.author = author
    //        self.title = title
    //        self.newsDate = newsDate
    //        super.init(style: .default, reuseIdentifier: "NewsCell")
    //    }
    
    func updateArticleInfo(author: String, title: String, newsDate: String, newsUrl: String) {
        self.author = author
        self.title = title
        self.newsDate = newsDate
        self.newsUrl = newsUrl
    }
    
    func updateImage() {
        guard let url = URL(string: newsUrl) else { return }
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url, placeholder: UIImage(named: "noPhoto"))
    }

}
