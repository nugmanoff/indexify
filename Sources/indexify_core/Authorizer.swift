//
//  Authorizer.swift
//  indexifyPackageDescription
//
//  Created by Aidar Nugmanov on 1/4/18.
//

import Foundation
import Commander

public final class Authorizer: Performable {
    
    private var runner = ScriptRunner()
    
    public init(with runner: ScriptRunner) {
        self.runner = runner
    }
    
    func perform(_ arguments: ArgumentConvertible...) {
        print(arguments)
    }
    
}
