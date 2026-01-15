/*
    ec_EtherCAT_interface

    This interface module organizes EtherCAT frames with SOEM
    The S-function outputs an 'eCAT_okay'-flag.
    Furthermore it starts a separate thread to monitor the EtherCAT network
    and tries to solve problems when detected. Whenever problems are detected, the
    'eCAT_okay'-flag is low until they are resolved.

    (c) Ferry Schoenmakers, 2019
*/

#define S_FUNCTION_NAME ec_EtherCAT_interface
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NSTATES         0
#define NPARAMS         1

/***************************
 * Input Ports definitions *
 ***************************/
#define NINPUTS     0                                  /* Number of input ports (0...) */

/****************************
 * Output Ports definitions *
 ****************************/
#define NOUTPUTS    1                                   /* Number of output ports (0...) */
#define NOUTPUTS0   1                                   /* EtherCAT OKAY state */

#include "ec_EtherCAT_interface.h"

/* Internal function prototypes */
#ifndef MATLAB_MEX_FILE
static int ec_initial(psfun_global_data psfgd);
static void ec_start(psfun_global_data psfgd);
#endif /* MATLAB_MEX_FILE */

/*====================*
 *  EtherCAT methods  *
 *====================*/
#ifndef MATLAB_MEX_FILE
/* Setup EtherCAT network, find and identify connected slaves */
static int ec_initial(psfun_global_data psfgd)
{
    int cnt;
    psfgd->inOP = FALSE;;
    printf("Starting initialization\n");
    /* initialise SOEM, bind socket to ifname */
    if (ec_init(psfgd->netif))
    {     
        printf("Master socket bind on %s succeeded.\n",psfgd->netif);
        /* find and auto-config slaves without IOmap*/
        if ( ec_config_init(FALSE) > 0 )
        {
            printf("%d slaves found and configured.\n",ec_slavecount);
            ec_config_map(&psfgd->IOmap);
            ec_configdc();
            printf("Slaves mapped, state to SAFE_OP.\n");
            /* wait for all slaves to reach SAFE_OP state */
            ec_statecheck(0, EC_STATE_SAFE_OP,  EC_TIMEOUTSTATE * 4);
            /* read indevidual slave state and store in ec_slave[] */
            ec_readstate();
            psfgd->expectedWKC = (ec_group[0].outputsWKC * 2) + ec_group[0].inputsWKC;
            printf("Calculated workcounter %d\n", psfgd->expectedWKC);
            /* Print all slaves found */
            for(cnt = 1; cnt <= ec_slavecount ; cnt++)
            {
                printf("Slave:%d Name:%s Output size:%3dbits Input size:%3dbits State:%2d\n",
                        cnt, ec_slave[cnt].name, ec_slave[cnt].Obits, ec_slave[cnt].Ibits, ec_slave[cnt].state);
                /* Initialize failed counter to 0 */
                ec_slave[cnt].toOPFailCntr = 0;
            }
        }
        else
        {
            printf("No EtherCAT slaves found. Are slaves connected to %s port?\n",psfgd->netif);
            return -1;
        }
    }
    else
    {
        printf("Master socket bind on %s NOT succeeded.\n",psfgd->netif);
        return -1;
    }
    return 0;
}
/* Switch EtherCAT network to Operational state */
static void ec_start(psfun_global_data psfgd)
{
    ec_slave[0].state = EC_STATE_OPERATIONAL;
    /* send one valid process data to make outputs in slaves happy*/
    ec_send_processdata();
    ec_receive_processdata(EC_TIMEOUTRET);
    /* request OP state for all slaves */
    ec_writestate(0);
    int chk = 40;
    /* wait for all slaves to reach OP state */
    do
    {
        ec_send_processdata();
        ec_receive_processdata(EC_TIMEOUTRET);
        ec_statecheck(0, EC_STATE_OPERATIONAL, 50000);
    }
    while (chk-- && (ec_slave[0].state != EC_STATE_OPERATIONAL));
    if (ec_slave[0].state == EC_STATE_OPERATIONAL)
    {
        printf("Operational state reached for all slaves.\n");
        psfgd->inOP = TRUE;
    }
    else
    {
        printf("Not all slaves reached operational state.\n");
        ec_readstate();
        int cnt;
        for (cnt = 1; cnt <= ec_slavecount; cnt++)
        {
            if (ec_slave[cnt].state != EC_STATE_OPERATIONAL)
            {
                printf("Slave %d State=0x%2.2x StatusCode=0x%4.4x : %s\n", cnt, ec_slave[cnt].state, ec_slave[cnt].ALstatuscode,
                        ec_ALstatuscode2string(ec_slave[cnt].ALstatuscode));
            }
        }
    }
}
/* Check sates of ALL slaves, template function to run in separate thread! */
void* ec_check_states(psfun_global_data psfgd)
{
    int slave;
    boolean needlf;
    uint8 currentgroup = 0;

    while(1)
    {
        if( psfgd->inOP && ((psfgd->wkc < psfgd->expectedWKC) || ec_group[currentgroup].docheckstate))
        {
            psfgd->eCAT_okay = FALSE;
            if (needlf)
            {
                needlf = FALSE;
                printf("\n");
            }
            /* one ore more slaves are not responding */
            ec_group[currentgroup].docheckstate = FALSE;
            ec_readstate();
            for (slave = 1; slave <= ec_slavecount; slave++)
            {
                if ((ec_slave[slave].group == currentgroup) && (ec_slave[slave].state != EC_STATE_OPERATIONAL))
                {
                    ec_group[currentgroup].docheckstate = TRUE;
                    if (ec_slave[slave].state == (EC_STATE_SAFE_OP + EC_STATE_ERROR))
                    {
                        if(ec_slave[slave].toOPFailCntr<5){
                            printf("ERROR : slave %d is in SAFE_OP + ERROR, attempting ack.\n", slave);
                            ec_slave[slave].state = (EC_STATE_SAFE_OP + EC_STATE_ACK);
                            ec_slave[slave].toOPFailCntr++;
                        }else{
                            printf("ERROR : slave %d is still in SAFE_OP + ERROR, attempting re-init.\n", slave);
                            ec_slave[slave].state = (EC_STATE_INIT);
                        }
                        ec_writestate(slave);
                    }
                    else if(ec_slave[slave].state == EC_STATE_SAFE_OP)
                    {
                        printf("WARNING : slave %d is in SAFE_OP, change to OPERATIONAL.\n", slave);
                        ec_slave[slave].state = EC_STATE_OPERATIONAL;
                        ec_writestate(slave);
                    }
                    else if(ec_slave[slave].state > EC_STATE_NONE)
                    {
                        if (ec_reconfig_slave(slave, EC_TIMEOUTMON))
                        {
                            ec_slave[slave].islost = FALSE;
                            printf("MESSAGE : slave %d reconfigured\n",slave);
                        }
                    }
                    else if(!ec_slave[slave].islost)
                    {
                        /* re-check state */
                        ec_statecheck(slave, EC_STATE_OPERATIONAL, EC_TIMEOUTRET);
                        if (ec_slave[slave].state == EC_STATE_NONE)
                        {
                            ec_slave[slave].islost = TRUE;
                            printf("ERROR : slave %d lost\n",slave);
                        }
                    }
                }
                if (ec_slave[slave].islost)
                {
                    if(ec_slave[slave].state == EC_STATE_NONE)
                    {
                        if (ec_recover_slave(slave, EC_TIMEOUTMON))
                        {
                            ec_slave[slave].islost = FALSE;
                            ec_slave[slave].toOPFailCntr = 0;
                            printf("MESSAGE : slave %d recovered\n",slave);
                        }
                    }
                    else
                    {
                        ec_slave[slave].islost = FALSE;
                        ec_slave[slave].toOPFailCntr = 0;
                        printf("MESSAGE : slave %d found\n",slave);
                    }
                }
            }
            if(!ec_group[currentgroup].docheckstate){
                printf("OK : all slaves resumed OPERATIONAL.\n");
                psfgd->eCAT_okay = TRUE;
            }
        }else{
            psfgd->eCAT_okay = TRUE;
        }
        osal_usleep(STATECHECK_PERIOD_US);
    }
}
#endif /* MATLAB_MEX_FILE */

