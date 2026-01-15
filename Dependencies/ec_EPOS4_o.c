/*
        ec_EPOS4_o

        (c) Ferry Schoenmakers, 2022

	// Outputs:
	// 	y[0] = Statusword
	// 	y[1] = Torque actual value
	// 	y[2] = Velocity actual value
	// 	y[3] = Position actual value

	Inputs: 
		u[0] = Controlword
		u[1] = Target torque
		u[2] = Target velocity
		u[3] = Target position
					
        Parameter: link id
*/
#define S_FUNCTION_NAME ec_EPOS4_o
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NSTATES         0
#define NINPUTS         2
// #define NOUTPUTS        1
#define NPARAMS         1

#define LINK_ID         ssGetSFcnParam(S,0)

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#include <math.h>
#include "ethercat.h"

typedef struct PACKED
{
	uint16_t    controlword;
    int16_t     target_value;
} out_EPOS4t;	

/* define global data struct */
typedef struct tag_sfun_global_data {
	int ilink;
    out_EPOS4t *out_EPOS4_;
    uint8_t Ostartbit;
} sfun_global_data, *psfun_global_data;

/*====================*
 * S-function methods *
 *====================*/

static void mdlInitializeSizes(SimStruct *S)
{
    int_T Rworksize;
    
	ssSetNumSFcnParams(S,NPARAMS);

	ssSetNumContStates(S,NSTATES);
	ssSetNumDiscStates(S,0);

	if (!ssSetNumInputPorts(S,1)) return;
	ssSetInputPortWidth(S,0,NINPUTS);
	ssSetInputPortDirectFeedThrough(S,0,1); 

	if (!ssSetNumOutputPorts(S,0)) return;

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
    psfgd->out_EPOS4_ = NULL;
	psfgd->ilink=(int) (*(mxGetPr(LINK_ID)));
	int nEPOS4 = 0;
	for (cnt = 1; cnt <= ec_slavecount; cnt++)
	{
		if (ec_slave[cnt].eep_id == 0x64500000)
		{
			nEPOS4++;
			if (nEPOS4 == psfgd->ilink){
				psfgd->out_EPOS4_ = (out_EPOS4t*) ec_slave[cnt].outputs;
                psfgd->Ostartbit = ec_slave[cnt].Ostartbit;
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

    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);

    psfgd->out_EPOS4_->controlword = (uint16_t) U(0);
    psfgd->out_EPOS4_->target_value = (int32_t) U(1);
#endif
}
/*************************************************************************/

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    /* get pointers to global data */
    double* ptrRwrk = ssGetRWork(S);
    psfun_global_data psfgd;
    psfgd = (psfun_global_data) ptrRwrk;

    if (psfgd->out_EPOS4_)
    {
        psfgd->out_EPOS4_->controlword = 0x2;   // Send a quickstop on exit to make sure drive is not actuated anymore
        psfgd->out_EPOS4_->target_value = 0;
    }
#endif    
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
