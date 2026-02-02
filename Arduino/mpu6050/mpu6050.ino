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
  Serial.begin(500000);
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
  
  // ---- Serial Plotter header ----
  Serial.println(
    "ax,ay,az,gx,gy,gz"
  );
}

void loop() {
  // Update IMU
  imu.update();
  imu.getAccel(&accel);
  imu.getGyro(&gyro);

  Serial.print(accel.accelX); Serial.print(',');
  Serial.print(accel.accelY); Serial.print(',');
  Serial.print(accel.accelZ); Serial.print(',');
  Serial.print(gyro.gyroX);   Serial.print(',');
  Serial.print(gyro.gyroY);   Serial.print(',');
  Serial.println(gyro.gyroZ);

  delayMicroseconds(1000);
}
