//
//  Crypto.swift
//  indexifyPackageDescription
//
//  Created by Aidar Nugmanov on 1/18/18.
//

import Foundation

class Crypto: Decodable {
    var marketCap: String = ""
    var symbol: String = ""
    var percentage: Double = 0.0
    var investment: Double = 0.0

    private enum CodingKeys: String, CodingKey {
        case symbol, marketCap = "market_cap_usd"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        marketCap  = try values.decode(String.self, forKey: .marketCap)
        symbol     = try values.decode(String.self, forKey: .symbol)
    }
}
