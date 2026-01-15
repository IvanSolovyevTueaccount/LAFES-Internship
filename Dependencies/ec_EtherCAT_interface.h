/*
    ec_EK1100_interface

    This interface module organizes EtherCAT frames with SOEM
    The S-function outputs an 'eCAT_okay'-flag.
    Furthermore it starts a separate thread to monitor the EtherCAT network
    and tries to solve problems when detected. Whenever problems are detected, the
    'eCAT_okay'-flag is low until they are resolved.

    (c) Ferry Schoenmakers, 2019
*/

#ifndef EK1100_INTERFACE_H_
#define EK1100_INTERFACE_H_

#include "ethercat.h"

#ifndef DEC
#define DEC                 ( void* (*)(void*) )
#endif

#define EC_TIMEOUTMON 500
#define STATECHECK_PERIOD_US 100000

/* define global data struct */
typedef struct tag_sfun_global_data {
    char netif[10];             /* Char array to store network interface name */
    char IOmap[4096];           /* EtherCAT I/O buffer */
    int expectedWKC;            /* To store expected work counter */
    boolean eCAT_okay;          /* Flag that indicates condition of EtherCAT network */
    volatile int wkc;           /* To store workcounter of current frame */
    boolean inOP;               /* Store flag to indicate ec_state == EC_STATE_OPERATIONAL */
    pthread_t check_thread;     /* Pointer to ec_check_states thread */
    boolean first_time;         /* Flag to indicate first run */
} sfun_global_data, *psfun_global_data;

/* function declarations */
void* ec_check_states(psfun_global_data psfgd);

#endif /* EK1100_INTERFACE_H_ */
