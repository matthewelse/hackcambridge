/* HackCambridge Project
 * 
 * Something to do with some home-made ECG sensors, with BLE
 * and stuff like that...
 *
 * Made by some people from Corpus Christi and King's colleges, Cambridge
 *
 * (Elena Rastorgueva, Lewis Jones and Matthew Else)
 *
 */

#include "mbed-drivers/mbed.h"

#include "ble/BLE.h"
#include "ble/Gap.h"

// set up all of the LEDs so that we can quickly use them
DigitalOut led1(LED1, 0);
DigitalOut led2(LED2, 0);
DigitalOut led3(LED3, 0);
DigitalOut led4(LED4, 0);

AnalogIn   a0(P0_1);
AnalogIn   a1(P0_2);

// set up some BLE config

const static char     DEVICE_NAME[] = "HackCambridge Sensor";
const static uint16_t ADC_SERVICE_UUID = 0xffff;
const static uint16_t ADC_VALUE_CHAR_UUID = 0xfffe;

// 0xffff is just a placeholder for the time being
const static uint16_t UUIDs = { ADC_SERVICE_UUID };

const static uint32_t SAMPLE_INTERVAL_MS = 100; // ms

static uint32_t       adc_value = 0x00000000;

GattCharacteristic *adcChar;
GattService *adcServ;

uint16_t dataPointsA1[16];
uint16_t dataPointsA0[16];

uint16_t position = 0;
uint16_t partial_s_a0 = 0;
uint16_t partial_s_a1 = 0;

uint8_t complete = 0;

void onDisconnection(const Gap::DisconnectionCallbackParams_t *params) {
    printf("disconnected!\r\n");
    BLE::Instance().startAdvertising();
}

void onConnection(const Gap::ConnectionCallbackParams_t *params) {
    printf("connected!\r\n");
}

void getSensorValue() {
    // do some ADC stuff...
    // this will be called from a callback
    
    uint16_t a0_value = a0.read_u16();
    uint16_t a1_value = a1.read_u16();

    partial_s_a0 -= dataPointsA0[position];
    partial_s_a1 -= dataPointsA1[position];

    dataPointsA0[position] = a0_value;
    dataPointsA1[position] = a1_value;

    partial_s_a0 += a0_value;
    partial_s_a1 += a1_value;

    position++; 

    //printf("partial sum: %d\r\n", partial_s);

    if (position >= 16) {
        position = 0;
        complete = 1;
    }

    if (complete == 1) {
        // take the average of the points in the 
        adc_value = partial_s_a0 >> 4;
        adc_value |= (partial_s_a1 >> 4) << 16;

        //printf("writing: 0x%x\r\n", adc_value);
        BLE::Instance().gattServer().write(adcChar->getValueHandle(), (uint8_t *)&adc_value, sizeof(adc_value)); 
    } 
}

void heartbeat() {
    led1 = !led1; 
}

void afterInit(BLE::InitializationCompleteCallbackContext *ctxt) {
    // make a pretty LED flash.
    printf("setting up the led callbacks\r\n"); 
    minar::Scheduler::postCallback(getSensorValue).period(minar::milliseconds(20));
    
    BLE& ble_device = ctxt->ble;

    ble_device.gap().onConnection(onConnection);
    ble_device.gap().onDisconnection(onDisconnection);

    if (adcChar != NULL) {
        free(adcChar);
    }

    if (adcServ != NULL) {
        free(adcServ);
    }

    // initialise the custom ADC service 
    adcChar = new GattCharacteristic(ADC_VALUE_CHAR_UUID, (uint8_t*)&adc_value, sizeof(adc_value), sizeof(adc_value), GattCharacteristic::BLE_GATT_CHAR_PROPERTIES_NOTIFY | GattCharacteristic::BLE_GATT_CHAR_PROPERTIES_READ);
    GattCharacteristic *adcChars[] = { adcChar };
    adcServ = new GattService(ADC_SERVICE_UUID, adcChars, 1);

    // setup the GAP parameters
    ble_device.accumulateAdvertisingPayload(GapAdvertisingData::BREDR_NOT_SUPPORTED | GapAdvertisingData::LE_GENERAL_DISCOVERABLE);

    ble_device.setAdvertisingType(GapAdvertisingParams::ADV_CONNECTABLE_UNDIRECTED);

    ble_device.accumulateAdvertisingPayload(GapAdvertisingData::COMPLETE_LOCAL_NAME, (uint8_t *)DEVICE_NAME, sizeof(DEVICE_NAME));

    //ble_device.accumulateAdvertisingPayload(GapAdvertisingData::COMPLETE_LIST_16BIT_SERVICE_IDS, (uint8_t *)UUIDs, sizeof(UUIDs));
    //
    uint8_t uuids[] = { 0xff, 0xff };
    ble_device.accumulateAdvertisingPayload(GapAdvertisingData::COMPLETE_LIST_16BIT_SERVICE_IDS, uuids , 2);


    ble_device.setAdvertisingInterval(160);

    ble_device.addService(*adcServ);

    ble_device.startAdvertising();
    printf("advertising\r\n");
}

void app_start(int, char**) {
    minar::Scheduler::postCallback(heartbeat).period(minar::milliseconds(500));
    // schedule a callback to make sure we know it's working...
    printf("initialising\r\n");    
    // BLE is now a singleton class, so do it this way
    BLE::Instance().init(afterInit);
}

