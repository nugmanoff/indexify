import indexify_core
import Foundation

let indexify = Indexify()

do {
    try indexify.run()
} catch {
    print("Whoops! An error occurred: \(error)")
    exit(1)
}
