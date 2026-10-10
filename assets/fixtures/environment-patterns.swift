enum Problem: Error { case missing, invalid, overflow }
protocol Transform { func apply(_ value: Int) throws -> Int }
struct Add: Transform {
    let amount: Int
    func apply(_ value: Int) throws -> Int {
        if value > 255 - amount { throw Problem.overflow }
        return value + amount
    }
}
func invoke<T: Transform>(_ operation: T, _ value: Int) throws -> Int {
    return try operation.apply(value)
}
func evaluate(_ args: [String]) throws -> Int {
    guard let text = args.first else { throw Problem.missing }
    guard !text.isEmpty, text.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
          let value = Int(text), value <= 255 else { throw Problem.invalid }
    let operation: any Transform = Add(amount: 7)
    return try invoke(operation, value)
}
do { print("ok:\(try evaluate(Array(CommandLine.arguments.dropFirst())))") }
catch Problem.missing { print("err:missing") }
catch Problem.overflow { print("err:overflow") }
catch { print("err:invalid") }
