//
//  Instance.swift
//  MustTootOn
//
//  Created by Willy Breitenbach on 05.11.22.
//

import Foundation

// MARK: - InstanceElement
struct Instance: Codable, Identifiable {

    let id = UUID()

    let approvalRequired: Bool
//    let categories: [Category]?
//    let category: Category
    let instanceDescription, domain, language: String
    let languages: [String]
    let lastWeekUsers: Int
    let proxiedThumbnail: String
    let region: String
    let totalUsers: Int
    let version: String

    enum CodingKeys: String, CodingKey {
        case approvalRequired = "approval_required"
//        case categories, category
        case instanceDescription = "description"
        case domain, language, languages
        case lastWeekUsers = "last_week_users"
        case proxiedThumbnail = "proxied_thumbnail"
        case region
        case totalUsers = "total_users"
        case version
    }
}

enum Category: String, Codable {
    case activism = "activism"
    case art = "art"
    case food = "food"
    case furry = "furry"
    case games = "games"
    case general = "general"
    case lgbt = "lgbt"
    case music = "music"
    case regional = "regional"
    case tech = "tech"
    case hobby = "hobby"
}
