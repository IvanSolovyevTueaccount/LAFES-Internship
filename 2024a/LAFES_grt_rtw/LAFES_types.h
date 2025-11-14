/*
 * LAFES_types.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "LAFES".
 *
 * Model version              : 1.9
 * Simulink Coder version : 24.1 (R2024a) 19-Nov-2023
 * C source code generated on : Fri Nov 14 12:36:52 2025
 *
 * Target selection: mttarget.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Linux 64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef LAFES_types_h_
#define LAFES_types_h_
#include "rtwtypes.h"
#ifndef DEFINED_TYPEDEF_FOR_State_Transition_TableModeType_
#define DEFINED_TYPEDEF_FOR_State_Transition_TableModeType_

typedef enum {
  State_Transition_TableModeType_Stopped = 0,
  State_Transition_TableModeType_Quick_Stopping,
  State_Transition_TableModeType_Running,
  State_Transition_TableModeType_Idle,
  State_Transition_TableModeType_None  /* Default value */
} State_Transition_TableModeType;

#endif

#ifndef SS_UINT64
#define SS_UINT64                      20
#endif

#ifndef SS_INT64
#define SS_INT64                       21
#endif

/* Parameters (default storage) */
typedef struct P_LAFES_T_ P_LAFES_T;

/* Forward declaration for rtModel */
typedef struct tag_RTM_LAFES_T RT_MODEL_LAFES_T;

#endif                                 /* LAFES_types_h_ */
