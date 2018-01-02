import Foundation
import Moya
import Alamofire

public final class Indexify {
    private let provider = MoyaProvider<Service>()
    private let runner = ScriptRunner()
    private var percentages = [(String, Double)]()
    private var investments = [String: Double]()
    private var totalCap = Double()
    
    public init() {
    }

    public func run(amount: Int, threshold: Double) throws {
        getGlobalData()
        getCapitalization(for: threshold)
        runner.wait()
    }
    
    // MARK: - Utility functions
    
    private func splitDeposit(amount: Double) {
        if (amount < 0.001) {
            let key = percentages.first!.0
            let percent = percentages.first!.1
            investments[key]! += amount * percent
            runner.unlock()
            print(investments)
            return
        }
        percentages.forEach {
           print(investments[$0.0]!)
           investments[$0.0]! += amount * $0.1
        }
        
        splitDeposit(amount: amount - investments.flatMap({ $0.value }).reduce(0, +))
    }
    
    // MARK: - API Requests

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
                        self.investments[symbol] = 0.0
                    }
                } catch {
                    print(error.localizedDescription)
                }
                self.percentages.sort(by: { $0.1 > $1.1})
                print(self.percentages)
                print()
                print(self.investments)
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
