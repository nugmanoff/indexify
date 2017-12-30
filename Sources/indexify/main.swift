import indexify_core

let indexify = Indexify()

do {
    try indexify.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
