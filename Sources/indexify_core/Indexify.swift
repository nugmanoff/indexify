import Foundation
import Moya
import Alamofire

public final class Indexify {
    private let provider = MoyaProvider<Service>()
    private let runner = ScriptRunner()
    private var percentages = [(String, Double)]()
    private var totalCap = Double()

    public init() {
    }

    public func run(amount: Int, threshold: Double) throws {
        getGlobalData()
        getCapitalization(for: threshold)
        runner.wait()
    }

    private func getCapitalization(for threshold: Double) {
        runner.lock()
        provider.request(.ticker) { (result) in
            switch result {
            case let .success(moyaResponse):
                do {
                    let response = try moyaResponse.mapJSON(failsOnEmptyData: false) as! [[String: Any]]
                    for entry in response {
                        let percentage = (Double)(entry["market_cap_usd"] as! String)! / self.totalCap
                        let symbol = entry["symbol"] as! String
                        if percentage < threshold/100 {
                            break
                        }
                        self.percentages.append((symbol, percentage))
                    }
                } catch {
                    print(error.localizedDescription)
                }
                print(self.percentages)
                self.runner.unlock()
            case let .failure(error):
                print("error ocurred \(error.errorDescription!)")
                self.runner.unlock()
            }
        }
    }

    private func getGlobalData() {
        runner.lock()
        provider.request(.global) { (result) in
            switch result {
            case let .success(moyaResponse):
                do {
                    let dict = try moyaResponse.mapJSON(failsOnEmptyData: false) as! [String: Any]
                    self.totalCap = dict["total_market_cap_usd"] as! Double
                    print(self.totalCap)
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
