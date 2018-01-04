//
//  Performable.swift
//  indexifyPackageDescription
//
//  Created by Aidar Nugmanov on 1/4/18.
//

import Commander

internal protocol Performable {
    func perform(_ arguments: ArgumentConvertible...)
}
