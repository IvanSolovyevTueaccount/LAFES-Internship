
/*
  timer_posix.c

  Rene van de Molengraft, June, 2004
  revision history: June, 28th, 2004: start
                    October, 2nd, 2004: added rtc_ prefix to routine names
                    October, 23th, 2005: synchronized original timer to fusion-timer
                    October, 30th, 2005: added frequency check
                    October, 11th, 2007: changed to posix timer
                    June, 5th, 2009: Changed to posix timed wait by Arthur Ketels
                    April, 23rd, 2016: Changed Posix-Timer to MONOTONIC for implementation with Chrony by Wouter Kuijpers
*/

#include <stdio.h>
#include <signal.h>
#include <math.h>
#include <sys/time.h>
#include <time.h>
#include <sched.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sched.h>
#include <string.h>
#include <pthread.h>
#include "scheduler.h"

#include "timer_posix.h"


#define NSEC_PER_SEC 1000000000L
#define USEC_PER_SEC 1000000L
#define USEC_PER_SEC_F 1000000.0
#define NSEC_PER_SEC_F 1000000000.0

double rtc_get_time(void);
void rtc_add_timespec(struct timespec *ts, signed long long addtime);
void set_sched_deadline(unsigned int period_usec);
void set_prio(int priority);

#define TIMING_STATS

#define TIMER_KLOKKIJKEN

double rtc_get_time(void)
{
  struct timespec tva;
  double t;

  clock_gettime(CLOCK_MONOTONIC, &tva);

  t = (double) tva.tv_sec+(double) tva.tv_nsec/NSEC_PER_SEC_F;

  return t;
}

int rtc_signalhandler(PTIMERCALLBACK the_user_apc)
{
    int stop;

    /* call user apc */
    stop = the_user_apc(0,0);

    return stop;
}

/* add ns to timespec */
void rtc_add_timespec(struct timespec *ts, signed long long addtime)
{
	signed long long sec, nsec;
	
	nsec = addtime % NSEC_PER_SEC;
	sec = (addtime - nsec) / NSEC_PER_SEC;
	ts->tv_sec += sec;
	ts->tv_nsec += nsec;
	if ( ts->tv_nsec > NSEC_PER_SEC ) 
	{ 
		nsec = ts->tv_nsec % NSEC_PER_SEC;
		ts->tv_sec += (ts->tv_nsec - nsec) / NSEC_PER_SEC;
		ts->tv_nsec = nsec;
	}	
}

void rtc_rttask_cond_wait_timeout(double dt,PTIMERCALLBACK the_user_apc)
{
	struct timespec ts;
	int stop=0;
	signed long long cycletime_ns;
	pthread_condattr_t      condattr;
	pthread_cond_t      cond  = PTHREAD_COND_INITIALIZER;
    /* This part of the code changes the attribute of the condition for the
     * pthread_cond_timedwait-function ahead. This now makes the Motion,
     * run on the CLOCK_MONOTONIC which is not affected by NTP-software. */

	pthread_condattr_init( &condattr);
	pthread_condattr_setclock( &condattr, CLOCK_MONOTONIC);
	pthread_cond_init( &cond, &condattr);

	pthread_mutex_t     mutex = PTHREAD_MUTEX_INITIALIZER;
	
    /* Depending on the clock chosen, the current time of the clock needs
     * to be obtained from CLOCK_MONOTONIC or CLOCK_REALTIME. */
	clock_gettime(CLOCK_MONOTONIC, &ts); // clock_gettime is stored in <time.h>

    /* Convert from timeval to timespec */
	cycletime_ns = dt * NSEC_PER_SEC; /* cycletime in ns */
	while(!stop)
	{	
		/* calculate next cycle start */
		rtc_add_timespec(&ts, cycletime_ns);
		/* wait to cycle start */
		pthread_cond_timedwait(&cond, &mutex, &ts);
		stop = rtc_signalhandler(the_user_apc);
	}
}

void rtc_rttask_continuous_check(double dt,PTIMERCALLBACK the_user_apc, ptimer_stat_t timer_stats_object)
{
	double lLastTime;
	double lCurrentTime;
	double diff;
	int divisor = 1;
	int stop = 0, ready = 1;

	/* start with initial sleep to start on an OS scheduler's tick boundary */
	usleep(100);
	lLastTime = rtc_get_time();
	while ( !stop )
	{

		while(!ready && !stop){
			lCurrentTime = rtc_get_time();
			diff = lCurrentTime - lLastTime;
			if(diff >= dt){
				ready = 1;
				/* skip samples if more than one sample is missed */
				divisor = diff/dt;
				lLastTime = lLastTime + divisor*dt;
			}
			else{
				/* sleeping too short results in worse performance, this is empirically determined */
				usleep(5);
			}
		}
		if(timer_stats_object == NULL){
			stop = rtc_signalhandler(the_user_apc);
		}else{
			start_timer_statistics(timer_stats_object);
			stop = rtc_signalhandler(the_user_apc);
			stop_timer_statistics(timer_stats_object);
			set_global_timer_statistics(timer_stats_object);
		}
		ready = 0;
	}
}

