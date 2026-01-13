/*
    imu_serial_sfunc
    (c) Stijn Michiels, 2026
*/

#define S_FUNCTION_NAME  imu_serial_sfunc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include <stdint.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

/*====================*
 * Constants
 *====================*/
#define OUTPUT_WIDTH 6
#define PACKET_SIZE 24
#define SYNC1 0xAA
#define SYNC2 0x55

static uint8_t rxBuf[PACKET_SIZE];
static int rxIndex = 0;
static int syncState = 0;

/*====================*
 * Globals
 *====================*/
static int fd = -1;
static char devicePath[256] = "/dev/ttyUSB0";
static real_T sampleTime = 1.0;

/*====================*
 * Parameters
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
    /* Read parameters EARLY */
    mxGetString(ssGetSFcnParam(S, PARAM_DEVICE),
                devicePath, sizeof(devicePath));

    sampleTime = mxGetScalar(ssGetSFcnParam(S, PARAM_SAMPLETIME));
    if (sampleTime <= 0.0) sampleTime = 1.0;
#endif

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumInputPorts(S, 0);

    ssSetNumOutputPorts(S, 1);
    ssSetOutputPortWidth(S, 0, OUTPUT_WIDTH);

    ssSetNumSampleTimes(S, 1);
    ssSetNumPWork(S, 0);   /* NO PWORK NEEDED ANYMORE */
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
    fd = open(devicePath, O_RDONLY | O_NONBLOCK);
    if (fd < 0) {
        perror("imu_serial_sfunc: open failed");
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
    uint8_t byte;

    if (fd < 0) {
        memset(y, 0, OUTPUT_WIDTH * sizeof(real_T));
        return;
    }

    while (read(fd, &byte, 1) == 1) {

        switch (syncState) {

        case 0:  // wait for 0xAA
            if (byte == SYNC1)
                syncState = 1;
            break;

        case 1:  // wait for 0x55
            if (byte == SYNC2) {
                syncState = 2;
                rxIndex = 0;
            } else {
                syncState = 0;
            }
            break;

        case 2:  // read payload
            rxBuf[rxIndex++] = byte;
            if (rxIndex == PACKET_SIZE) {
                float *f = (float*)rxBuf;
                for (int i = 0; i < OUTPUT_WIDTH; i++)
                    y[i] = f[i];

                syncState = 0;   
                return;          
            }
            break;
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
