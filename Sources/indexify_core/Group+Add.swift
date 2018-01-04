//
//  CommandType+createCommand.swift
//  indexifyPackageDescription
//
//  Created by Aidar Nugmanov on 1/4/18.
//

import Commander

extension Group {
    func add(command: Command) {
        addCommand(command.name, command.description, command.wrapper)
    }
}
