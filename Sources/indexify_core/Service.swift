//
//  Service.swift
//  indexifyPackageDescription
//
//  Created by Aidar Nugmanov on 12/31/17.
//

import Foundation
import Moya

enum Service {
    case ticker, global
}

// MARK: - TargetType Protocol Implementation

extension Service: TargetType {
    var baseURL: URL {
        switch self {
        case .ticker, .global:
            return URL(string: "https://api.coinmarketcap.com/v1")!
        }
    }
    var path: String { 
        switch self {
        case .ticker:
            return "/ticker/"
        case .global:
            return "/global/"
        }
    }
    var method: Moya.Method {
        switch self {
        case .ticker, .global:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .ticker, .global:
            return .requestPlain
        }
    }
    var sampleData: Data {
        switch self {
        case .ticker:
            guard let url = Bundle.main.url(forResource: "ticker", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        case .global:
            guard let url = Bundle.main.url(forResource: "global", withExtension: "json"),
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
