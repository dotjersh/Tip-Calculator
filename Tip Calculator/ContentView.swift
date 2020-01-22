//
//  ContentView.swift
//  Tip Calculator
//
//  Created by John Slomka on 2020-01-09.
//  Copyright © 2020 John Slomka. All rights reserved.
//

import SwiftUI

// Colors
let BUTTON_COLOR = Color(".black")
let CLEAR_BUTTON_COLOR = Color(".black")
let BUTTON_TEXT_COLOR = Color(.white)
let TIP_COLOR = Color(.black)
let BILL_COLOR = Color(.black)
let SETTINGS_COLOR = CLEAR_BUTTON_COLOR


// ------------- ENUMS -------------
enum NumButtons: String {
    case zero, one, two, three, four, five, six, seven, eight, nine
    case clear
    var backgroundColor: Color {
        switch self {
            case .clear:
                return CLEAR_BUTTON_COLOR
            default:
                return BUTTON_COLOR
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
// ------------- END ENUMS -------------


// ------------- GLOBAL OBJECT -------------
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
        } else if bill.count < 5 {
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
                let value = String(Int(round(i * Double(bill)!)))
                let contained = tipValues.contains("$"+value)
                if value == "0" {
                    self.tipValues[count] = "--"
                } else if contained && count == 2 || contained && count == 1 {
                    self.tipValues[count-1] = "--"
                    self.tipValues[count] = "$" + value
                } else {
                     self.tipValues[count] = "$" + value
                }
                count += 1
            }
        }
    }
}
// ------------- END GLOBAL OBJECT -------------


// ------------- MAIN VIEW -------------
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
                .statusBar(hidden: true)
            VStack (spacing: 12) {
                HStack(alignment: .bottom) {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                        Text("Settings")
                        .font(.custom("Chalkduster", size: 15))
                        .foregroundColor(SETTINGS_COLOR)
                        .offset(x: UIScreen.main.bounds.height/8, y: UIScreen.main.bounds.height/20)
                    }
                }
                
                // Tips View
                HStack(alignment: .bottom) {
                    Spacer()
                    ForEach(env.tipValues, id: \.self) { tip in
                        TipView(tip: tip).allowsHitTesting(true)
                        .offset(x: 0, y: UIScreen.main.bounds.height/16)
                        .allowsTightening(true)
                        .truncationMode(.middle)
                    
                        
                    }
                }
                
                // Coin View
                HStack {
                    Spacer()
                    ForEach(coins, id: \.self) { coin in
                        CoinView(coin: coin)
                        .scaleEffect((UIScreen.main.bounds.width)/350)
                    }
                }
                
                // Bill View
                HStack {
                    Spacer()
                    Text(env.display).foregroundColor(billColour)
                    .font(.custom("Chalkduster", size: 40))
                    .offset(x: -(UIScreen.main.bounds.width)/10, y: 0)
                    .foregroundColor(BILL_COLOR)
                }.padding()
                
                // Button View
                ForEach(buttons, id: \.self) { row in
                    HStack (spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            NumButtonView(button: button)
                            .minimumScaleFactor(0.5)
                            .scaleEffect((UIScreen.main.bounds.width)/350)
                        }
                    }
                } // End loops
            }.padding(.bottom)
            .offset(x: 0, y: -UIScreen.main.bounds.height/20)
        }
        }
    }
// ------------- END MAIN VIEW -------------


// ------------- NESTED VIEWS -------------
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
            .foregroundColor(BUTTON_TEXT_COLOR)
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
        .offset(x: -(UIScreen.main.bounds.width)/9, y: 0)
        .frame(width: (UIScreen.main.bounds.width - 3 * 3) / 4, height: (UIScreen.main.bounds.width - 3 * 3) / 4)
    }
}

struct TipView: View {
    @EnvironmentObject var env: GlobalEnvironment
    var tip: String
    var body: some View {
        Text(tip).scaledToFit()
        .font(.custom("Chalkduster", size: 30))
        .offset(x: -(UIScreen.main.bounds.width)/9, y: 0)
        .frame(width: (UIScreen.main.bounds.width - 3 * 3) / 4, height: (UIScreen.main.bounds.width - 3 * 3) / 4)
        .foregroundColor(TIP_COLOR)
    }
    
}
// ------------- END NESTED VIEWS -------------


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GlobalEnvironment())
    }
}
