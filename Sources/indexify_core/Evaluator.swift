import Foundation
import Moya
import Alamofire
import Commander

public final class Evaluator: Performable {
    
    private let provider = MoyaProvider<Service>()
    private var percentages: [(String, Double)] = []
    private var investments: [String: Double] = [:]
    private var totalCap = Double()
    private var runner = ScriptRunner()

    public init(with runner: ScriptRunner) {
        self.runner = runner
    }
    
    public func perform(_ arguments: ArgumentConvertible...) {
        let amount = arguments[0] as! Double
        let threshold = arguments[1] as! Double
        perform(amount: amount, threshold: threshold)
    }

    private func perform(amount: Double, threshold: Double) {
//        let s = String(String: getpass("Enter your API Key:"), encoding: .utf8)
//        let b = String(String: getpass("Enter your Secret:"), encoding: .utf8)
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
            self.runner.unlock()
        }
        runner.wait()
    }

    // MARK: - Private

    private func splitDeposit(amount: Double) {
        var tempSum = 0.0
        if amount < 0.001 {
            investments[percentages.first!.0]! += amount
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
    
    // MARK: - Network Requests

    private func getCapitalization(for threshold: Double, completionHandler: @escaping() -> Void) {
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
                completionHandler()
            case let .failure(error):
                print("error ocurred \(error.errorDescription!)")
                completionHandler()
            }
        }
    }

    private func getGlobalData(completionHandler: @escaping() -> Void) {
        provider.request(.global) { (result) in
            switch result {
            case let .success(moyaResponse):
                do {
                    let dict = try moyaResponse.mapJSON(failsOnEmptyData: false) as! [String: Any]
                    self.totalCap = dict["total_market_cap_usd"] as! Double
                } catch {
                    print(error.localizedDescription)
                }
                completionHandler()
            case let .failure(error):
                print("error ocurred \(error.errorDescription!)")
                completionHandler()
            }
        }
    }
}
