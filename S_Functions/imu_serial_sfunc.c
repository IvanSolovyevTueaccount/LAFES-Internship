/*
        imu_serial_sfunc

        (c) Stijn Michiels, 2026

        Outputs: 0..width-1: IMU values (ax ay az gx gy gz ...)
*/

#define S_FUNCTION_NAME  imu_serial_sfunc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

static int fd = -1;          // Serial file descriptor
static int packetSize = 24;  // Default, overridden by parameter
static int outputWidth = 6;  // Default, overridden by parameter
static char devicePath[256]; // Default, overridden by parameter
static double sampleTime = 1; // Default sample time

/*====================*
 * S-function parameters
 *====================*/
#define PARAM_DEVICE     0
#define PARAM_PACKETSIZE 1
#define PARAM_OUTWIDTH   2
#define PARAM_SAMPLETIME 3
#define NUM_PARAMS       4

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_PARAMS);
    if(ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    ssSetNumContStates(S,0);
    ssSetNumDiscStates(S,0);

    if(!ssSetNumInputPorts(S,0)) return;

    if(!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S,0,outputWidth); // temporary, adjusted in mdlStart

    ssSetNumSampleTimes(S,1);
}

/*==================*
 * Sample times
 *==================*/
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S,0,sampleTime);
    ssSetOffsetTime(S,0,0.0);
}

/*==================*
 * mdlStart
 *==================*/
#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    // ----- read parameters -----
    const mxArray *mxDevice = ssGetSFcnParam(S, PARAM_DEVICE);
    const mxArray *mxPacket = ssGetSFcnParam(S, PARAM_PACKETSIZE);
    const mxArray *mxWidth  = ssGetSFcnParam(S, PARAM_OUTWIDTH);
    const mxArray *mxSample = ssGetSFcnParam(S, PARAM_SAMPLETIME);

    if(mxDevice && mxDevice->mxIsChar){
        strncpy(devicePath, mxArrayToString(mxDevice), sizeof(devicePath)-1);
        devicePath[sizeof(devicePath)-1] = '\0';
    } else {
        strncpy(devicePath, "/dev/ttyUSB0", sizeof(devicePath)-1);
    }

    if(mxPacket) packetSize = (int) mxGetScalar(mxPacket);
    if(mxWidth)  outputWidth = (int) mxGetScalar(mxWidth);
    if(mxSample) sampleTime = mxGetScalar(mxSample);

    // Update output port width dynamically
    ssSetOutputPortWidth(S,0,outputWidth);

    // ----- open serial port -----
    fd = open(devicePath, O_RDONLY | O_NONBLOCK);
    if(fd < 0){
        perror("Failed to open serial port");
    }
#endif
}

/*==================*
 * mdlOutputs
 *==================*/
static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    float buffer[outputWidth];
    int bytesRead = read(fd, buffer, packetSize);
    if(bytesRead == packetSize){
        real_T *y = ssGetOutputPortRealSignal(S,0);
        for(int i=0;i<outputWidth;i++){
            y[i] = buffer[i];
        }
    }
#endif
}

/*==================*
 * mdlTerminate
 *==================*/
static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    if(fd >= 0){
        close(fd);
        fd = -1;
    }
#endif
}

#include "simulink.c"