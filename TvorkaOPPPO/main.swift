import Foundation

enum CalcError: Error {
    case runtimeError(message: String)
    case ok(result: [Double])
}

enum FuncType {
    case normal
    case noException
    case fullException
}

func isEqual(_ a: Double, _ b: Double, _ eps: Double = 0.00001) -> Bool {
    return abs(a - b) < eps
}

func sumArray(_ array: [Double]) -> Double {
    return array.reduce(0.0, +)
}

func solveCorrectEquation(a: Double, b: Double, c: Double) -> [Double] {
    if isEqual(a, 0.0), isEqual(b, 0.0) {
        return []
    }
    
    if isEqual(a, 0.0) {
        return [-c / b]
    }
    
    let disc = pow(b, 2) - (4 * a * c)
    
    if isEqual(disc, 0.0) {
        return [-b / (2 * a)]
    }
    
    if disc < 0.0 {
        return []
    }
    
    return [
        (-b + sqrt(disc)) / (2 * a),
        (-b - sqrt(disc)) / (2 * a)
    ]
}

func solveNoException(a: Double, b: Double, c: Double) -> [Double] {
    if isEqual(a, 0.0), isEqual(b, 0.0), isEqual(c, 0.0) {
        return []
    }
    
    return solveCorrectEquation(a: a, b: b, c: c)
}

func solve(a: Double, b: Double, c: Double) throws -> [Double] {
    if isEqual(a, 0.0), isEqual(b, 0.0), isEqual(c, 0.0) {
        throw(CalcError.runtimeError(message: "Invalid parametrs"))
    }
    
    return solveCorrectEquation(a: a, b: b, c: c)
}

func solveFullException(a: Double, b: Double, c: Double) throws {
    if isEqual(a, 0.0), isEqual(b, 0.0), isEqual(c, 0.0) {
        throw(CalcError.runtimeError(message: "Invalid parametrs"))
    }
    
    throw(CalcError.ok(result: solveCorrectEquation(a: a, b: b, c: c)))
}

func rootsSumNoException(a: Double, b: Double, c: Double) -> Double {
    return sumArray(solveNoException(a: a, b: b, c: c))
}

func rootsSum(a: Double, b: Double, c: Double) -> Double {
    do {
        let result = try solve(a: a, b: b, c: c)
        return sumArray(result)
    } catch {
        return 0.0
    }
}

func rootsSumFullException(a: Double, b: Double, c: Double) -> Double {
    do {
       try solveFullException(a: a, b: b, c: c)
    } catch CalcError.ok(let result) {
        return sumArray(result)
    } catch {
        return 0.0
    }
    
    return 0.0
}

func callSolver(funcType: FuncType, a: Double, b: Double, c: Double) -> Double {
    switch funcType {
    case .normal:
        return rootsSumNoException(a: a, b: b, c: c)
        
    case .noException:
        return rootsSumNoException(a: a, b: b, c: c)
        
    case .fullException:
        return rootsSumFullException(a: a, b: b, c: c)
    }
}

func run(n: UInt64, funcType: FuncType) {
    let begin = Date()
    
    var sum: Double = 0.0
    // последовательная
    for i in 0..<n {
        let a: Double = (Double(i).truncatingRemainder(dividingBy: 2000.0) - 1000.0) / 33.0
        let b: Double = (Double(i).truncatingRemainder(dividingBy: 200.0) - 100.0) / 22.0
        let c: Double = (Double(i).truncatingRemainder(dividingBy: 20.0) - 10.0) / 11.0
        sum += callSolver(funcType: funcType, a: a, b: b, c: c)
    }

    // параллельная
//    let lock = NSLock()
//    DispatchQueue.concurrentPerform(iterations: Int(n)) { i in
//        let a: Double = (Double(i).truncatingRemainder(dividingBy: 2000.0) - 1000.0) / 33.0
//        let b: Double = (Double(i).truncatingRemainder(dividingBy: 200.0) - 100.0) / 22.0
//        let c: Double = (Double(i).truncatingRemainder(dividingBy: 20.0) - 10.0) / 11.0
//        let localSum = callSolver(funcType: funcType, a: a, b: b, c: c)
//
//        lock.lock()
//        sum += localSum
//        lock.unlock()
//    }
    
    let end = Date()
    
    let elapsed = end.timeIntervalSince(begin) * 1000
    
    print(n, "\t", elapsed, "\t", sum)
}

let from = 4096
let to = from * 512

print("\t\t\t--------No exception-----------")
var i = from
repeat {
    run(n: UInt64(i), funcType: .noException)
    i *= 2
} while i <= to

print("\t\t\t--------Normal-----------")
i = from
repeat {
    run(n: UInt64(i), funcType: .normal)
    i *= 2
} while i <= to

print("\t\t\t--------Full exception-----------")
i = from
repeat {
    run(n: UInt64(i), funcType: .fullException)
    i *= 2
} while i <= to
