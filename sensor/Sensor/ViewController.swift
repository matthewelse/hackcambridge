//
//  ViewController.swift
//  Sensor
//
//  Created by Matthew Else on 30/01/2016.
//  Copyright © 2016 Hackathon Team. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var graph: GraphView!
    @IBOutlet weak var adcLabel: UILabel!
    
    var centralManager:CBCentralManager!
    var connectingPeripheral:CBPeripheral!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("discovered peripheral")
        print(peripheral)
        print(advertisementData)

        
        connectingPeripheral = peripheral
        connectingPeripheral.delegate = self
        centralManager.connectPeripheral(connectingPeripheral, options: nil)
        centralManager.stopScan()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch (central.state) {
        case .PoweredOn:
            print("powered on!")
            let serviceUUIDs = [CBUUID(string: "ffff")]
            let periphs = central.retrieveConnectedPeripheralsWithServices(serviceUUIDs)
            
            if periphs.count > 0 {
                print("found one!")
                let device = periphs.last! as CBPeripheral
                
                connectingPeripheral = device
                connectingPeripheral.delegate = self
                centralManager.connectPeripheral(device, options: nil)
            } else {
                print("looking for one")
                centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: nil)
            }
        
        default:
            print(central.state)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (characteristic.UUID == CBUUID(string: "fffe")) {
            // updated the adc characteristic
            
            let adcval = getADCData(characteristic)
            
            print("received notification. the new adc value is: " + String(adcval))
            adcLabel.text = "ADC Value: " + String(adcval)
            
            graph.addDataPoint(Float(adcval));
        } else {
            print("received notification from another characteristic")
            print(characteristic.UUID);
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if service.UUID == CBUUID(string: "ffff") {
            // this is the ADC service... look for the ADC char
            
            for characteristic in service.characteristics! {
                if characteristic.UUID == CBUUID(string: "fffe") {
                    print("found an adc characteristic. enabling notifications")
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
            }
        }
    }
    
    func getADCData(characteristic: CBCharacteristic) -> Int {
        let data = characteristic.value
        
        let count = data!.length / sizeof(UInt8)
        
        // create an array of Uint8
        var array = [UInt8](count: count, repeatedValue: 0)
        
        // copy bytes into array
        data!.getBytes(&array, length:count * sizeof(UInt8))
        
        // get a 16-bit number out of the array (little-endian)
        
        return Int(array[0]) + Int(array[1]) << 8;
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

