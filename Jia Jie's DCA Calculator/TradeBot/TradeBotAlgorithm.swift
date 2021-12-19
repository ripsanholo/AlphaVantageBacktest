//
//  TradeBotAlgorithm.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 19/12/21.
//

import Foundation
struct TradeBotAlgorithm {
    
    static func performCheck(condition: EvaluationCondition, previous: OHLCCloudElement, latest: OHLCCloudElement, bot: TradeBot) -> Bool {
        var inputValue: Double?
        var xxx: Double?
        
        switch condition.technicalIndicator {
        case .monthlyPeriodic:
    
            var inputValue: Date!
            var xxx: Date!
            
            inputValue = getInputValue(i: condition.technicalIndicator, element: latest)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
            
            return DateManager.checkIfNewMonth(previous: inputValue, next: xxx)
        case .movingAverage, .RSI:
            
            inputValue = getInputValue(i: condition.technicalIndicator, element: previous)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
            
        case .profitTarget:
            
            inputValue = bot.account.profit(quote: latest.close, budget: bot.budget)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
        
        default:
            
            inputValue = getInputValue(i: condition.technicalIndicator, element: latest)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
            
        }
        
        guard xxx != nil, inputValue != nil else { return false }
        
        print("Evaluating that the value of \(inputValue!) is \(condition.aboveOrBelow) the \(condition.technicalIndicator) of \(xxx!). I have evaluated this to be \(condition.aboveOrBelow.evaluate(inputValue!, xxx!)).")
        
        return condition.aboveOrBelow.evaluate(inputValue!, xxx!)
    }
    
    //MARK: SCENARIO 1: INDICATORS BASED ON OPEN. ELEMENT IS ALWAYS MOST RECENT. SECNARIO 2: INDICATORS BASED ON CLOSE. ELEMENT IS PREVIOUS FOR INDICATORS. ELEMENT IS MOST RECENT FOR PRICE INPUT (USING OPEN).
    
    //MARK: UPDATED THOUGHTS: You are currently comparing most recent open to previous close, and buying on most recent close. You have options:
    // 1 - Compare previous close to previous close. Buy on most recent open (lagging indicator, results only published at end of day based on API. Check again?)
    // 2 - Compare most recent close to most recent close. Buy on most recent close (only 90% realistic as MOC orders need leeway)
    // 3 - Compare previous close to previous close. Buy on most recent close (Simulate MOC order).
    // Conclusion: Depends on aim. Realism: Option 1, 3, and current. User satisfaction (result publishing): Option 2.
    // Current and option 3 is not much different. Current option feels inherently "More live". (Recency of input value) and hence current option is better.
    // Alternative: Compare most recent open to most recent open, buy on most recent close. (Change indicator parameter as 'open'). Again, slight advantage is recency. (Recency of indicator value from previous to most recent).
    static func getInputValue<T: Comparable>(i: TechnicalIndicators, element: OHLCCloudElement) -> T? {
        switch i {
        case .movingAverage:
            return element.movingAverage as! T?
        case .RSI:
            return element.RSI as! T?
        case .bollingerBands:
            return element.open as! T?
        case .monthlyPeriodic:
            return DateManager.date(from: element.stamp) as! T?
        case .stopOrder:
            //MARK: INPUT: LATEST OPEN
            return element.open as! T?
        case .profitTarget:
            return nil
        }
    }
    
    //MARK: INDICATOR VALUE IS ALWAYS PREVIOUS
    static func getIndicatorValue<T: Comparable>(i: TechnicalIndicators, element: OHLCCloudElement) -> T? {
        switch i {
        case .movingAverage:
            return element.movingAverage as! T?
        case let .RSI(period: _, value: value):
            return value * 100 as! T?
        case let .bollingerBands(percentage: b):
            return element.valueAtPercent(percent: b) as! T?
        case .monthlyPeriodic:
            return DateManager.date(from: element.stamp) as! T?
        case .stopOrder(let value):
            return value as! T?
        case .profitTarget(value: let value):
            return value as! T?
        }
    }
}