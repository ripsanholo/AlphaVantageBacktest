//
//  CandleIndicatorView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/11/21.
//

import Foundation
import SwiftUI

struct CandleIndicatorView: View {
    
    @EnvironmentObject var viewModel: CandleViewModel
    @State var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
//        Rectangle()
//            .position(x: -viewModel.width / 2, y: viewModel.height / 2)
//            .frame(width: 10, height: viewModel.height, alignment: .leading)
//            .opacity(0)
//            .offset(x: offset)
        }
        .frame(width: viewModel.width, height: viewModel.height)
        .contentShape(Rectangle())
//        .position(x: 0)
        .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ gesture in
                        let x = gesture.location.x
                        let data = viewModel.RC!.data
                        let lowerBound: CGFloat = 0
                        let upperBound = viewModel.width * CGFloat(data.count) / CGFloat(data.count + 1)
                        guard x >= lowerBound && x <= upperBound else { return }
//                        print(x)
                        offset = x
                        viewModel.selectedIndex = viewModel.indicator!.updateIndicator(xPos: x)
                    }))
        .frame(width: viewModel.width, height: viewModel.height)
      
        
    }
}
