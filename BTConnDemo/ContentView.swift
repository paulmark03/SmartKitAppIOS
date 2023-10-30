//
//  ContentView.swift
//  BTConnDemo
//
//  Created by Paul Marcu on 03.10.2023.

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject var service = BluetoothService()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    //@State var sensorValue: String = "0.0,12.4,455.2,51.2,1900.5,0.0"
    @State var sensorValue: String = ""
    @State private var storedValues: [String] = UserDefaults.standard.array(forKey: "storedValues") as? [String] ?? initializeDefaultArray()
    //let floatArray: [Float] = sensorValue.split(separator: ",").compactMap { Float($0) }
    
    static func initializeDefaultArray() -> [String] {
            let defaultArray = Array(repeating: "10.0", count: 6)
            UserDefaults.standard.set(defaultArray, forKey: "storedValues")
            return defaultArray
        }
    
    func getStatus(for sensorValue: String, index: Int) -> (color: Color, height: CGFloat, text: String) {
        print(sensorValue)
        if let sensorDouble = Double(sensorValue) {
            let threshold1 = (Double(storedValues[index]) ?? 10) / 3
            let threshold2 = threshold1 * 2
            if sensorDouble < threshold1 {
                return (Color.red, 20, "low")
            } else if sensorDouble < threshold2 {
                return (Color.yellow, 35, "mid")
            } else {
                return (Color.green, 50, "full")
            }
        }
        return (Color.blue, 45, "N/A") // default if sensorValue is not a valid number
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Red strip with title
                Text("Smart Kit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .background(Color.red)

                // Red cross icon
                Image(systemName: "plus.rectangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.red)
                    .padding()

                        
                
                // 3x2 Grid of boxes with statuses
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                    let stringArray: [String] = {
                        var array = sensorValue.split(separator: ",").map(String.init)
                        while array.count < 6 {
                            array.append("0.0")
                        }
                        return array
                    }()
                    ForEach(1...6, id: \.self) { index in
                        
                        let currentStatus = getStatus(for: stringArray[index-1], index: index-1)
                        StatusBox(color: currentStatus.color, height: currentStatus.height, statusText: "Med \(index)", index: index-1, value: stringArray[index-1], storedValues: $storedValues)
                    }
                }
                .padding(.horizontal)
                .onReceive(timer, perform: { _ in
                    print("Sensor value: \(storedValues)")
                    sensorValue = service.strVal
                })

                Spacer()
                Spacer()

//                Button("Check Connectivity", action: { /* Handle check connectivity action */ })
//                    .padding()

                HStack(spacing: geometry.size.width/3) {
                    Image(systemName: "house")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Image(systemName: "list.bullet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                .padding(.bottom)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all)) // White background covering entire screen
        }
    }
}

struct StatusBox: View {
    let color: Color
    let height: CGFloat
    let statusText: String
    let index: Int
    let value: String
    @Binding var storedValues: [String]

    @State private var showConfirmationAlert = false

    var body: some View {
        ZStack {
            VStack {
                Text("Status:")
                    .font(.subheadline)
                Rectangle()
                    .fill(color)
                    .frame(width: 50, height: height)
                    .cornerRadius(5)
                Text(statusText)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 5)
            
            // Gear icon in the top left
            VStack {
                HStack {
                    Button(action: {
                        showConfirmationAlert = true
                    }, label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(0)
                    })
                    Spacer()
                }
                Spacer()
            }
        }
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to update?"),
                primaryButton: .default(Text("Yes"), action: {
                    updateArray()
                }),
                secondaryButton: .cancel()
            )
        }
    }

    func updateArray() {
        // Adding a new element to the array for demonstration; modify as needed.
        storedValues[index] = value
        
        // Storing the updated array back to UserDefaults
        UserDefaults.standard.set(storedValues, forKey: "storedValues")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
