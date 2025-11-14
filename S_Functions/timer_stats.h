/*
 * timer_stats.h
 *
 *  Created on: Dec 15, 2018
 *      Author: robocup
 */

#ifndef TIMER_STATS_H_
#define TIMER_STATS_H_

#define HIST1_RESOLUTION 2 /* in percentage */
#define HIST2_MAX_EXECUTION_TIME 99 /* in samples */

typedef struct tag_timer_stat
{
    unsigned long long icnt;
    unsigned int idelay;
    unsigned int ioverrun;
    double total_time;
    double max_time;
    double dt;
    unsigned int hist1[(100/HIST1_RESOLUTION) * 2]; /* used for execution times between 0 and 200% */
    unsigned int hist2[HIST2_MAX_EXECUTION_TIME]; /* used for execution times larger than 200%, resolution is 1 sample */
    double last_t1;
    double last_execution_time;
} timer_stat_t, *ptimer_stat_t;

void 	init_timer_statistics(ptimer_stat_t stats_struct, double dt, unsigned int npost_pone_samples);
void 	start_timer_statistics(ptimer_stat_t stats_struct);
void 	stop_timer_statistics(ptimer_stat_t stats_struct);
void 	set_global_timer_statistics(ptimer_stat_t stats_struct);
void	rtc_postpone_statistics_calculation(ptimer_stat_t stats_struct, unsigned int nsamples);
int 	print_timer_statistics(ptimer_stat_t stats_struct);
int 	save_timer_statistics(ptimer_stat_t stats_struct, char* filename);
int 	get_timer_result(double* sample_start_time, double* sample_execution_time);
#endif /* TIMER_STATS_H_ */
