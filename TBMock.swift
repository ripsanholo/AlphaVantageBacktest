import Foundation
struct Mock {
    
    static func account() -> Account {
        return Account(budget: 5000, cash: 5000, accumulatedShares: 0)
    }
    
    static func tb() -> TradeBot {
        return TradeBot(account: account(), conditions: [])!
    }
    
    static func MA() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, enterOrExit: .enter, andCondition: [])!
    }
    
    static func MAOperation() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .movingAverageOperation(period1: 200, period2: 50), aboveOrBelow: .priceAbove, enterOrExit: .enter, andCondition: [])!
    }
    
    static func BB() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .bollingerBands(percentage: 0.69), aboveOrBelow: .priceBelow, enterOrExit: .enter, andCondition: [])!
    }
    
    static func RSI() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .RSI(period: 14, value: 0.69), aboveOrBelow: .priceBelow, enterOrExit: .enter, andCondition: [])!
    }
    
    static func ticker() -> OHLCCloudElement {
        return OHLCCloudElement(stamp: "", open: 1.1, high: 0, low: 0, close: 0, volume: 0, percentageChange: nil, RSI: [14: 0.70], movingAverage: [
            200 : 1 ,
            50 : 0.9
        ], standardDeviation: nil, upperBollingerBand: 100, lowerBollingerBand: 0)
    }
    
    static func context() -> ContextObject {
        let o = ContextObject(account: account(), tb: tb())
            .updateTickers(previous: ticker(), mostRecent: ticker())
        return o
    }
    
}

struct AlgoMock {
    static func timeSeries() -> Daily {
        return Daily(meta: nil, timeSeries: mockTimeSeries, note: nil, sorted: nil)
    }
    
    static var mockTimeSeries: [String: TimeSeriesDaily] = [
        "2022-01-01" : .init(open: "25", high: "30", low: "20", close: "22", volume: "44"),
        "2022-01-02" : .init(open: "25", high: "30", low: "20", close: "22", volume: "44")
    ]
    
    static func tb() -> TradeBot {
        return TradeBot(account: account(), conditions: [inactiveHP()], holdingPeriod: 10)!
    }
    
    static func account() -> Account {
        return Account(budget: 5000, cash: 5000, accumulatedShares: 0)
    }
    
    static func ticker() -> OHLCCloudElement {
        return OHLCCloudElement(stamp: "2022-01-01", open: 0, high: 0, low: 0, close: 0, volume: 0, percentageChange: nil, RSI: [:], movingAverage: [:], standardDeviation: nil, upperBollingerBand: nil, lowerBollingerBand: nil)
    }
    
    static func context() -> ContextObject {
        return ContextObject(account: account(), tb: tb())
            .updateTickers(previous: ticker(), mostRecent: ticker())
    }
    
    static func inactiveHP() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .holdingPeriod(value: 99999999), aboveOrBelow: .priceAbove, enterOrExit: .enter, andCondition: [])!
    }
    
    static func activeHP() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .holdingPeriod(value: 20220111), aboveOrBelow: .priceAbove, enterOrExit: .enter, andCondition: [])!
    }
    
}
