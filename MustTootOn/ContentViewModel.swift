//
//  ContentViewModel.swift
//  MustTootOn
//
//  Created by Willy Breitenbach on 05.11.22.
//

import Foundation
import AuthenticationServices
import EasyNetwork

@MainActor
class ViewModel: NSObject, ObservableObject {

    private let networkService = EasyNetwork()
    
    @Published
    var instances: [Instance] = []

    override init() {
        super.init()
        URLCache.shared.memoryCapacity = 50_000_000 // ~50 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
    }

    func fetchServers() async throws {
        let endPoint = MastodonServers()
        instances = try await networkService.send(endPoint)
    }

    func start(domain: String) {
        Task {
            guard let response = try? await sendRequest(domain) else {
                return
            }
            
            startAuth(domain: domain, appResponse: response)
        }
    }

    func sendRequest(_ domain: String) async throws -> AppsResponse {
        let sessionConfig = URLSessionConfiguration.default

        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        /* Create the Request:
         Request (POST https://mastodon.social/api/v1/apps)
         */

        guard let URL = URL(string: "https://\(domain)/api/v1/apps") else {
            throw NSError(domain: "musttooton", code: 7001)
        }

        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        // Headers

        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        // JSON Body

        let bodyObject: [String : Any] = [
            "redirect_uris": "musttooton://oauth",
            "client_name": "musttooton",
            "scopes": "read write follow push"
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])

        let (data, _) = try await session.data(for: request)
        let response = try  JSONDecoder().decode(AppsResponse.self, from: data)

        return response
    }

    func startAuth(domain: String, appResponse: AppsResponse) {

        let queryItems = [
            URLQueryItem(name: "client_id", value: appResponse.clientID),
            URLQueryItem(name: "client_secret", value: appResponse.clientSecret),
            URLQueryItem(name: "redirect_uri", value: appResponse.redirectURI),
            URLQueryItem(name: "scope", value: "read write follow push"),
            URLQueryItem(name: "response_type", value: "code")
        ]

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = domain
        urlComponents.path = "/oauth/authorize"
        urlComponents.queryItems = queryItems

        let authSession = ASWebAuthenticationSession(
            url: urlComponents.url!,
            callbackURLScheme: "musttooton",
            completionHandler: { url, error in

                guard let url,
                      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })
                else {
                    return
                }
                
                print("Code: \(code.value ?? "NA")")
            }
        )

        authSession.presentationContextProvider = self
        authSession.prefersEphemeralWebBrowserSession = true

        authSession.start()
    }
}

extension ViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {

        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first {
            $0.isKeyWindow
        }

        return window ?? ASPresentationAnchor()
    }
}

struct AppsResponse: Codable {
    let id, name, redirectURI: String
    let clientID, clientSecret, vapidKey: String
    let website: String?

    enum CodingKeys: String, CodingKey {
        case id, name, website
        case redirectURI = "redirect_uri"
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case vapidKey = "vapid_key"
    }
}