/*====================*
 * S-function methods *
 *====================*/
static void mdlInitializeSizes(SimStruct *S)
{
    int Rworksize;
    
    ssSetNumSFcnParams(S, NPARAMS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return;
    }

    ssSetNumContStates(S,0);
    ssSetNumDiscStates(S,0);

    if (!ssSetNumInputPorts(S,NINPUTS)) return;

    if (!ssSetNumOutputPorts(S,NOUTPUTS)) return;
    ssSetOutputPortWidth(S,0,NOUTPUTS0);
    ssSetOutputPortDataType(S,0,SS_UINT8);

    ssSetNumSampleTimes(S,1);
    /* Define this block to be executed first in a model */
    ssSetOptions(S, SS_OPTION_PLACE_ASAP);

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
    ssSetSampleTime(S,0,CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}
/*************************************************************************/

#define MDL_START
void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    /* get pointers to global data */
    double* ptrRwrk = ssGetRWork(S);
    psfun_global_data psfgd;
    psfgd = (psfun_global_data) ptrRwrk;

    psfgd->eCAT_okay = FALSE;
    psfgd->inOP = FALSE;
    psfgd->first_time = 1;

    /* set network interface name */
    mxGetString(ssGetSFcnParam(S, 0), psfgd->netif, sizeof(psfgd->netif) / sizeof(psfgd->netif[0]));
    printf("Net interface = %s.\n", psfgd->netif);

    /* create thread to handle slave error handling in OP */
    printf("Starting statecheck thread\n");
    pthread_attr_t  attr;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, 128000);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    if (pthread_create(&(psfgd->check_thread), &attr, DEC ec_check_states, psfgd)) {
       printf("ERROR: ec_EtherCAT_interface cannot create thread.");
       exit(1);
    }

    if (ec_initial(psfgd) != 0){
    	printf("Initialization failed\n");
    	exit(EXIT_FAILURE);
    }
