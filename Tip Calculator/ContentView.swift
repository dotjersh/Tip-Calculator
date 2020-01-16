//
//  ContentView.swift
//  Tip Calculator
//
//  Created by John Slomka on 2020-01-09.
//  Copyright © 2020 John Slomka. All rights reserved.
//

import SwiftUI

enum NumButtons: String {
    case zero, one, two, three, four, five, six, seven, eight, nine
    case clear
    
    // Button Colour
    var backgroundColor: Color {
        switch self {
            case .clear:
                return Color("ClearButton")
            default:
                return Color("ButtonColor")
        }
    }
    var title: String {
        switch self {
            case .zero: return "0"
            case .one: return "1"
            case .two: return "2"
            case .three: return "3"
            case .four: return "4"
            case .five: return "5"
            case .six: return "6"
            case .seven: return "7"
            case .eight: return "8"
            case .nine: return "9"
            default: return "AC"
        }
    }
}


enum Coins: String {
    case one, two, three
    var image: String {
        switch self {
        case .one: return "OneCoin"
            case .two: return "TwoCoins"
        default: return "ThreeCoins"
        }
    }
}


// Env Obect
// Treated as the Global Application State
class GlobalEnvironment: ObservableObject {
    
    var bill = ""
    var defaultScreen = "$0"
    @Published var display = "$0"
    @Published var tipValues: [String] = ["%10","%20","%30"]
    
    func receiveButton(button: NumButtons) {
        if button == .clear {
            bill = ""
            tipValues = ["%10","%20","%30"]
            self.display = defaultScreen
        } else if bill.count < 9 {
            // Cannot start bill with 0
            if bill == "" && button.title != "0" || bill != ""{
                bill += button.title
                self.display = "$" + bill
                calcTip(tip: tipValues, bill: bill)
            }
            
        }
    }
    
    func calcTip(tip: [String], bill: String) {
        var count = 0
        if Int(bill) != 0 {
            for i in [0.1,0.2,0.3] {
                self.tipValues[count] = "$" + String(Int(round(i * Double(bill)!)))
            
                count += 1
            }
        }
    }
}


struct ContentView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    var billColour: Color = .black

    let buttons: [[NumButtons]] = [
        [.seven, .eight, .nine],
        [.four, .five, .six],
        [.one, .two, .three],
        [.zero, .clear]
    ]
    
    let coins: [Coins] = [.one, .two, .three]
    
    var body: some View {
        ZStack (alignment: .bottom) {
            
            // Colours
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack (spacing: 12) {
                
                // Tips View
                HStack(alignment: .bottom) {
                    Spacer()
                    ForEach(env.tipValues, id: \.self) { tip in
                        TipView(tip: tip)
                            .offset(x: 0, y: UIScreen.main.bounds.height/16)
                    }
                }
                
                // Coin View
                HStack {
                    Spacer()
                    ForEach(coins, id: \.self) { coin in
                        CoinView(coin: coin)
                    }
                }
                
                // Bill View
                HStack {
                    Spacer()
                    Text(env.display).foregroundColor(billColour)
                        .font(.custom("Chalkduster", size: 40))
                        .offset(x: -(UIScreen.main.bounds.width)/10, y: 0)
                    // .font(.system(size: 40))
                    
                }.padding()
                
                // Button View
                ForEach(buttons, id: \.self) { row in
                    HStack (spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            NumButtonView(button: button)
                        }
                    }
                } // End loops
            }.padding(.bottom)
            .offset(x: 0, y: -UIScreen.main.bounds.height/20)
        }
        }
    }


struct NumButtonView: View {
    // Enum type
    var button: NumButtons
    @EnvironmentObject var env: GlobalEnvironment
    
    var body: some View {
        Button(action: {
            // Sends update
            self.env.receiveButton(button: self.button)
        }) {
            Text(button.title)
            .font(.custom("Chalkduster", size: 30))
           
                .frame(width: self.frameWidth(button: self.button), height: (UIScreen.main.bounds.width - 4 * 11) / 4)
            .foregroundColor(.white)
            .background(button.backgroundColor)
            .cornerRadius(self.frameWidth(button: button) / 2)
        }
    }
    
    func frameWidth(button: NumButtons) -> CGFloat {
        switch button {
            case .zero:
                return (UIScreen.main.bounds.width - 3 * 11) / 2
            default:
                return (UIScreen.main.bounds.width - 4 * 11) / 4
        }
    }
}


struct CoinView: View {
    // Enum type
    var coin: Coins
    
    @EnvironmentObject var env: GlobalEnvironment
    
    var body: some View {
       
        Image(coin.image)
            .foregroundColor(Color("CoinColor"))
            .offset(x: -(UIScreen.main.bounds.width)/9, y: 0)
            .frame(width: (UIScreen.main.bounds.width - 3 * 3) / 4, height: (UIScreen.main.bounds.width - 3 * 3) / 4)
        
    }
}


struct TipView: View {
    @EnvironmentObject var env: GlobalEnvironment
    var tip: String
    var body: some View {
        Text(tip)
        .font(.custom("Chalkduster", size: 30))
        .offset(x: -(UIScreen.main.bounds.width)/9, y: 0)
        .frame(width: (UIScreen.main.bounds.width - 3 * 3) / 4, height: (UIScreen.main.bounds.width - 3 * 3) / 4)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GlobalEnvironment())
    }
}
