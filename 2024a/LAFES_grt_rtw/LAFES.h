/*
 * LAFES.h
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

#ifndef LAFES_h_
#define LAFES_h_
#ifndef LAFES_COMMON_INCLUDES_
#define LAFES_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "simstruc.h"
#include "fixedpoint.h"
#include "rt_logging.h"
#include "dt_info.h"
#include "ext_work.h"
#endif                                 /* LAFES_COMMON_INCLUDES_ */

#include "LAFES_types.h"
#include <stddef.h>
#include "rt_nonfinite.h"
#include "rtGetInf.h"
#include "rtGetNaN.h"
#include <string.h>
#include <float.h>

/* Macros for accessing real-time model data structure */
#ifndef rtmGetContTimeOutputInconsistentWithStateAtMajorStepFlag
#define rtmGetContTimeOutputInconsistentWithStateAtMajorStepFlag(rtm) ((rtm)->CTOutputIncnstWithState)
#endif

#ifndef rtmSetContTimeOutputInconsistentWithStateAtMajorStepFlag
#define rtmSetContTimeOutputInconsistentWithStateAtMajorStepFlag(rtm, val) ((rtm)->CTOutputIncnstWithState = (val))
#endif

#ifndef rtmGetDerivCacheNeedsReset
#define rtmGetDerivCacheNeedsReset(rtm) ((rtm)->derivCacheNeedsReset)
#endif

#ifndef rtmSetDerivCacheNeedsReset
#define rtmSetDerivCacheNeedsReset(rtm, val) ((rtm)->derivCacheNeedsReset = (val))
#endif

#ifndef rtmGetFinalTime
#define rtmGetFinalTime(rtm)           ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetRTWExtModeInfo
#define rtmGetRTWExtModeInfo(rtm)      ((rtm)->extModeInfo)
#endif

#ifndef rtmGetRTWLogInfo
#define rtmGetRTWLogInfo(rtm)          ((rtm)->rtwLogInfo)
#endif

#ifndef rtmGetSampleHitArray
#define rtmGetSampleHitArray(rtm)      ((rtm)->Timing.sampleHitArray)
#endif

#ifndef rtmGetStepSize
#define rtmGetStepSize(rtm)            ((rtm)->Timing.stepSize)
#endif

#ifndef rtmGetZCCacheNeedsReset
#define rtmGetZCCacheNeedsReset(rtm)   ((rtm)->zCCacheNeedsReset)
#endif

#ifndef rtmSetZCCacheNeedsReset
#define rtmSetZCCacheNeedsReset(rtm, val) ((rtm)->zCCacheNeedsReset = (val))
#endif

#ifndef rtmGet_TimeOfLastOutput
#define rtmGet_TimeOfLastOutput(rtm)   ((rtm)->Timing.timeOfLastOutput)
#endif

#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetStopRequested
#define rtmGetStopRequested(rtm)       ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
#define rtmSetStopRequested(rtm, val)  ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
#define rtmGetStopRequestedPtr(rtm)    (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetT
#define rtmGetT(rtm)                   (rtmGetTPtr((rtm))[0])
#endif

#ifndef rtmGetTFinal
#define rtmGetTFinal(rtm)              ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetTPtr
#define rtmGetTPtr(rtm)                ((rtm)->Timing.t)
#endif

#ifndef rtmGetTStart
#define rtmGetTStart(rtm)              ((rtm)->Timing.tStart)
#endif

#ifndef rtmGetTimeOfLastOutput
#define rtmGetTimeOfLastOutput(rtm)    ((rtm)->Timing.timeOfLastOutput)
#endif

/* Block signals (default storage) */
typedef struct {
  real_T SFunction1[2];                /* '<S5>/S-Function1' */
  real_T Switch;                       /* '<S3>/Switch' */
  real_T Derivative;                   /* '<S6>/Derivative' */
  real_T Z_out;                        /* '<S3>/Sum1' */
  real_T X_gen;                        /* '<S8>/Gain' */
  State_Transition_TableModeType State;/* '<S1>/State Transition Table' */
  uint8_T eCAT_okay;                   /* '<S2>/S-Function' */
  boolean_T Constant;                  /* '<S1>/Constant' */
  boolean_T Constant1;                 /* '<S1>/Constant1' */
  boolean_T Constant2;                 /* '<S1>/Constant2' */
} B_LAFES_T;

