/*
        ec_EPOS4_i

        (c) Ferry Schoenmakers, 2022

	Outputs:
		y[0] = Statusword
		y[1] = Error code
		y[2] = Torque actual value
		y[3] = Velocity actual value
        y[4] = Position actual value

	// Inputs: 
	// 	u[0] = Controlword
	// 	u[1] = Target torque
	// 	u[2] = Target velocity
	// 	u[3] = Target position
					
        Parameter: link id
*/
#define S_FUNCTION_NAME ec_EPOS4_i
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NSTATES         0
// #define NINPUTS         1
#define NOUTPUTS        2
#define NPARAMS         2

#define LINK_ID         ssGetSFcnParam(S,0)
#define OPERATING_MODE	ssGetSFcnParam(S,1)

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#include <math.h>
#include "ethercat.h"

typedef struct PACKED
{ 
	uint16_t	statusword;
    int32_t 	actual_value;
} in_EPOS4t;

/* define global data struct */
typedef struct tag_sfun_global_data {
	int ilink;
	uint8_t operating_mode;
    in_EPOS4t *in_EPOS4_;
    uint8_t Istartbit;
} sfun_global_data, *psfun_global_data;

/* Operating mdoes */
enum OperatingModes {
	eProfilePosition = 1,
	eProfileVelocity = 3,
	eHomingMode = 6,
	eCyclicSynchronousPosition = 8,
	eCyclicSynchronousVelocity = 9,
	eCyclicSynchronousTorque = 10
};

/*====================*
 * S-function methods *
 *====================*/

static void mdlInitializeSizes(SimStruct *S)
{
    int_T Rworksize;

	ssSetNumSFcnParams(S,NPARAMS);

	ssSetNumContStates(S,NSTATES);
	ssSetNumDiscStates(S,0);

	if (!ssSetNumInputPorts(S,0)) return;

	if (!ssSetNumOutputPorts(S,1)) return;
	ssSetOutputPortWidth(S,0,NOUTPUTS);

    ssSetNumSampleTimes(S,1);

    /* compute necessary amount of real_T workspace */
    Rworksize = ( sizeof(sfun_global_data)/sizeof(double) + 1 );
    ssSetNumRWork(S,Rworksize);
    ssSetNumIWork(S,0);
    ssSetNumPWork(S,0);
    ssSetNumModes(S,0);
    ssSetNumNonsampledZCs(S,0);
}
/*************************************************************************/

static void mdlInitializeSampleTimes(SimStruct *S)
{
	ssSetSampleTime(S,0, CONTINUOUS_SAMPLE_TIME);
	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}
/*************************************************************************/
#ifndef MATLAB_MEX_FILE
static void writeAndVerifySDO(uint16 Slave, uint16 Index, uint8 SubIndex, int ObjectSize, void* data)
{
    /* Attempt to write user configuration */
    ec_SDOwrite(Slave, Index, SubIndex, FALSE, ObjectSize, data, EC_TIMEOUTRXM);
    /* Copy user data and check if succesful */
    switch(ObjectSize)
    {
        case 1: ;
            uint8_t user_data1 = *(uint8_t*)(data);
            ec_SDOread(Slave, Index, SubIndex, FALSE, &ObjectSize, &user_data1, EC_TIMEOUTRXM);
            if (user_data1 !=*(uint8_t*)(data)) {
                printf("\tERROR configuring parameter %04X:%02X via SDO!\n", Index, SubIndex);
                exit(1);
            }
            printf("\tparameter %04X:%02X configured to: %u\n", Index, SubIndex, user_data1);
            break;
        case 2: ;
            uint16_t user_data2 = *(uint16_t*)(data);
            ec_SDOread(Slave, Index, SubIndex, FALSE, &ObjectSize, &user_data2, EC_TIMEOUTRXM);
            if (user_data2 !=*(uint16_t*)(data)) {
                printf("\tERROR configuring parameter %04X:%02X via SDO!\n", Index, SubIndex);
                exit(1);
            }
            printf("\tparameter %04X:%02X configured to: %u\n", Index, SubIndex, user_data2);
            break;
        case 4: ;
            uint32_t user_data3 = *(uint32_t*)(data);
            ec_SDOread(Slave, Index, SubIndex, FALSE, &ObjectSize, &user_data3, EC_TIMEOUTRXM);
            if (user_data3 !=*(uint32_t*)(data)) {
                printf("\tERROR configuring parameter %04X:%02X via SDO!\n", Index, SubIndex);
                exit(1);
            }
            printf("\tparameter %04X:%02X configured to: %u\n", Index, SubIndex, user_data3);
            break;
        default:
            printf("ERROR, unsupported SDO datatype requested!");
            return;
            break;
    }
}
#endif
/*************************************************************************/

#ifndef MATLAB_MEX_FILE
static void setOperatingMode(int slave_id, uint8_t operating_mode)
{
	writeAndVerifySDO(slave_id, 0x6060, 0x00, sizeof(uint8_t), &operating_mode);
}
#endif
/*************************************************************************/

#define MDL_INITIALIZE_CONDITIONS
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
	/* get pointers to global data */
    double* ptrRwrk = ssGetRWork(S);
    psfun_global_data psfgd;
    psfgd = (psfun_global_data) ptrRwrk;

	/* Loop through found slaves and get pointer to ours */
	int cnt;
	psfgd->ilink=(int) (*(mxGetPr(LINK_ID)));
	// We only allow CyclicSynchronousPosition, CyclicSynchronousVelocity and CyclicSynchronousTorque
	// as operation modes with enum values 8,9 and 10 respectively. Hence, convert matlab index to enum 
	psfgd->operating_mode=(int) (*(mxGetPr(OPERATING_MODE)) + 7);
	int nEPOS4 = 0;
	for (cnt = 1; cnt <= ec_slavecount; cnt++)
	{
		if (ec_slave[cnt].eep_id == 0x64500000)
		{
			nEPOS4++;
			if (nEPOS4 == psfgd->ilink)
			{
				psfgd->in_EPOS4_ = (in_EPOS4t*) ec_slave[cnt].inputs;
                psfgd->Istartbit = ec_slave[cnt].Istartbit;
				/* Configure slave via SDO */
                printf("Configuring slave %d (EPOS4):\n", cnt);
				/*Set operating mode */
				setOperatingMode(cnt, psfgd->operating_mode);       // original
                // setOperatingMode(cnt, 10);                       // operating mode = 10, torque mode
				return;
			}
		}
	}
	printf("ERROR: %s:%d, incorrect link ID, could not find slave with link ID : %d\n",__FILE__,__LINE__,psfgd->ilink);
    exit(1);
#endif
}
#endif /* INITIALIZE_CONDITIONS */
/*************************************************************************/

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    /* get pointers to global data */
    double* ptrRwrk = ssGetRWork(S);
    psfun_global_data psfgd;
    psfgd = (psfun_global_data) ptrRwrk;

    real_T *y = ssGetOutputPortRealSignal(S,0);      

    y[0] = (double) psfgd->in_EPOS4_->statusword;
	y[1] = (double) psfgd->in_EPOS4_->actual_value;
#endif
}
/*************************************************************************/

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
