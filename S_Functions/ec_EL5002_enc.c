/*
        ec_EL5002_enc

        (c) Rene' van de Molengraft, 2007
        (c) Ferry Schoenmakers, 2019
        (c) Danny Hameeteman, 2025 Created EL5002 config based on EL5101
        (c) Stijn Michiels, 2025 Changed mdlOutputs to read second encoder correctly

        Outputs: y[0] = SSI output 1
                 y[1] = SSI output 2

        Parameter: link id
*/

#define S_FUNCTION_NAME ec_EL5002_enc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NSTATES         0
#define NINPUTS         0
#define NOUTPUTS        2
#define NPARAMS         1

#define LINK_ID         ssGetSFcnParam(S,0)

#include <math.h>
#include "ethercat.h"

typedef struct PACKED
{
    uint16     status1;
    int32	   invalue1;
    uint16     status2;
	int32	   invalue2;
} in_EL5002t;

/* define global data struct */
typedef struct tag_sfun_global_data {
	int ilink;
    in_EL5002t *in_EL5002_;
    uint8_t startbit;
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

	if (!ssSetNumInputPorts(S,0)) return;
/*	ssSetInputPortWidth(S,0,NINPUTS);
	ssSetInputPortDirectFeedThrough(S,0,0); */

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
	int n5002 = 0;
	for (cnt = 1; cnt <= ec_slavecount; cnt++)
	{
		if (ec_slave[cnt].eep_id == 0x138A3052)
		{
			n5002++;
			if (n5002 == psfgd->ilink){
                psfgd->in_EL5002_ = (in_EL5002t*) ec_slave[cnt].inputs;
                psfgd->startbit = ec_slave[cnt].Istartbit;
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

    /* read enc channel */
    int32_t ivalue[2];
    ivalue[0] = psfgd->in_EL5002_->invalue1;
    ivalue[1] = psfgd->in_EL5002_->invalue2;

    for(ichan=0;ichan<2;++ichan){
        uint32_t raw - (uint32_t)ivalue[chan];
        
        if (raw & 0x80000000) {
            ivalue[ichan] = int32_t(raw - 0x100000000ULL);
        }

        *y[ichan] = (real_T)ivalue[ichan];
    }

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
