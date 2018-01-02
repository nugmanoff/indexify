import Foundation
import Moya
import Alamofire

public final class Indexify {
    private let provider = MoyaProvider<Service>()
    private let runner = ScriptRunner()
    private let percentages = [(String, Int)]()
    private let totalCap = Double()

    public init() {
    }

    public func run(amount: Int, threshold: Int) throws {
//        runner.lock()
        test(amount, threshold)
        fetchGlobalData()
        fetchCapitalization()
        runner.wait()
    }

    private func test(_ amount: Int, _ threshold: Int) {
        print("Amount is \(amount)$ & threshold is \(threshold)%")
    }

    private func fetchCapitalization() {
        runner.lock()
        provider.request(.ticker) { (result) in
            switch result {
            case let .success(moyaResponse):
                do {
                    let dict = try moyaResponse.mapJSON(failsOnEmptyData: false) as! [[String: Any]]
                    print(dict.first?["symbol"] as! String)
                } catch {
                    print(error.localizedDescription)
                }
                self.runner.unlock()
            case let .failure(error):
                print("error ocurred \(error.errorDescription!)")
                self.runner.unlock()
            }
        }
    }

    private func fetchGlobalData() {
        runner.lock()
        provider.request(.global) { (result) in
            switch result {
            case let .success(moyaResponse):
                do {
                    let dict = try moyaResponse.mapJSON(failsOnEmptyData: false) as! [String: Any]
                    let totalCap = dict["total_market_cap_usd"] as! Double
                    print(totalCap)
                } catch {
                    print(error.localizedDescription)
                }
                self.runner.unlock()
            case let .failure(error):
                print("error ocurred \(error.errorDescription!)")
                self.runner.unlock()
            }
        }
    }
}
