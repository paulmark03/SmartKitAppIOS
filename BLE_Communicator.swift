//
//  BLE_Communicator.swift
//  BTConnDemo
//
//  Created by Paul Marcu on 04.10.2023.
//

import CoreBluetooth

class BluetoothService: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    let DEVICE_SERVICE_UUID = CBUUID.init(string: "FFE0")
    let CHAR_UUID = CBUUID.init(string: "FFE1")
    
    var accumulatedData = ""
    private var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    var strVal: String = ""
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", DEVICE_SERVICE_UUID);
            centralManager.scanForPeripherals(withServices: [DEVICE_SERVICE_UUID])
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered \(peripheral.name!)")
        
//        if peripheral.name == "iOSArduinoBoard" {
        // Copy the peripheral instance
        self.peripheral = peripheral
        
        // Connect!
        self.centralManager.connect(peripheral)
        
    }
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to BLE device")
            peripheral.delegate = self
            peripheral.discoverServices([DEVICE_SERVICE_UUID]);
            
            // We've found it so stop scan
            self.centralManager.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            print("Disconnected");
            self.peripheral = nil;
            // Start scanning again
            print("Central scanning for", DEVICE_SERVICE_UUID);
            centralManager.scanForPeripherals(withServices: [DEVICE_SERVICE_UUID]);
        }
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let services = peripheral.services {
//            for service in services {
//                if service.uuid == DEVICE_SERVICE_UUID {
//                    print("LED service found")
//                    //Now kick off discovery of characteristics
//                    peripheral.discoverCharacteristics([DEVICE_SERVICE_UUID], for: service)
//                }
//            }
//        }
        
        for service in peripheral.services ?? [] {
            print(service)
            if service.uuid == DEVICE_SERVICE_UUID {
                peripheral.discoverCharacteristics([CHAR_UUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            
            var value: UInt8 = 1

            let data = NSData(bytes: &value, length: MemoryLayout<UInt8>.size)
            
            print("ceva")
            print(characteristic.value)
            peripheral.writeValue(data as Data, for: characteristic,type: CBCharacteristicWriteType.withoutResponse)
            peripheral.setNotifyValue(true, for: characteristic)
        }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CHAR_UUID {

            if let data = characteristic.value, let newData = String(data: data, encoding: .utf8) {

                // Add new data to accumulatedData
                accumulatedData += newData
                
                // Check if accumulatedData contains the delimiter '|'
                if accumulatedData.contains("|") {
                    
                    // Split the data based on the delimiter
                    let completeMessage = accumulatedData.replacingOccurrences(of: "|", with: "")

                    // The complete message is the first component

                    
                    print("Complete Message: \(completeMessage)")

                    self.strVal = completeMessage
                    accumulatedData = ""
                }
            }
        }
    }
    
    func checkConnectivity() -> Bool {
        if peripheral != nil {
            return true
        }
        return false
    }
    
}