#endif
}
/*************************************************************************/

static void mdlOutputs(SimStruct *S, int_T tid)
{
    /* get pointers to global data */
    double* ptrRwrk = ssGetRWork(S);
    psfun_global_data psfgd;
    psfgd = (psfun_global_data) ptrRwrk;

#ifndef MATLAB_MEX_FILE
    /* On first time start EtherCAT PDOs */
    if (psfgd->first_time) {
        ec_start(psfgd);
        psfgd->first_time = 0;
    }

    /* perform I/O first to obtain measurement inputs */
    ec_send_processdata();
    psfgd->wkc = ec_receive_processdata(EC_TIMEOUTMON);
#endif

    /* output current EtherCAT network state */
    uint8_t *eCAT_Okay_state = (uint8_t*) ssGetOutputPortRealSignal(S,0);
    *eCAT_Okay_state = psfgd->eCAT_okay;
}
/*************************************************************************/

#define MDL_UPDATE
#if defined(MDL_UPDATE)
static void mdlUpdate(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
#ifdef IAM8WHEELED
    /* get pointers to global data */
    double* ptrRwrk = ssGetRWork(S);
    psfun_global_data psfgd;
    psfgd = (psfun_global_data) ptrRwrk;

    /* perform I/O again to send control commands, but don't wait for the telegram to return
        since we don't care about this returned data.
        Next timestep we will first get the latest data again in mdlOutputs() */
    ec_send_processdata();
    psfgd->wkc = ec_receive_processdata(0);
#endif
#endif
}
#endif /* MDL_UPDATE */
/*************************************************************************/

#define MDL_CLEANUP_RUNTIME_RESOURCES
static void mdlCleanupRuntimeResources(SimStruct *S)
{
    /* get pointers to global data */
    double* ptrRwrk = ssGetRWork(S);
    psfun_global_data psfgd;
    psfgd = (psfun_global_data) ptrRwrk;

    psfgd->inOP = FALSE;

#ifndef MATLAB_MEX_FILE    
    /* On terminate make sure to send latest PDO's */
    ec_send_processdata();
    ec_receive_processdata(EC_TIMEOUTMON);
    
    printf("Request safe operational state for all slaves\n");
    ec_slave[0].state = EC_STATE_SAFE_OP;
    /* request SAFE_OP state for all slaves */
    ec_writestate(0);
    
    printf("End SOEM, close socket\n");
    /* stop SOEM, close socket */
    ec_close();

    pthread_cancel(psfgd->check_thread);
#endif
}
/*************************************************************************/

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    /* On terminate make sure to send latest PDO's */
    ec_send_processdata();
    ec_receive_processdata(EC_TIMEOUTMON);
#endif
}
/*************************************************************************/
#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
