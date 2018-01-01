//
//  Service.swift
//  indexifyPackageDescription
//
//  Created by Aidar Nugmanov on 12/31/17.
//

import Foundation
import Moya

enum Service {
    case ticker
}

// MARK: - TargetType Protocol Implementation

extension Service: TargetType {
    var baseURL: URL {
        switch self {
        case .ticker:
            return URL(string: "https://api.coinmarketcap.com/v1")!
        }
    }
    var path: String {
        switch self {
        case .ticker:
            return "/ticker/"
        }
    }
    var method: Moya.Method {
        switch self {
        case .ticker:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .ticker:
            return .requestPlain
        }
    }
    var sampleData: Data {
        switch self {
        case .ticker:
            guard let url = Bundle.main.url(forResource: "sample", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
