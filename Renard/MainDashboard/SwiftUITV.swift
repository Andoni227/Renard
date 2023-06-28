//
//  SwiftUITV.swift
//  Renard
//
//  Created by Andoni Suarez on 23/06/23.
//

import Foundation
import SwiftUI
import Charts

struct SwiftUITV: View {
    
    var labels = [
        StatisticObj.init(name: "Foto de mayor resolución", value: assetsLibrary.shared.maxResPhoto ?? "-"),
        StatisticObj.init(name: "Foto de menor resolución", value: assetsLibrary.shared.lowResPhoto ?? "-"),
        StatisticObj.init(name: "Formato más común", value: assetsLibrary.shared.mostCommonFormat?.getName ?? "-"),
        StatisticObj.init(name: "Formato menos común", value: assetsLibrary.shared.lessCommonFormat?.getName ?? "-")
    ]
    
    var body: some View {
        NavigationView{
            List{
                ForEach(labels, id: \.name) { statistic in
                              HStack {
                                  Text(statistic.name)
                                  Spacer()
                                  Text(statistic.value)
                              }
                          }
            }
            .font(Font(UIFont.montserratBold(ofSize: 13.0)))
            .navigationTitle("Estadísiticas")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUITV()
    }
}

struct StatisticObj{
    var name: String
    var value: String
}
