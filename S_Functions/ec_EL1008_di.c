/*
        ec_EL1008_di

        (c) Rene' van de Molengraft, 2007
		(c) Ferry Schoenmakers, 2019

        Outputs: y[0] - y[3]  = di channels 0 - 3

        Parameter: link id
*/

#define S_FUNCTION_NAME ec_EL1008_di
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NSTATES         0
#define NINPUTS         0
#define NOUTPUTS        8
#define NPARAMS         1

#define LINK_ID         ssGetSFcnParam(S,0)

#include <math.h>
#include "ethercat.h"

#ifndef MATLAB_MEX_FILE
static int bitmask[8] = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80}; /* bit masks voor digital I/O */
#endif /* MATLAB_MEX_FILE */

typedef struct PACKED
{
	uint8_t	   inbits;
} in_EL1008t;

/* define global data struct */
typedef struct tag_sfun_global_data {
	int ilink;
	in_EL1008t *in_EL1008_;
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
	int nEL1008 = 0;
	for (cnt = 1; cnt <= ec_slavecount; cnt++)
	{
		if (ec_slave[cnt].eep_id == 0x03f03052)
		{
			nEL1008++;
			if (nEL1008 == psfgd->ilink){
				psfgd->in_EL1008_ = (in_EL1008t*) ec_slave[cnt].inputs;
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

    int_T ichan, ivalue;

	/* read di channels */
    for (ichan = psfgd->startbit; ichan < (NOUTPUTS + psfgd->startbit); ++ichan)
	{
		ivalue = (psfgd->in_EL1008_->inbits & bitmask[ichan]) >> ichan;
		y[ichan] = (double) ivalue;
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
