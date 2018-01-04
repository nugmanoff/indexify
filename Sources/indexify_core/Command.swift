//
//  Command.swift
//  indexifyPackageDescription
//
//  Created by Aidar Nugmanov on 1/4/18.
//

import Foundation
import Commander

internal enum Command: String {
    case eval
    case auth
}

extension Command {
    
    static var all: [Command] {
        return [.eval, .auth]
    }

    var name: String {
        switch self {
        case .eval:
            return "eval"
        case .auth:
            return "auth"
        }
    }

    var description: String {
        switch self {
        case .eval:
            return "Evaluate deposit splitting using current Market Cap"
        case .auth:
            return "Authorize to gain access to trading functions using Poloniex"
        }
    }

    var task: Performable {
        switch self {
        case .eval:
            return Evaluator()
        case .auth:
            return Authorizer()
        }
    }

    var wrapper: CommandType {
        switch self {
        case .eval:
            return command(
                Option("amount", default: 100.0, description: "Amount of money (USD) to invest."),
                Option("threshold", default: 3.0, description: "Threshold percentage of Total Market Cap Index of currency.")
            ) { amount, threshold in
                print("amount is \(amount) & threshold is \(threshold)")
            }
        case .auth:
            return command {
                print("hello")
            }
        }
    }

//    var block: @autoclosure() throws -> () {
//        return task.peform()
//    }

}
