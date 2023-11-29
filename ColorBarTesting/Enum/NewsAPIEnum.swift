//
//  NewsAPIEnum.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import Foundation

enum Category: String, CaseIterable, Codable {
    case general
    case business
    case health
    case technology
    case sports
    case entertainment
    
    var chineseName: String {
        switch self {
        case .business:
            return "商業"
        case .entertainment:
            return "娛樂"
        case .general:
            return "一般"
        case .health:
            return "健康"
        case .sports:
            return "體育"
        case .technology:
            return "科技"
        }
    }
    
    var order: Int {
        switch self {
        case .general:
            return 0
        case .business:
            return 1
        case .health:
            return 2
        case .technology:
            return 3
        case .sports:
            return 4
        case .entertainment:
            return 5
        }
    }
    
    static func getTotal() -> Int {
        return Category.allCases.count
    }
    
    static func fromOrder(_ order: Int) -> Category? {
        return Category.allCases.first(where: { $0.order == order })
    }
}

enum CountryCode: String, CaseIterable, Codable {
    case BR // 巴西
    case CN // 中國
    case DE // 德國
    case FR // 法國
    case GB // 英國
    case IN // 印度
    case TW // 意大利
    case JP // 日本
    case MX // 墨西哥
    case US // 美國
    
    var chineseName: String {
        switch self {
        case .BR:
            return "巴西"
        case .CN:
            return "中國"
        case .DE:
            return "德國"
        case .FR:
            return "法國"
        case .GB:
            return "英國"
        case .IN:
            return "印度"
        case .TW:
            return "台灣"
        case .JP:
            return "日本"
        case .MX:
            return "墨西哥"
        case .US:
            return "美國"
        }
    }
}

enum SearchIn: String, Codable {
    case title
    case description
    case content
    case all = "title,content,description"
    
    var chineseName: String {
        switch self {
        case .title:
            return "標題"
        case .description:
            return "簡述"
        case .content:
            return "內容"
        case .all:
            return "全部內容"
        }
    }
}

enum SearchSortBy: String, Codable {
    case relevancy
    case popularity
    case publishedAt
    
    var chineseName: String {
        switch self {
        case .relevancy:
            return "相關度"
        case .popularity:
            return "熱門排序"
        case .publishedAt:
            return "最新排序"
        }
    }
}

enum DisplayMode: String {
    case headline
    case search
}

enum SearchLanguage: String, CaseIterable, Codable {
    case BR // 巴西
    case CN // 中國
    case DE // 德國
    case FR // 法國
    case GB // 英國
    case IN // 印度
    case TW // 意大利
    case JP // 日本
    case MX // 墨西哥
    case US // 美國
    
    var chineseName: String {
        switch self {
        case .BR:
            return "巴西"
        case .CN:
            return "中國"
        case .DE:
            return "德國"
        case .FR:
            return "法國"
        case .GB:
            return "英國"
        case .IN:
            return "印度"
        case .TW:
            return "台灣"
        case .JP:
            return "日本"
        case .MX:
            return "墨西哥"
        case .US:
            return "美國"
        }
    }
}
