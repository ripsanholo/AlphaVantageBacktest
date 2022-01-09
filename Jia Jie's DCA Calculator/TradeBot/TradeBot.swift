//
//  TradeBot.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/12/21.
//
import Foundation
import CloudKit
import Foundation

struct TradeBot: CloudKitInterchangeable {
    let long: Bool 
    var account: Account
    var conditions: [EvaluationCondition] = []
    let record: CKRecord
    var exitTrigger: Int?
    var lm = LedgerManager()
    
    init?(record: CKRecord) {
        let budget = record["budget"] as! Double
        let cash = record["cash"] as! Double
        let accumulatedShares = record["accumulatedShares"] as! Double
        let exitTrigger = record["exitTrigger"] as! Int?
        let long = record["long"] as! Bool
        
        self.account = .init(budget: budget, cash: cash, accumulatedShares: accumulatedShares)
        self.record = record
        self.exitTrigger = exitTrigger
        self.long = long
    }
    
    func update() -> Self {
        let record = self.record

        return TradeBot(record: record)!
    }
    
    init?(account: Account, conditions: [EvaluationCondition], exitTrigger: Int? = nil, long: Bool = true) {
        let record = CKRecord(recordType: "TradeBot")
                record.setValuesForKeys([
                    "budget": account.budget,
                    "cash": account.budget,
                    "accumulatedShares": 0,
                    "long" : long
                ])
            if let exitTrigger = exitTrigger {
              record.setValue(exitTrigger, forKey: "exitTrigger")
             }
        self.init(record: record)
        self.conditions = conditions
        
        //MARK: EFFECTIVE AFTER IS LATEST OHLC DATE.
    }

    mutating func evaluate(previous: OHLCCloudElement, latest: OHLCCloudElement, didEvaluate: @escaping (Bool) -> Void) {
        let close = latest.close
       
        //MARK: CONDITION SATISFIED, INVEST 10% OF CASH
        for condition in self.conditions {
                switch condition.enterOrExit {
                case .enter:
                    guard account.cash > 0 else { continue }
                    if TradeBotAlgorithm.checkNext(condition: condition, previous: previous, latest: latest, bot: self) {
                     
                        account.accumulatedShares += account.decrement(long ? account.cash : account.budget) / close
                        
                    switch exitTrigger {
                        case .some(exitTrigger) where exitTrigger! >= 0:
                        self.conditions = ExitTriggerManager.orUpload(latest: latest.stamp, exitAfter: exitTrigger!, tb: self)
                        case .some(exitTrigger) where exitTrigger! < 0:
                        self.conditions = ExitTriggerManager.andUpload(latest: latest.stamp, exitAfter: abs(exitTrigger!), tb: self)
                        default:
                          break
                    }
                    
                    break
                    }
                case .exit:
                    guard account.accumulatedShares > 0 else { continue }
                    if TradeBotAlgorithm.checkNext(condition: condition, previous: previous, latest: latest, bot: self) {
                    account.cash += account.decrement(shares: account.accumulatedShares) * close
                        
                        switch exitTrigger {
                        case .some(exitTrigger) where exitTrigger! >= 0:
                            self.conditions = ExitTriggerManager.resetOrExitTrigger(tb: self)
                        case .some(exitTrigger) where exitTrigger! < 0:
                        self.conditions = ExitTriggerManager.resetAndExitTrigger(tb: self)
                        default:
                            break
                        }
                        
                    break
                    }
                }
            }
    }
}

extension TradeBot {
    
}

struct Account {
    let budget: Double
    var cash: Double
    var accumulatedShares: Double
    
    func longProfit(quote: Double) -> Double {
        let value = (accumulatedShares * quote + cash) - budget
        return value / budget
    }
    
    func shortProfit(quote: Double) -> Double {
        let value = (budget - cash) - (accumulatedShares * quote)
        return value / budget
    }

    mutating func decrement(_ amount: Double) -> Double {
        cash -= amount
        return amount
    }
    
    mutating func decrement(shares: Double) -> Double {
        accumulatedShares -= shares
        return shares
    }
    
    func netWorth(quote: Double) -> Double {
        return accumulatedShares * quote + cash
    }
}

enum AboveOrBelow: Int, CustomStringConvertible {
    case priceAbove, priceBelow

    var description: String {
    switch self {
    case .priceAbove:
        return "above"
    case .priceBelow:
        return "below"
    }
    }
    
    var opposingDescription: String {
        switch self {
        case .priceAbove:
            return "below"
        case .priceBelow:
            return "above"
        }
    }

    func evaluate(_ price: Double, _ technicalIndicator: Double) -> Bool {
        switch self {
        case .priceAbove:
            return price > technicalIndicator
        case .priceBelow:
            return price < technicalIndicator
        }
    }
}

enum EnterOrExit: Int, CustomStringConvertible {
    var description: String {
        switch self {
        case .enter:
            return "enter"
        case .exit:
            return "exit"
        }
    }
    
    var opposingDescription: String {
        switch self {
        case .enter:
            return "exit"
        case .exit:
            return "enter"
        }
    }
    case enter, exit
}

