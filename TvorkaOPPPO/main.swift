import Foundation

enum Exception: Error {
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

func solveNoException(a: Double, b: Double, c: Double) -> [Double]? {
    if isEqual(a, 0.0), isEqual(b, 0.0), isEqual(c, 0.0) {
        return nil
    }
    
    return solveCorrectEquation(a: a, b: b, c: c)
}

func solve(a: Double, b: Double, c: Double) throws -> [Double] {
    if isEqual(a, 0.0), isEqual(b, 0.0), isEqual(c, 0.0) {
        throw(Exception.runtimeError(message: "Invalid parametrs"))
    }
    
    return solveCorrectEquation(a: a, b: b, c: c)
}

func solveFullException(a: Double, b: Double, c: Double) throws {
    if isEqual(a, 0.0), isEqual(b, 0.0), isEqual(c, 0.0) {
        throw(Exception.runtimeError(message: "Invalid parametrs"))
    }
    
    throw(Exception.ok(result: solveCorrectEquation(a: a, b: b, c: c)))
}

func rootsSumNoException(a: Double, b: Double, c: Double) -> Double {
    if let solve = solveNoException(a: a, b: b, c: c) {
        return sumArray(solve)
    }
    
    return 0
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
    } catch Exception.ok(let result) {
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
//    for i in 0..<n {
//        let a: Double = (Double(i).truncatingRemainder(dividingBy: 2000.0) - 1000.0) / 33.0
//        let b: Double = (Double(i).truncatingRemainder(dividingBy: 200.0) - 100.0) / 22.0
//        let c: Double = (Double(i).truncatingRemainder(dividingBy: 20.0) - 10.0) / 11.0
//        sum += callSolver(funcType: funcType, a: a, b: b, c: c)
//    }

    // параллельная
    let lock = NSLock()
    DispatchQueue.concurrentPerform(iterations: Int(n)) { i in
        let a: Double = (Double(i).truncatingRemainder(dividingBy: 2000.0) - 1000.0) / 33.0
        let b: Double = (Double(i).truncatingRemainder(dividingBy: 200.0) - 100.0) / 22.0
        let c: Double = (Double(i).truncatingRemainder(dividingBy: 20.0) - 10.0) / 11.0
        let localSum = callSolver(funcType: funcType, a: a, b: b, c: c)

        DispatchQueue.global().sync {
            lock.lock()
            sum += localSum
            lock.unlock()
        }
    }
    
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

/*
Последовательная
   --------No exception-----------
4096   6.83903694152832   2420.266837376501
8192   12.38393783569336   4847.97216801181
16384   25.927066802978516   9696.61526524532
32768   49.73900318145752   19394.491021253325
65536   98.90103340148926   39996.97667195608
131072   212.74197101593018   80000.10919719133
262144   396.9320058822632   158764.74170307766
524288   796.6489791870117   317531.8489237112
1048576   1639.6369934082031   635072.6618684477
2097152   3279.440999031067   1271356.425433359
   --------Normal-----------
4096   6.5490007400512695   2420.266837376501
8192   12.923002243041992   4847.97216801181
16384   27.32992172241211   9696.61526524532
32768   50.69899559020996   19394.491021253325
65536   103.48701477050781   39996.97667195608
131072   207.85796642303467   80000.10919719133
262144   418.71798038482666   158764.74170307766
524288   827.9640674591064   317531.8489237112
1048576   1668.3320999145508   635072.6618684477
2097152   3360.741972923279   1271356.425433359
   --------Full exception-----------
4096   7.730007171630859   2420.266837376501
8192   15.36703109741211   4847.97216801181
16384   31.222105026245117   9696.61526524532
32768   68.27497482299805   19394.491021253325
65536   169.75009441375732   39996.97667195608
131072   271.02601528167725   80000.10919719133
262144   555.3840398788452   158764.74170307766
524288   1012.6880407333374   317531.8489237112
1048576   2126.6510486602783   635072.6618684477
2097152   4429.7239780426025   1271356.425433359

Параллельно
   --------No exception-----------
4096   6.995081901550293   2420.2668373765014
8192   8.486032485961914   4847.97216801181
16384   16.294002532958984   9696.61526524532
32768   27.966022491455078   19394.491021253325
65536   54.52597141265869   39996.97667195609
131072   112.2809648513794   80000.10919719134
262144   222.80490398406982   158764.74170307769
524288   438.4770393371582   317531.8489237112
1048576   891.3220167160034   635072.6618684478
2097152   1805.1400184631348   1271356.4254333596
   --------Normal-----------
4096   3.297090530395508   2420.2668373765005
8192   7.60197639465332   4847.972168011811
16384   15.519976615905762   9696.615265245322
32768   30.571937561035156   19394.49102125333
65536   53.57098579406738   39996.976671956094
131072   111.96506023406982   80000.10919719134
262144   229.248046875   158764.74170307766
524288   457.3349952697754   317531.84892371116
1048576   889.7029161453247   635072.6618684479
2097152   1811.340093612671   1271356.425433359
   --------Full exception-----------
4096   3.715038299560547   2420.2668373765014
8192   7.094979286193848   4847.972168011811
16384   14.373064041137695   9696.615265245318
32768   27.514934539794922   19394.49102125333
65536   54.12602424621582   39996.97667195609
131072   106.1619520187378   80000.10919719131
262144   199.33807849884033   158764.74170307769
524288   424.0880012512207   317531.84892371116
1048576   851.4299392700195   635072.6618684477
2097152   1671.0230112075806   1271356.4254333593
*/
