#include <Wire.h>
#include <FastIMU.h>

#define IMU_ADDRESS 0x68
#define SYNC1 0xAA
#define SYNC2 0x55

MPU6500 imu;
calData calib;
AccelData accel;
GyroData gyro;

struct IMUPacket {
  float ax, ay, az;
  float gx, gy, gz;
};

IMUPacket pkt;

void setup() {
  Serial.begin(460800);
  Wire.begin();
  Wire.setClock(400000);  // Fast I2C

  // Zero biases for now
  memset(&calib, 0, sizeof(calib));

  int err = imu.init(calib, IMU_ADDRESS);
  if (err != 0) {
    Serial.print("IMU init failed, code: ");
    Serial.println(err);
    while (1);
  }
}

void loop() {
  // Update IMU
  imu.update();
  imu.getAccel(&accel);
  imu.getGyro(&gyro);

  // Fill packet
  pkt.ax = accel.accelX;
  pkt.ay = accel.accelY;
  pkt.az = accel.accelZ;
  pkt.gx = gyro.gyroX;
  pkt.gy = gyro.gyroY;
  pkt.gz = gyro.gyroZ;

  // Send sync bytes + packet
  Serial.write(SYNC1);
  Serial.write(SYNC2);
  Serial.write((uint8_t*)&pkt, sizeof(pkt));

  // Wait ~1.25 ms → 800 Hz
  delayMicroseconds(1250);
}