void rtc_rttask_itimer(double dt,PTIMERCALLBACK the_user_apc, ptimer_stat_t timer_stats_object)
{
	// Block alarm signal, will be waited on explicitly
	sigset_t lAlarm;
	sigemptyset( &lAlarm );
	sigaddset( &lAlarm, SIGALRM  );
	sigprocmask( SIG_BLOCK, &lAlarm, NULL );

	// Set up periodic interrupt timer
	struct itimerval lTimer;
	int lReceivedSignal = 0;

	int Tusec = dt*USEC_PER_SEC;
	lTimer.it_value.tv_sec = 0;
	lTimer.it_value.tv_usec = Tusec;
	lTimer.it_interval = lTimer.it_value;

	// Start timer
	if ( setitimer( ITIMER_REAL, &lTimer, NULL ) != 0 )
	{
		printf("Could not start interval timer\n" );
		return;
	}

	int stop = 0;
	while ( !stop )
	{
		//Periodic wait
		if ( sigwait( &lAlarm, &lReceivedSignal ) != 0 )
		{
			printf("Failed to wait for next clock tick\n" );
			return;
		}
		if(timer_stats_object == NULL){
			stop = rtc_signalhandler(the_user_apc);
		}else{
			start_timer_statistics(timer_stats_object);
			stop = rtc_signalhandler(the_user_apc);
			stop_timer_statistics(timer_stats_object);
			set_global_timer_statistics(timer_stats_object);
		}
	}
}

int rtc_timer(PTIMERCALLBACK user_apc, ptimer_config_t ptimer_config, ptimer_stat_t timer_stats_object)
{
	if(ptimer_config == NULL){
		printf("ERROR: Invalid timer config pointer\n");
		return -1;
	}

	/* check input timer frequency */
	if (ptimer_config->freq <= 0.0) {
		printf("rtc_timer (posix) reports: invalid timer frequency : %f.\n",ptimer_config->freq);
		return -1;
	}

	double dt = 1.0/ptimer_config->freq;

	switch(ptimer_config->sched_type){
		case DEADLINE_SCHED:
			set_sched_deadline(dt*USEC_PER_SEC);
			break;
		default:
			set_prio(ptimer_config->priority);
			break;

	}
	printf("rtc_timer (posix) running at %f Hz.\n", ptimer_config->freq);

	switch(ptimer_config->timer_type){
		case CONTINUOUS_CHECKING:
			rtc_rttask_continuous_check(dt, user_apc, timer_stats_object);
			break;
		case CONDWAIT_TIMEOUT:
			rtc_rttask_cond_wait_timeout(dt, user_apc);
			break;
		case ITIMER:
			rtc_rttask_itimer(dt, user_apc, timer_stats_object);
			break;
		default:
			rtc_rttask_continuous_check(dt, user_apc, timer_stats_object);
			break;
	}

	printf("rtc_timer (posix) has been stopped.\n");

	return 0;
}

void set_prio(int priority)
{
	struct sched_param schp;
	int prio_min, prio_max;

	mlockall(MCL_CURRENT|MCL_FUTURE);

	/* set priority */
	prio_min = sched_get_priority_min(SCHED_FIFO);
	prio_max = sched_get_priority_max(SCHED_FIFO);

	if( ( priority >= prio_min ) & ( priority <= prio_max ) ) {
		memset(&schp, 0, sizeof(schp));
		schp.sched_priority = priority;

		if(sched_setscheduler(0, SCHED_FIFO, &schp) != 0) {
			printf("rtc_timer reports: error sched_setscheduler");
			usleep(2000000);
		}
		printf("rtc_timer reports: SCHED_FIFO priority set to %d.\n", priority);
	}
	/* ignore SIGALRM */

	signal(SIGALRM, SIG_IGN);
}

void set_sched_deadline(unsigned int period_usec)
{
	mlockall(MCL_CURRENT|MCL_FUTURE);


	struct sched_attr attr;
	unsigned int flags = 0;

	attr.size = sizeof(attr);
	attr.sched_flags = 0;
	attr.sched_nice = -10;
	attr.sched_priority = 0;

	attr.sched_policy = SCHED_DEADLINE;
	attr.sched_runtime = 0.9 * period_usec * 1000;
	attr.sched_period  = period_usec * 1000;
	attr.sched_deadline= period_usec * 1000;

	sched_setattr(0, &attr, flags);
}
