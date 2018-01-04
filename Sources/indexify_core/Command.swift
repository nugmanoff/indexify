//
//  Command.swift
//  indexifyPackageDescription
//
//  Created by Aidar Nugmanov on 1/4/18.
//

import Foundation

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
    
    var block: @autoclosure() throws -> () {
        return task.peform()
    }

//    init(arguments: [String], index: Int = 1) throws {
//        guard let commandString = arguments.element(at: index) else {
//            self = .help
//            return
//        }
//
//        guard let command = Command(rawValue: commandString) else {
//            throw Error.invalid(commandString)
//        }
//
//        self = command
//    }
}
