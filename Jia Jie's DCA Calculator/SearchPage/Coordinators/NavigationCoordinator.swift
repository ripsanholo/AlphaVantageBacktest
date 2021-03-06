//
//  MainCoordinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 25/9/21.
//

import Foundation
import UIKit
import Combine

class NavigationCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
    var childCoordinators: [Coordinator] = [] { didSet {
        print(childCoordinators)
    }}
    
    var rawDataDaily: Daily?
    
    var subscribers = Set<AnyCancellable>()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func pushSearchViewController() {
        navigationController.delegate = self
        let vc = SearchViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func start(name: String, symbol: String, type: String) {
       let child = PageCoordinator(navigationController: navigationController)
       child.parentCoordinator = self
       child.name = name
       child.symbol = symbol
       child.type = type
       child.rawDataDaily = rawDataDaily
       child.start(name: name, symbol: symbol, type: type)
    }
    
    func childDidExit(_ child: Coordinator?) {
        let initialCount = childCoordinators.count
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                Log.queue(action: "Child successfully exited")
                break
            } else {
                continue
            }
        }
        
        let oneItemRemoved = initialCount - 1 == childCoordinators.count
        guard oneItemRemoved else { fatalError() }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        
        //MARK: CHECK IF PUSHED
        if navigationController.viewControllers.contains(fromViewController) { return }
        
        //MARK: VIEWCONTROLLER WAS POPPED
        if let vc = fromViewController as? CandleViewController {
            childDidExit(vc.coordinator)
        } else {
            fatalError() //MARK: Fatal Error
        }
    }
    
}
