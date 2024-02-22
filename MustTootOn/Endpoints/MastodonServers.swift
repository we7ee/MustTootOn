//
//  MastodonServers.swift
//  MustTootOn
//
//  Created by Willy Breitenbach on 06.11.22.
//

import Foundation
import EasyNetwork

struct MastodonServers: EndPointType {
    typealias Response = [Instance]

    var baseURL: URL {
        guard let url = URL(string: "https://api.joinmastodon.org") else {
            fatalError("Could not parse url")
        }

        return url
    }

    var path: String {
        "/servers"
    }

    var httpMethod: HTTPMethod {
        .get
    }

    var task: HTTPTask {
        .request
    }

    var httpBody: HTTPBody?

    var headers: HTTPHeaders?

    var urlQuery: Parameters?
}
