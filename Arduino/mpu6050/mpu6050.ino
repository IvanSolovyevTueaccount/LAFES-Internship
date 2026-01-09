#include <Wire.h>
#include <FastIMU.h>

#define IMU_ADRESS 0x68

MPU6500 imu;
calData calib;

AccelData accel;
GyroData gyro;

void setup() {
  Serial.begin(115200);
  Wire.begin();
  Wire.setClock(100000);

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

  Serial.println("aX, aY, aZ, gX, gY, gZ");
}

void loop() {
  imu.update();

  imu.getAccel(&accel);
  imu.getGyro(&gyro);
  
  // CSV output
  // accel: m/s^2
  // gyro: rad/s
  Serial.print(accel.accelX); Serial.print(",");
  Serial.print(accel.accelY); Serial.print(",");
  Serial.print(accel.accelZ); Serial.print(",");
  Serial.print(gyro.gyroX);   Serial.print(",");
  Serial.print(gyro.gyroY);   Serial.print(",");
  Serial.println(gyro.gyroZ);

  delayMicroseconds(1000); // ~1000 Hz
  
}