/* Block states (default storage) for system '<Root>' */
typedef struct {
  real_T TimeStampA;                   /* '<S6>/Derivative' */
  real_T LastUAtTimeA;                 /* '<S6>/Derivative' */
  real_T TimeStampB;                   /* '<S6>/Derivative' */
  real_T LastUAtTimeB;                 /* '<S6>/Derivative' */
  real_T TimeStampA_e;                 /* '<S6>/Derivative1' */
  real_T LastUAtTimeA_c;               /* '<S6>/Derivative1' */
  real_T TimeStampB_l;                 /* '<S6>/Derivative1' */
  real_T LastUAtTimeB_f;               /* '<S6>/Derivative1' */
  real_T SFunction_RWORK[519];         /* '<S2>/S-Function' */
  real_T SFunction1_RWORK[4];          /* '<S5>/S-Function1' */
  real_T SFunction_RWORK_m[4];         /* '<S5>/S-Function' */
  int32_T sfEvent;                     /* '<S1>/State Transition Table' */
  int8_T SignalGenerator_SubsysRanBC;  /* '<S3>/Signal Generator' */
  uint8_T is_active_c4_LAFES;          /* '<S1>/State Transition Table' */
  boolean_T SignalGenerator_MODE;      /* '<S3>/Signal Generator' */
} DW_LAFES_T;

/* Parameters (default storage) */
struct P_LAFES_T_ {
  boolean_T main_switch;               /* Variable: main_switch
                                        * Referenced by: '<S1>/Constant'
                                        */
  boolean_T motor_e_stop;              /* Variable: motor_e_stop
                                        * Referenced by: '<S1>/Constant2'
                                        */
  boolean_T quick_stop;                /* Variable: quick_stop
                                        * Referenced by: '<S1>/Constant1'
                                        */
  boolean_T useGenerator;              /* Variable: useGenerator
                                        * Referenced by: '<S3>/Constant'
                                        */
  real_T Out1_Y0;                      /* Computed Parameter: Out1_Y0
                                        * Referenced by: '<S8>/Out1'
                                        */
  real_T SineWave_Amp;                 /* Expression: 1
                                        * Referenced by: '<S8>/Sine Wave'
                                        */
  real_T SineWave_Bias;                /* Expression: 0
                                        * Referenced by: '<S8>/Sine Wave'
                                        */
  real_T SineWave_Freq;                /* Expression: 1
                                        * Referenced by: '<S8>/Sine Wave'
                                        */
  real_T SineWave_Phase;               /* Expression: 0
                                        * Referenced by: '<S8>/Sine Wave'
                                        */
  real_T Gain_Gain;                    /* Expression: 100
                                        * Referenced by: '<S8>/Gain'
                                        */
  real_T SFunction_P1_Size[2];         /* Computed Parameter: SFunction_P1_Size
                                        * Referenced by: '<S2>/S-Function'
                                        */
  real_T SFunction_P1[4];              /* Computed Parameter: SFunction_P1
                                        * Referenced by: '<S2>/S-Function'
                                        */
  real_T SFunction1_P1_Size[2];        /* Computed Parameter: SFunction1_P1_Size
                                        * Referenced by: '<S5>/S-Function1'
                                        */
  real_T SFunction1_P1;                /* Expression: link_id
                                        * Referenced by: '<S5>/S-Function1'
                                        */
  real_T SFunction1_P2_Size[2];        /* Computed Parameter: SFunction1_P2_Size
                                        * Referenced by: '<S5>/S-Function1'
                                        */
  real_T SFunction1_P2;                /* Expression: operating_mode
                                        * Referenced by: '<S5>/S-Function1'
                                        */
  real_T Gain_Gain_f;                  /* Expression: 0
                                        * Referenced by: '<S6>/Gain'
                                        */
  real_T Gain1_Gain;                   /* Expression: 0
                                        * Referenced by: '<S6>/Gain1'
                                        */
  real_T Gain2_Gain;                   /* Expression: 0
                                        * Referenced by: '<S6>/Gain2'
                                        */
  real_T SFunction_P1_Size_c[2];      /* Computed Parameter: SFunction_P1_Size_c
                                       * Referenced by: '<S5>/S-Function'
                                       */
  real_T SFunction_P1_e;               /* Expression: link_id
                                        * Referenced by: '<S5>/S-Function'
                                        */
};

/* Real-time Model Data Structure */
struct tag_RTM_LAFES_T {
  struct SimStruct_tag * *childSfunctions;
  const char_T *errorStatus;
  SS_SimMode simMode;
  RTWLogInfo *rtwLogInfo;
  RTWExtModeInfo *extModeInfo;
  RTWSolverInfo solverInfo;
  RTWSolverInfo *solverInfoPtr;
  void *sfcnInfo;

  /*
   * NonInlinedSFcns:
   * The following substructure contains information regarding
   * non-inlined s-functions used in the model.
   */
  struct {
    RTWSfcnInfo sfcnInfo;
    time_T *taskTimePtrs[2];
    SimStruct childSFunctions[3];
    SimStruct *childSFunctionPtrs[3];
    struct _ssBlkInfo2 blkInfo2[3];
    struct _ssSFcnModelMethods2 methods2[3];
    struct _ssSFcnModelMethods3 methods3[3];
    struct _ssSFcnModelMethods4 methods4[3];
    struct _ssStatesInfo2 statesInfo2[3];
    ssPeriodicStatesInfo periodicStatesInfo[3];
    struct _ssPortInfo2 inputOutputPortInfo2[3];
    struct {
      time_T sfcnPeriod[1];
      time_T sfcnOffset[1];
      int_T sfcnTsMap[1];
      struct _ssPortOutputs outputPortInfo[1];
      struct _ssOutPortUnit outputPortUnits[1];
      struct _ssOutPortCoSimAttribute outputPortCoSimAttribute[1];
      uint_T attribs[1];
      mxArray *params[1];
      struct _ssDWorkRecord dWork[1];
      struct _ssDWorkAuxRecord dWorkAux[1];
    } Sfcn0;

