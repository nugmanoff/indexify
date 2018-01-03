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

    public func run(amount: Double, threshold: Double) throws {
        runner.lock()
        let queue = DispatchQueue(label: "queue")
        let sema = DispatchSemaphore(value: 1)
        
        queue.async {
            sema.wait()
            self.getGlobalData {
                sema.signal()
            }
        }
        
        queue.async {
            sema.wait()
            self.getCapitalization(for: threshold) {
                sema.signal()
            }
        }
        
        queue.async {
            sema.wait()
            self.splitDeposit(amount: amount)
        }
        
        runner.wait()
    }

    // MARK: - Utility functions
    
    private func splitDeposit(amount: Double) {
        var tempSum = 0.0
        if (amount < 0.001) {
//            investments[percentages.first!.0]! += amount
            runner.unlock()
            print(investments)
            return
        }
        percentages.forEach {
           investments[$0.0]! += amount * $0.1
           tempSum += amount * $0.1
        }
        splitDeposit(amount: amount - tempSum)
    }

    // MARK: - API Requests

    private func getCapitalization(for threshold: Double, completionHandler: @escaping() -> ()) {
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
                completionHandler()
//                self.runner.unlock()
            case let .failure(error):
                print("error ocurred \(error.errorDescription!)")
                completionHandler()
//                self.runner.unlock()
            }
        }
    }

    private func getGlobalData(completionHandler: @escaping() -> ()) {
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
                completionHandler()
//                self.runner.unlock()
            case let .failure(error):
                print("error ocurred \(error.errorDescription!)")
                completionHandler()
//                self.runner.unlock()
            }
        }
    }
}
