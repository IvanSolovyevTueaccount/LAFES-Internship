#include <Wire.h>
#include <FastIMU.h>

#define IMU_ADRESS 0x68

MPU6500 imu;
calData calib;

AccelData accel;
GyroData gyro;

struct IMUPacket {
  float ax;
  float ay;
  float az;
  float gx;
  float gy;
  float gz;
};

IMUPacket pkt;

const uint8_t SYNC[2] = {0xAA, 0x55};

void setup() {
  Serial.begin(460800);
  Wire.begin();
  Wire.setClock(400000);  

  calib.accelBias[0] = 0;
  calib.accelBias[1] = 0;
  calib.accelBias[2] = 0;

  calib.gyroBias[0] = 0;
  calib.gyroBias[1] = 0;
  calib.gyroBias[2] = 0;

  int err = imu.init(calib, IMU_ADRESS);
  if (err != 0) {
    Serial.print("IMU init failed, error code: ");
    Serial.println(err);
    while (1);
  }
}

void loop() {
  imu.update();

  imu.getAccel(&accel);
  imu.getGyro(&gyro);
  
  pkt.ax = accel.accelX;
  pkt.ay = accel.accelY;
  pkt.az = accel.accelZ;
  pkt.gx = gyro.gyroX;
  pkt.gy = gyro.gyroY;
  pkt.gz = gyro.gyroZ;

  Serial.write(SYNC, 2); 
  Serial.write((uint8_t*)&pkt, sizeof(pkt));

  delayMicroseconds(1250);  // 800 Hz
}
