//
//  Command.swift
//  indexifyPackageDescription
//
//  Created by Aidar Nugmanov on 1/4/18.
//

import Foundation
import Commander

public final class CommandManager {
    
    private var version = "0.0.1"
    private var group = Group()
    private final let amount = 100.0
    private final let threshold = 3.0
    private let runner = ScriptRunner()
    
    init() {
        resolveCommands()
    }

    convenience init(with version: String) {
        self.version = version
        self.init()
    }
    
    public func run() {
        group.run(version)
    }
    
    private func resolveCommands() {

        let eval = Evaluator()
        
        let calc = command(
            Option("amount", default: amount, description: "Amount of money (USD) to invest."),
            Option("threshold", default: threshold, description: "Threshold percentage of Total Market Cap Index of currency.")
        ) { amount, threshold in
            do {
//                try indexify.run(amount: amount, threshold: threshold)
            } catch {
                print("Whoops! An error occurred: \(error)")
            }
        }
        
        let auth = command {
            print("authorized")
        }

        group.addCommand("calc", "used to calculate deposit splitting", calc)
        group.addCommand("auth", "used to authorize user to Poloniex API", auth)
    }
    
}
