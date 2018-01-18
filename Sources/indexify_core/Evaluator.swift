import Foundation
import Moya
import Alamofire
import Commander

// MARK: - Error

public enum EvaluatorError {
    case failedToDecodeServerResponse
    case networkError
}

extension EvaluatorError: PrintableError {
    public var message: String {
        switch self {
        case .failedToDecodeServerResponse:
            return "Decoding error occurred"
        case .networkError:
            return "Network error occurred"
        }
    }
}

// MARK: - Evaluator

public final class Evaluator: Performable {
    
    private let provider = MoyaProvider<Service>()
    private var cryptos: [Crypto] = []
    private var totalCap = Double()
    private var runner = ScriptRunner()
    
    // MARK: - Init

    public init(with runner: ScriptRunner) {
        self.runner = runner
    }
    
    public func perform(_ arguments: ArgumentConvertible...) {
        let amount = arguments[0] as! Double
        let threshold = arguments[1] as! Double
        perform(amount: amount, threshold: threshold)
    }

    private func perform(amount: Double, threshold: Double) {
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
            cryptos[0].investment += amount
            prettyPrint()
            return
        }
        for crypto in cryptos {
            crypto.investment += amount * crypto.percentage
            tempSum += amount * crypto.percentage
        }
        splitDeposit(amount: amount - tempSum)
    }
    
    private func prettyPrint() {
        for crypto in cryptos {
            print("\(crypto.symbol), investment: \(crypto.investment), ")
        }
        print()
        runner.unlock()
    }
    
    // MARK: - Network Requests

    private func getCapitalization(for threshold: Double, completionHandler: @escaping() -> Void) {
        provider.request(.ticker) { (result) in
            switch result {
            case let .success(moyaResponse):
                if let cryptos = try? JSONDecoder().decode([Crypto].self, from: moyaResponse.data) {
                    for crypto in cryptos {
                        let percentage = Double(crypto.marketCap)! / self.totalCap
                        guard percentage > threshold * 0.01 else {
                            break
                        }
                        crypto.percentage = percentage
                        self.cryptos.append(crypto)
                    }
                }
                self.cryptos.sort(by: { $0.percentage > $1.percentage})
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
                    print(EvaluatorError.failedToDecodeServerResponse)
                }
                completionHandler()
            case .failure:
                print(EvaluatorError.networkError)
                completionHandler()
            }
        }
    }
}
