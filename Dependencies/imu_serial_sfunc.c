/*
    imu_serial_sfunc
    (c) Stijn Michiels, 2026
*/

#define S_FUNCTION_NAME  imu_serial_sfunc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>

/*====================*
 * Linux-only includes
 *====================*/
#ifndef MATLAB_MEX_FILE
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#endif

/*====================*
 * Constants
 *====================*/
#define OUTPUT_WIDTH 6
#define PACKET_SIZE 24
#define SYNC1 0xAA
#define SYNC2 0x55

/*====================*
 * Globals
 *====================*/
static uint8_t rxBuf[PACKET_SIZE];
static real_T lastOutput[OUTPUT_WIDTH] = {0};
static int rxIndex = 0;
static int syncState = 0;

static char devicePath[256] = "/dev/ttyUSB0";
static real_T sampleTime = 1.0;

#ifndef MATLAB_MEX_FILE
static int fd = -1;

static int setupSerial(int fd)
{
    struct termios tio;

    if (tcgetattr(fd, &tio) != 0)
        return -1;

    cfmakeraw(&tio);

    cfsetispeed(&tio, B460800);
    cfsetospeed(&tio, B460800);

    tio.c_cflag |= (CLOCAL | CREAD);
    tio.c_cflag &= ~CRTSCTS;     // no flow control
    tio.c_cflag &= ~CSTOPB;      // 1 stop bit
    tio.c_cflag &= ~PARENB;      // no parity
    tio.c_cflag &= ~CSIZE;
    tio.c_cflag |= CS8;           // 8 data bits

    tio.c_cc[VMIN]  = 0;          // non-blocking read
    tio.c_cc[VTIME] = 0;

    return tcsetattr(fd, TCSANOW, &tio);
}
#endif

/*====================*
 * S-function parameters
 *====================*/
#define PARAM_DEVICE     0
#define PARAM_SAMPLETIME 1
#define NUM_PARAMS       2

/*====================*
 * mdlInitializeSizes
 *====================*/
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_PARAMS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

#ifdef MATLAB_MEX_FILE
    mxGetString(ssGetSFcnParam(S, PARAM_DEVICE), devicePath, sizeof(devicePath));
    sampleTime = mxGetScalar(ssGetSFcnParam(S, PARAM_SAMPLETIME));
    if (sampleTime <= 0.0) sampleTime = 1.0;
#endif

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumInputPorts(S, 0);

    ssSetNumOutputPorts(S, 1);
    ssSetOutputPortWidth(S, 0, OUTPUT_WIDTH);

    ssSetNumSampleTimes(S, 1);
}

/*====================*
 * Sample times
 *====================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, sampleTime);
    ssSetOffsetTime(S, 0, 0.0);
}

/*====================*
 * mdlStart
 *====================*/
#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    fd = open(devicePath, O_RDONLY | O_NOCTTY | O_NONBLOCK);
    if (fd < 0) {
        perror("imu_serial_sfunc: open failed");
        return;
    }

    if (setupSerial(fd) != 0) {
        perror("imu_serial_sfunc: termios setup failed");
        close(fd);
        fd = -1;
    }
#endif
}

/*====================*
 * mdlOutputs
 *====================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    real_T *y = ssGetOutputPortRealSignal(S,0);

    // Default: output last known good packet
    memcpy(y, lastOutput, OUTPUT_WIDTH * sizeof(real_T));

    if (fd < 0)
        return;

    // ===== REPLACE old single-byte loop with this =====
    ssize_t n = read(fd, &rxBuf[rxIndex], PACKET_SIZE - rxIndex);
    if (n > 0) {
        for (ssize_t i = 0; i < n; i++) {
            uint8_t byte = rxBuf[rxIndex + i];
            switch (syncState) {
                case 0: // wait for SYNC1
                    if (byte == SYNC1) syncState = 1;
                    break;

                case 1: // wait for SYNC2
                    if (byte == SYNC2) { syncState = 2; rxIndex = 0; }
                    else { syncState = 0; }
                    break;

                case 2: // read payload
                    rxBuf[rxIndex++] = byte;
                    if (rxIndex == PACKET_SIZE) {
                        float *f = (float*)rxBuf;
                        for (int i = 0; i < OUTPUT_WIDTH; i++)
                            lastOutput[i] = f[i];

                        // reset for next packet
                        syncState = 0;
                        rxIndex = 0;
                    }
                    break;
            }
        }
    }
#endif
}


/*====================*
 * mdlTerminate
 *====================*/
static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    if (fd >= 0) {
        close(fd);
        fd = -1;
    }
#endif
}

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
