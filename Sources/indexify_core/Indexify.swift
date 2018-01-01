import Foundation
import Moya
import Alamofire

public final class Indexify {
    private let provider = MoyaProvider<Service>()
    private let arguments: [String]
    private let runner = ScriptRunner()

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        runner.lock()
        fetch()
        runner.wait()
    }

    private func fetch() {
        provider.request(.ticker) { (result) in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                let dict = data as! [String: Any]
                print(moyaResponse.description)
                self.runner.unlock()
            case let .failure(error):
                print("error ocurred \(error.errorDescription!)")
                self.runner.unlock()
            }
        }
    }
}
