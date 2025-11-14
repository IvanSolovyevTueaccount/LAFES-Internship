#ifndef TIMER_H
#define TIMER_H

#include "timer_stats.h"

typedef int (*PTIMERCALLBACK) (int,int);

typedef enum{
	FIFO_SCHED,
	DEADLINE_SCHED
}scheduler_type_t;

typedef enum{
	CONTINUOUS_CHECKING,
	ITIMER,
	CONDWAIT_TIMEOUT
}timer_type_t;

typedef struct{
	timer_type_t 		timer_type;
	scheduler_type_t 	sched_type;
	int					priority;
	double				freq;
}timer_config_t,*ptimer_config_t;

int		rtc_timer(PTIMERCALLBACK user_apc, ptimer_config_t ptimer_config, ptimer_stat_t timer_stats_object);

#endif /* TIMER_H */
