//
//  CloudKit.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/12/21.
//

import Foundation
import UIKit
import Combine
import CloudKit
import SwiftUI

class CloudKitViewController: UIHostingController<AnyView> {

    var subscribers = Set<AnyCancellable>()
    var viewModel = CloudViewModel()
    
    var userName: String = ""
    var permission: Bool = false
    var isSignedInToiCloud: Bool = false
    var error: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        FetchLatest.update { [unowned self] tb in
//            Log.queue(action: "HALLELUJAH!!! \(tb)")
//            viewModel.tb = tb
//        }

        Log.queue(action: "Cloud view did load")

    }
    
    init() {
        super.init(rootView: AnyView(CloudView().environmentObject(viewModel)))
        getiCloudStatus()
        requestPermission()
        getCurrentUserName()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requestPermission() {
        CloudKitUtility.requestApplicationPermission()
            .receive(on: DispatchQueue.main)
            .sink { value in
                switch value {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                permission = value
            }.store(in: &subscribers)
    }

    private func getiCloudStatus() {
        CloudKitUtility.getiCloudStatus()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self.error = error.localizedDescription
                }
            } receiveValue: { [unowned self] value in
                isSignedInToiCloud = value
            }.store(in: &subscribers)
    }

    func getCurrentUserName() {
        CloudKitUtility.discoverUserIdentity()
            .receive(on: DispatchQueue.main)
            .sink { value in
                switch value {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                userName = value
            }.store(in: &subscribers)
    }
    
}