    struct {
      time_T sfcnPeriod[1];
      time_T sfcnOffset[1];
      int_T sfcnTsMap[1];
      struct _ssPortOutputs outputPortInfo[1];
      struct _ssOutPortUnit outputPortUnits[1];
      struct _ssOutPortCoSimAttribute outputPortCoSimAttribute[1];
      uint_T attribs[2];
      mxArray *params[2];
      struct _ssDWorkRecord dWork[1];
      struct _ssDWorkAuxRecord dWorkAux[1];
    } Sfcn1;

    struct {
      time_T sfcnPeriod[1];
      time_T sfcnOffset[1];
      int_T sfcnTsMap[1];
      struct _ssPortInputs inputPortInfo[1];
      struct _ssInPortUnit inputPortUnits[1];
      struct _ssInPortCoSimAttribute inputPortCoSimAttribute[1];
      real_T const *UPtrs0[2];
      uint_T attribs[1];
      mxArray *params[1];
      struct _ssDWorkRecord dWork[1];
      struct _ssDWorkAuxRecord dWorkAux[1];
    } Sfcn2;
  } NonInlinedSFcns;

  boolean_T zCCacheNeedsReset;
  boolean_T derivCacheNeedsReset;
  boolean_T CTOutputIncnstWithState;

  /*
   * Sizes:
   * The following substructure contains sizes information
   * for many of the model attributes such as inputs, outputs,
   * dwork, sample times, etc.
   */
  struct {
    uint32_T checksums[4];
    uint32_T options;
    int_T numContStates;
    int_T numU;
    int_T numY;
    int_T numSampTimes;
    int_T numBlocks;
    int_T numBlockIO;
    int_T numBlockPrms;
    int_T numDwork;
    int_T numSFcnPrms;
    int_T numSFcns;
    int_T numIports;
    int_T numOports;
    int_T numNonSampZCs;
    int_T sysDirFeedThru;
    int_T rtwGenSfcn;
  } Sizes;

  /*
   * SpecialInfo:
   * The following substructure contains special information
   * related to other components that are dependent on RTW.
   */
  struct {
    const void *mappingInfo;
  } SpecialInfo;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    time_T stepSize;
    uint32_T clockTick0;
    uint32_T clockTickH0;
    time_T stepSize0;
    uint32_T clockTick1;
    uint32_T clockTickH1;
    time_T stepSize1;
    time_T tStart;
    time_T tFinal;
    time_T timeOfLastOutput;
    SimTimeStep simTimeStep;
    boolean_T stopRequestedFlag;
    time_T *sampleTimes;
    time_T *offsetTimes;
    int_T *sampleTimeTaskIDPtr;
    int_T *sampleHits;
    int_T *perTaskSampleHits;
    time_T *t;
    time_T sampleTimesArray[2];
    time_T offsetTimesArray[2];
    int_T sampleTimeTaskIDArray[2];
    int_T sampleHitArray[2];
    int_T perTaskSampleHitsArray[4];
    time_T tArray[2];
  } Timing;
};

/* Block parameters (default storage) */
extern P_LAFES_T LAFES_P;

/* Block signals (default storage) */
extern B_LAFES_T LAFES_B;

/* Block states (default storage) */
extern DW_LAFES_T LAFES_DW;

/* External data declarations for dependent source files */
extern const real_T LAFES_RGND;        /* real_T ground */

/* Model entry point functions */
extern void LAFES_initialize(void);
extern void LAFES_step(void);
extern void LAFES_terminate(void);

/* Real-time Model object */
extern RT_MODEL_LAFES_T *const LAFES_M;

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'LAFES'
 * '<S1>'   : 'LAFES/State Machine'
 * '<S2>'   : 'LAFES/Subsystem'
 * '<S3>'   : 'LAFES/Subsystem Reference'
 * '<S4>'   : 'LAFES/State Machine/State Transition Table'
 * '<S5>'   : 'LAFES/Subsystem Reference/EPOS'
 * '<S6>'   : 'LAFES/Subsystem Reference/FeedForward'
 * '<S7>'   : 'LAFES/Subsystem Reference/Feedback'
 * '<S8>'   : 'LAFES/Subsystem Reference/Signal Generator'
 */
#endif                                 /* LAFES_h_ */
