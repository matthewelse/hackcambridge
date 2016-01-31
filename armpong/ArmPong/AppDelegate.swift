
//
//  AppDelegate.swift
//  ArmPong
//
//  Created by Matthew Else on 30/01/2016.
//  Copyright (c) 2016 Corpus/King's Hack Cambridge Team. All rights reserved.
//


import Cocoa
import SpriteKit
import CoreBluetooth

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    var centralManager:CBCentralManager!
    var connectingPeripheral:CBPeripheral!
    
    var calibrationScene: CalibrationScene?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        
        /* Pick a size for the scene */
        let scene = ConnectionScene(size:self.skView.bounds.size)
        
        scene.scaleMode = .AspectFill
        self.skView!.presentScene(scene)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView!.ignoresSiblingOrder = true
        
        self.skView!.showsFPS = true
        self.skView!.showsNodeCount = true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    // central manager delegate functions
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("connected!")
        
        calibrationScene = CalibrationScene(size:self.skView.bounds.size)
        self.skView.presentScene(calibrationScene)
        
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
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
    
    // peripheral code
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (characteristic.UUID == CBUUID(string: "fffe")) {
            // updated the adc characteristic
            
            let (ladc, radc) = getADCData(characteristic)
            
            /* handle the adc value in the current scene. */
            if let calibScene = calibrationScene {
                calibScene.handleAdcValue(ladc, valuer: radc)
            }
            
            
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
    
    func getADCData(characteristic: CBCharacteristic) -> (Int, Int) {
        let data = characteristic.value
        
        let count = data!.length / sizeof(UInt8)
        
        // create an array of Uint8
        var array = [UInt8](count: count, repeatedValue: 0)
        
        // copy bytes into array
        data!.getBytes(&array, length:count * sizeof(UInt8))
        
        // get a 16-bit number out of the array (big-endian for some reason...)
        
        let a = Int(array[0]) + Int(array[1]) << 8
        let b = Int(array[2]) + Int(array[3]) << 8
        
        return (a, b)
    }
}
