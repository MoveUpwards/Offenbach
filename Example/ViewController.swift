//
//  ViewController.swift
//  Example
//
//  Created by Move Upwards on 12 juin 2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Alamofire
import UIKit
import Offenbach

// MARK: - ViewController

struct Films: Decodable {
    let count: Int
    let all: [Film]

    enum CodingKeys: String, CodingKey {
        case count
        case all = "results"
    }
}

struct Film: Decodable {
    let id: Int
    let title: String
    let openingCrawl: String
    let director: String
    let producer: String
    let releaseDate: String
    let starships: [String]

    enum CodingKeys: String, CodingKey {
        case id = "episode_id"
        case title
        case openingCrawl = "opening_crawl"
        case director
        case producer
        case releaseDate = "release_date"
        case starships
    }
}

struct Token: TokenProtocol {
    var token: String? = "valid-jwt"
    var refresh: String? = "valid-jwt-refresh-token"
}

class ApiClient: Client {
    public static let `default` = ApiClient()

    private override init() { }
}

class ApiConfig: Config {
    override var baseURL: String {
        "https://swapi.dev/api"
    }

    required init(env: ApiEnvironment, decoder: DataDecoder = JSONDecoder()) {
        super.init(env: env, decoder: decoder)
    }
}

/// The ViewController
class ViewController: UIViewController {

    // MARK: Properties

    /// The Label
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "🚀\nOffenbach\nExample"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    // MARK: View-Lifecycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    /// LoadView
    override func loadView() {
        self.view = self.label
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        ApiClient.default
            .set(config: ApiConfig(env: .production))
            .set(jwt: Token())
            .get(action: "films/") { (result: Result<Films, AFError>) in
                switch result {
                    case .success(let films): print(films.all)
                    case .failure(let error): print(error)
                }
            }
    }
}
