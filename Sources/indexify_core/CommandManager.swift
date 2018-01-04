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

    public init() {
        resolveCommands()
    }

    public convenience init(with version: String) {
        self.init()
        self.version = version
    }

    public func run() {
        group.run(version)
    }

    private func resolveCommands() {
        group.add(command: .auth)
        group.add(command: .eval)
    }

    private func resolveVersion() {
    }

}
