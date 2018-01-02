import indexify_core
import Commander

let indexify = Indexify()

command(
    Option("amount", default: 100, description: "Amount of money (USD) to invest."),
    Option("threshold", default: 3, description: "Threshold percentage of Total Market Cap Index of currency.")
) { amount, threshold in
    do {
        try indexify.run(amount: amount, threshold: threshold)
    } catch {
        print("Whoops! An error occurred: \(error)")
    }
}.run()
