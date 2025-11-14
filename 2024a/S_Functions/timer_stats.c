/*
 * timer_stats.c
 *
 *  Created on: Dec 15, 2018
 *      Author: robocup
 */
#include <stdio.h>
#include <math.h>
#include <string.h>

#include "timer_stats.h"

static double last_start_time=-1;
static double last_execution_time=0;

void add_to_timer_statistics(ptimer_stat_t stats_struct, double diff);
double rtc_get_time(void);

void init_timer_statistics(ptimer_stat_t stats_struct, double dt, unsigned int npost_pone_samples)
{
	memset(stats_struct,0,sizeof(timer_stat_t));
	/* set the possibly set postpone */
	stats_struct->idelay = npost_pone_samples;
	/* store the sample time */
	stats_struct->dt = dt;
	return;
}

void start_timer_statistics(ptimer_stat_t stats_struct)
{
	stats_struct->last_t1 = rtc_get_time();
}

void stop_timer_statistics(ptimer_stat_t stats_struct)
{
	stats_struct->last_execution_time = rtc_get_time() - stats_struct->last_t1;
	add_to_timer_statistics(stats_struct, stats_struct->last_execution_time);
}

void set_global_timer_statistics(ptimer_stat_t stats_struct)
{
	last_start_time = stats_struct->last_t1;
	last_execution_time = stats_struct->last_execution_time;
}
int get_timer_result(double* sample_start_time, double* sample_execution_time)
{
	if(last_start_time < 0){
		*sample_start_time = 0;
		*sample_execution_time = 0;
		return 0;
	}else{
		*sample_start_time = last_start_time;
		*sample_execution_time = last_execution_time;
	}
	return 1;
}
int print_timer_statistics(ptimer_stat_t stats_struct)
{
	unsigned long long nsamples = stats_struct->icnt - stats_struct->idelay;

	if( stats_struct->icnt <= stats_struct->idelay ){
		printf("No statistics available\n");
		return 0;
	}
	double avg_time = stats_struct->total_time/nsamples;

	if(stats_struct->idelay > 0){
		printf("The statistics calculations started %.1f [s] after initialization.\n",stats_struct->idelay*stats_struct->dt);
	}

	printf("Average execution time :\t%.3e [s] (%.1f%% of sample time)\n",avg_time,avg_time/stats_struct->dt*100.0);
	printf("Maximum execution time :\t%.3e [s] (%.1f%% of sample time)\n",stats_struct->max_time,stats_struct->max_time/stats_struct->dt*100.0);
	printf("Number of sample overruns :\t%d (out of %lld)\n",stats_struct->ioverrun,nsamples);


    return 0;
}

int save_timer_statistics(ptimer_stat_t stats_struct, char* filename)
{
	int i;
	FILE* fp=NULL;
	unsigned long long nsamples = stats_struct->icnt - stats_struct->idelay;

	if( stats_struct->icnt <= stats_struct->idelay ){
		printf("No statistics available\n");
		return 0;
	}
	fp = fopen (filename, "w");

	if(fp == NULL){
		printf("rtc_save_timer_statistics could not open logfile to write statistics\n");
		return 0;
	}

	double avg_time = stats_struct->total_time/nsamples;

	fprintf(fp,"Delay time:\t%d\nSample time:\t%.3e\nHIST1_RES:\t%d\nHIST2_MAX:\t%d\nNSAMPLES:\t%lld\nAVG_EXE_TIME:\t%.3e\nMAX_EXE_TIME:\t%.3e\nNOVERRUNS:\t%d\n",
			stats_struct->idelay,stats_struct->dt,HIST1_RESOLUTION,HIST2_MAX_EXECUTION_TIME,nsamples,avg_time,stats_struct->max_time,stats_struct->ioverrun);

	for(i=0;i<(100/HIST1_RESOLUTION)*2;i++){
		fprintf(fp,"%d\t[%d - %d%%]\t%d\t(%.1f%%)\n",HIST1_RESOLUTION*(2*i+1)/2
										,HIST1_RESOLUTION*i,HIST1_RESOLUTION*(i+1),stats_struct->hist1[i]
				                        ,((double)stats_struct->hist1[i]*100.0)/nsamples);
	}

	for(i=0;i<HIST2_MAX_EXECUTION_TIME-1;i++){
		fprintf(fp,"%d\t[%d - %d%%]\t%d\t(%.1f%%)\n",(2*i+5)*100/2,(i+2)*100,(i+3)*100,stats_struct->hist2[i]
				                        ,((double)stats_struct->hist2[i]*100.0)/nsamples);
	}
	i = HIST2_MAX_EXECUTION_TIME-1;
	fprintf(fp,"# [>%d%%] %d (%.1f%%)\n",(i+2)*100,stats_struct->hist2[i]
			                        ,((double)stats_struct->hist2[i]*100.0)/nsamples);

	fprintf(fp,"# Average execution time :\t%.3e [s] (%.1f%% of sample time)\n",avg_time,avg_time/stats_struct->dt*100.0);
	fprintf(fp,"# Maximum execution time :\t%.3e [s] (%.1f%% of sample time)\n",stats_struct->max_time,stats_struct->max_time/stats_struct->dt*100.0);
	fprintf(fp,"# Number of sample overruns :\t%d (out of %lld)\n",stats_struct->ioverrun,nsamples);
	fclose(fp);
    return 0;
}

void add_to_timer_statistics(ptimer_stat_t stats_struct, double diff)
{
	int idx;
	stats_struct->icnt++;

	if(stats_struct->icnt < stats_struct->idelay){
		/* start saving stats after idelay samples */
		return;
	}
	/* check for sample overrun */
    if(diff > stats_struct->dt){
    	stats_struct->ioverrun++;
    }
    /* check if it exceeds the maximum execution time */
    if(diff > stats_struct->max_time){
    	stats_struct->max_time = diff;
    }
    stats_struct->total_time += diff;
    /* add the timing to the histogram */
    if(diff > 2*stats_struct->dt){
    	/* put in hist2, resolution of histogram is 1 sample */
    	idx = round(diff/stats_struct->dt)-2; /* -2 because first two seconds are covered by hist1 */
    	if(idx>HIST2_MAX_EXECUTION_TIME-1){
    		idx = HIST2_MAX_EXECUTION_TIME-1;
    	}else if(idx <= 0){
    		idx = 0;
    	}
    	stats_struct->hist2[idx]++;
    }else{
    	/* put in hist1 */
    	idx = round((100.0/HIST1_RESOLUTION)*(diff/stats_struct->dt));
    	if(idx>((100/HIST1_RESOLUTION) * 2)-1){
    		idx = ((100/HIST1_RESOLUTION) * 2)-1;
    	}else if(idx <= 0){
    		idx = 0;
    	}
    	stats_struct->hist1[idx]++;
    }
}

