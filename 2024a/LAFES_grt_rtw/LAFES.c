/*
 * LAFES.c
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

#include "LAFES.h"
#include "rtwtypes.h"
#include "LAFES_types.h"
#include <math.h>
#include "rt_nonfinite.h"
#include "LAFES_private.h"
#include <string.h>
#include "LAFES_dt.h"

/* Named constants for State Transition Table: '<S1>/State Transition Table' */
#define LAFES_CALL_EVENT               (-1)

const real_T LAFES_RGND = 0.0;         /* real_T ground */

/* Block signals (default storage) */
B_LAFES_T LAFES_B;

/* Block states (default storage) */
DW_LAFES_T LAFES_DW;

/* Real-time model */
static RT_MODEL_LAFES_T LAFES_M_;
RT_MODEL_LAFES_T *const LAFES_M = &LAFES_M_;

/* Model step function */
void LAFES_step(void)
{
  {
    real_T lastTime;
    real_T rtb_e;
    real_T *lastU;

    /* Reset subsysRan breadcrumbs */
    srClearBC(LAFES_DW.SignalGenerator_SubsysRanBC);

    /* S-Function (ec_EtherCAT_interface): '<S2>/S-Function' */

    /* Level2 S-Function Block: '<S2>/S-Function' (ec_EtherCAT_interface) */
    {
      SimStruct *rts = LAFES_M->childSfunctions[0];
      sfcnOutputs(rts,0);
    }

    /* S-Function (ec_EPOS4_i): '<S5>/S-Function1' */

    /* Level2 S-Function Block: '<S5>/S-Function1' (ec_EPOS4_i) */
    {
      SimStruct *rts = LAFES_M->childSfunctions[1];
      sfcnOutputs(rts,0);
    }

    /* Outputs for Enabled SubSystem: '<S3>/Signal Generator' incorporates:
     *  EnablePort: '<S8>/Enable'
     */
    /* Constant: '<S3>/Constant' */
    LAFES_DW.SignalGenerator_MODE = LAFES_P.useGenerator;
    if (LAFES_DW.SignalGenerator_MODE) {
      /* Gain: '<S8>/Gain' incorporates:
       *  Sin: '<S8>/Sine Wave'
       */
      LAFES_B.X_gen = (sin(LAFES_P.SineWave_Freq * LAFES_M->Timing.t[0] +
                           LAFES_P.SineWave_Phase) * LAFES_P.SineWave_Amp +
                       LAFES_P.SineWave_Bias) * LAFES_P.Gain_Gain;
      srUpdateBC(LAFES_DW.SignalGenerator_SubsysRanBC);
    }

    /* End of Outputs for SubSystem: '<S3>/Signal Generator' */

    /* Switch: '<S3>/Switch' incorporates:
     *  Constant: '<S3>/Constant'
     */
    if (LAFES_P.useGenerator) {
      /* Switch: '<S3>/Switch' */
      LAFES_B.Switch = LAFES_B.X_gen;
    } else {
      /* Switch: '<S3>/Switch' */
      LAFES_B.Switch = 0.0;
    }

    /* End of Switch: '<S3>/Switch' */

    /* Derivative: '<S6>/Derivative' incorporates:
     *  Derivative: '<S6>/Derivative1'
     */
    rtb_e = LAFES_M->Timing.t[0];
    if ((LAFES_DW.TimeStampA >= rtb_e) && (LAFES_DW.TimeStampB >= rtb_e)) {
      /* Derivative: '<S6>/Derivative' */
      LAFES_B.Derivative = 0.0;
    } else {
      lastTime = LAFES_DW.TimeStampA;
      lastU = &LAFES_DW.LastUAtTimeA;
      if (LAFES_DW.TimeStampA < LAFES_DW.TimeStampB) {
        if (LAFES_DW.TimeStampB < rtb_e) {
          lastTime = LAFES_DW.TimeStampB;
          lastU = &LAFES_DW.LastUAtTimeB;
        }
      } else if (LAFES_DW.TimeStampA >= rtb_e) {
        lastTime = LAFES_DW.TimeStampB;
        lastU = &LAFES_DW.LastUAtTimeB;
      }

      /* Derivative: '<S6>/Derivative' */
      LAFES_B.Derivative = (LAFES_B.Switch - *lastU) / (rtb_e - lastTime);
    }

    /* End of Derivative: '<S6>/Derivative' */

    /* Derivative: '<S6>/Derivative1' */
    if ((LAFES_DW.TimeStampA_e >= rtb_e) && (LAFES_DW.TimeStampB_l >= rtb_e)) {
      rtb_e = 0.0;
    } else {
      lastTime = LAFES_DW.TimeStampA_e;
      lastU = &LAFES_DW.LastUAtTimeA_c;
      if (LAFES_DW.TimeStampA_e < LAFES_DW.TimeStampB_l) {
        if (LAFES_DW.TimeStampB_l < rtb_e) {
          lastTime = LAFES_DW.TimeStampB_l;
          lastU = &LAFES_DW.LastUAtTimeB_f;
        }
      } else if (LAFES_DW.TimeStampA_e >= rtb_e) {
        lastTime = LAFES_DW.TimeStampB_l;
        lastU = &LAFES_DW.LastUAtTimeB_f;
      }

      rtb_e = (LAFES_B.Derivative - *lastU) / (rtb_e - lastTime);
    }

    /* Signum: '<S6>/Sign' */
    if (rtIsNaN(LAFES_B.Derivative)) {
      lastTime = (rtNaN);
    } else if (LAFES_B.Derivative < 0.0) {
      lastTime = -1.0;
    } else {
      lastTime = (LAFES_B.Derivative > 0.0);
    }

    /* Sum: '<S3>/Sum1' incorporates:
     *  Gain: '<S6>/Gain'
     *  Gain: '<S6>/Gain1'
     *  Gain: '<S6>/Gain2'
     *  Signum: '<S6>/Sign'
     *  Sum: '<S3>/Sum'
     *  Sum: '<S6>/Sum'
     */
    LAFES_B.Z_out = ((LAFES_P.Gain_Gain_f * lastTime + LAFES_P.Gain1_Gain *
                      LAFES_B.Derivative) + LAFES_P.Gain2_Gain * rtb_e) +
      LAFES_B.Switch;

    /* S-Function (ec_EPOS4_o): '<S5>/S-Function' */

    /* Level2 S-Function Block: '<S5>/S-Function' (ec_EPOS4_o) */
    {
      SimStruct *rts = LAFES_M->childSfunctions[2];
      sfcnOutputs(rts,0);
    }

    /* Constant: '<S1>/Constant' */
    LAFES_B.Constant = LAFES_P.main_switch;

    /* Constant: '<S1>/Constant1' */
    LAFES_B.Constant1 = LAFES_P.quick_stop;

    /* Constant: '<S1>/Constant2' */
    LAFES_B.Constant2 = LAFES_P.motor_e_stop;

    /* State Transition Table: '<S1>/State Transition Table' */
    /* Gateway: State Machine/State Transition Table */
    LAFES_DW.sfEvent = LAFES_CALL_EVENT;

    /* During: State Machine/State Transition Table */
    if (LAFES_DW.is_active_c4_LAFES == 0U) {
      /* Entry: State Machine/State Transition Table */
      LAFES_DW.is_active_c4_LAFES = 1U;

      /* Entry Internal: State Machine/State Transition Table */
      /* Transition: '<S4>:15' */
      LAFES_B.State = State_Transition_TableModeType_Idle;
    } else {
      switch (LAFES_B.State) {
       case State_Transition_TableModeType_Idle:
        /* During 'Idle': '<S4>:13' */
        if (LAFES_B.Constant) {
          /* Transition: '<S4>:16' */
          LAFES_B.State = State_Transition_TableModeType_Running;

          /* Entry 'Running': '<S4>:14' */
        }
        break;

       case State_Transition_TableModeType_Quick_Stopping:
        /* During 'Quick_Stopping': '<S4>:22' */
        if (!LAFES_B.Constant) {
          /* Transition: '<S4>:51' */
          LAFES_B.State = State_Transition_TableModeType_Idle;
        } else if (!LAFES_B.Constant1) {
          /* Transition: '<S4>:27' */
          LAFES_B.State = State_Transition_TableModeType_Running;

          /* Entry 'Running': '<S4>:14' */
        }
        break;

       case State_Transition_TableModeType_Running:
        /* During 'Running': '<S4>:14' */
        if (!LAFES_B.Constant) {
          /* Transition: '<S4>:50' */
          LAFES_B.State = State_Transition_TableModeType_Idle;
        } else if (LAFES_B.Constant1) {
          /* Transition: '<S4>:23' */
          LAFES_B.State = State_Transition_TableModeType_Quick_Stopping;
        } else if (LAFES_B.Constant2) {
          /* Transition: '<S4>:34' */
          LAFES_B.State = State_Transition_TableModeType_Stopped;
        }
        break;

       default:
        /* During 'Stopped': '<S4>:33' */
        break;
      }
    }

    /* End of State Transition Table: '<S1>/State Transition Table' */
  }

  /* Matfile logging */
  rt_UpdateTXYLogVars(LAFES_M->rtwLogInfo, (LAFES_M->Timing.t));

  {
    real_T *lastU;

    /* Update for S-Function (ec_EtherCAT_interface): '<S2>/S-Function' */
    /* Level2 S-Function Block: '<S2>/S-Function' (ec_EtherCAT_interface) */
    {
      SimStruct *rts = LAFES_M->childSfunctions[0];
      sfcnUpdate(rts,0);
      if (ssGetErrorStatus(rts) != (NULL))
        return;
    }

    /* Update for Derivative: '<S6>/Derivative' */
    if (LAFES_DW.TimeStampA == (rtInf)) {
      LAFES_DW.TimeStampA = LAFES_M->Timing.t[0];
      lastU = &LAFES_DW.LastUAtTimeA;
    } else if (LAFES_DW.TimeStampB == (rtInf)) {
      LAFES_DW.TimeStampB = LAFES_M->Timing.t[0];
      lastU = &LAFES_DW.LastUAtTimeB;
    } else if (LAFES_DW.TimeStampA < LAFES_DW.TimeStampB) {
      LAFES_DW.TimeStampA = LAFES_M->Timing.t[0];
      lastU = &LAFES_DW.LastUAtTimeA;
    } else {
      LAFES_DW.TimeStampB = LAFES_M->Timing.t[0];
      lastU = &LAFES_DW.LastUAtTimeB;
    }

    *lastU = LAFES_B.Switch;

    /* End of Update for Derivative: '<S6>/Derivative' */

    /* Update for Derivative: '<S6>/Derivative1' */
    if (LAFES_DW.TimeStampA_e == (rtInf)) {
      LAFES_DW.TimeStampA_e = LAFES_M->Timing.t[0];
      lastU = &LAFES_DW.LastUAtTimeA_c;
    } else if (LAFES_DW.TimeStampB_l == (rtInf)) {
      LAFES_DW.TimeStampB_l = LAFES_M->Timing.t[0];
      lastU = &LAFES_DW.LastUAtTimeB_f;
    } else if (LAFES_DW.TimeStampA_e < LAFES_DW.TimeStampB_l) {
      LAFES_DW.TimeStampA_e = LAFES_M->Timing.t[0];
      lastU = &LAFES_DW.LastUAtTimeA_c;
    } else {
      LAFES_DW.TimeStampB_l = LAFES_M->Timing.t[0];
      lastU = &LAFES_DW.LastUAtTimeB_f;
    }

    *lastU = LAFES_B.Derivative;

    /* End of Update for Derivative: '<S6>/Derivative1' */
  }

  /* External mode */
  rtExtModeUploadCheckTrigger(2);

  {                                    /* Sample time: [0.0s, 0.0s] */
    rtExtModeUpload(0, (real_T)LAFES_M->Timing.t[0]);
  }

  {                                    /* Sample time: [0.01s, 0.0s] */
    rtExtModeUpload(1, (real_T)LAFES_M->Timing.t[1]);
  }

  /* signal main to stop simulation */
  {                                    /* Sample time: [0.0s, 0.0s] */
    if ((rtmGetTFinal(LAFES_M)!=-1) &&
        !((rtmGetTFinal(LAFES_M)-LAFES_M->Timing.t[0]) > LAFES_M->Timing.t[0] *
          (DBL_EPSILON))) {
      rtmSetErrorStatus(LAFES_M, "Simulation finished");
    }

    if (rtmGetStopRequested(LAFES_M)) {
      rtmSetErrorStatus(LAFES_M, "Simulation finished");
    }
  }

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   * Timer of this task consists of two 32 bit unsigned integers.
   * The two integers represent the low bits Timing.clockTick0 and the high bits
   * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
   */
  if (!(++LAFES_M->Timing.clockTick0)) {
    ++LAFES_M->Timing.clockTickH0;
  }

  LAFES_M->Timing.t[0] = LAFES_M->Timing.clockTick0 * LAFES_M->Timing.stepSize0
    + LAFES_M->Timing.clockTickH0 * LAFES_M->Timing.stepSize0 * 4294967296.0;

  {
    /* Update absolute timer for sample time: [0.01s, 0.0s] */
    /* The "clockTick1" counts the number of times the code of this task has
     * been executed. The absolute time is the multiplication of "clockTick1"
     * and "Timing.stepSize1". Size of "clockTick1" ensures timer will not
     * overflow during the application lifespan selected.
     * Timer of this task consists of two 32 bit unsigned integers.
     * The two integers represent the low bits Timing.clockTick1 and the high bits
     * Timing.clockTickH1. When the low bit overflows to 0, the high bits increment.
     */
    if (!(++LAFES_M->Timing.clockTick1)) {
      ++LAFES_M->Timing.clockTickH1;
    }

    LAFES_M->Timing.t[1] = LAFES_M->Timing.clockTick1 *
      LAFES_M->Timing.stepSize1 + LAFES_M->Timing.clockTickH1 *
      LAFES_M->Timing.stepSize1 * 4294967296.0;
  }
}

/* Model initialize function */
void LAFES_initialize(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)LAFES_M, 0,
                sizeof(RT_MODEL_LAFES_T));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&LAFES_M->solverInfo, &LAFES_M->Timing.simTimeStep);
    rtsiSetTPtr(&LAFES_M->solverInfo, &rtmGetTPtr(LAFES_M));
    rtsiSetStepSizePtr(&LAFES_M->solverInfo, &LAFES_M->Timing.stepSize0);
    rtsiSetErrorStatusPtr(&LAFES_M->solverInfo, (&rtmGetErrorStatus(LAFES_M)));
    rtsiSetRTModelPtr(&LAFES_M->solverInfo, LAFES_M);
  }

  rtsiSetSimTimeStep(&LAFES_M->solverInfo, MAJOR_TIME_STEP);
  rtsiSetIsMinorTimeStepWithModeChange(&LAFES_M->solverInfo, false);
  rtsiSetIsContModeFrozen(&LAFES_M->solverInfo, false);
  rtsiSetSolverName(&LAFES_M->solverInfo,"FixedStepDiscrete");
  LAFES_M->solverInfoPtr = (&LAFES_M->solverInfo);

  /* Initialize timing info */
  {
    int_T *mdlTsMap = LAFES_M->Timing.sampleTimeTaskIDArray;
    mdlTsMap[0] = 0;
    mdlTsMap[1] = 1;

    /* polyspace +2 MISRA2012:D4.1 [Justified:Low] "LAFES_M points to
       static memory which is guaranteed to be non-NULL" */
    LAFES_M->Timing.sampleTimeTaskIDPtr = (&mdlTsMap[0]);
    LAFES_M->Timing.sampleTimes = (&LAFES_M->Timing.sampleTimesArray[0]);
    LAFES_M->Timing.offsetTimes = (&LAFES_M->Timing.offsetTimesArray[0]);

    /* task periods */
    LAFES_M->Timing.sampleTimes[0] = (0.0);
    LAFES_M->Timing.sampleTimes[1] = (0.01);

    /* task offsets */
    LAFES_M->Timing.offsetTimes[0] = (0.0);
    LAFES_M->Timing.offsetTimes[1] = (0.0);
  }

  rtmSetTPtr(LAFES_M, &LAFES_M->Timing.tArray[0]);

  {
    int_T *mdlSampleHits = LAFES_M->Timing.sampleHitArray;
    mdlSampleHits[0] = 1;
    mdlSampleHits[1] = 1;
    LAFES_M->Timing.sampleHits = (&mdlSampleHits[0]);
  }

  rtmSetTFinal(LAFES_M, 3600.0);
  LAFES_M->Timing.stepSize0 = 0.01;
  LAFES_M->Timing.stepSize1 = 0.01;

  /* Setup for data logging */
  {
    static RTWLogInfo rt_DataLoggingInfo;
    rt_DataLoggingInfo.loggingInterval = (NULL);
    LAFES_M->rtwLogInfo = &rt_DataLoggingInfo;
  }

  /* Setup for data logging */
  {
    rtliSetLogXSignalInfo(LAFES_M->rtwLogInfo, (NULL));
    rtliSetLogXSignalPtrs(LAFES_M->rtwLogInfo, (NULL));
    rtliSetLogT(LAFES_M->rtwLogInfo, "tout");
    rtliSetLogX(LAFES_M->rtwLogInfo, "");
    rtliSetLogXFinal(LAFES_M->rtwLogInfo, "");
    rtliSetLogVarNameModifier(LAFES_M->rtwLogInfo, "rt_");
    rtliSetLogFormat(LAFES_M->rtwLogInfo, 4);
    rtliSetLogMaxRows(LAFES_M->rtwLogInfo, 0);
    rtliSetLogDecimation(LAFES_M->rtwLogInfo, 1);
    rtliSetLogY(LAFES_M->rtwLogInfo, "");
    rtliSetLogYSignalInfo(LAFES_M->rtwLogInfo, (NULL));
    rtliSetLogYSignalPtrs(LAFES_M->rtwLogInfo, (NULL));
  }

  /* External mode info */
  LAFES_M->Sizes.checksums[0] = (3755760846U);
  LAFES_M->Sizes.checksums[1] = (3035390421U);
  LAFES_M->Sizes.checksums[2] = (3807190845U);
  LAFES_M->Sizes.checksums[3] = (923304473U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[3];
    LAFES_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    systemRan[1] = &rtAlwaysEnabled;
    systemRan[2] = (sysRanDType *)&LAFES_DW.SignalGenerator_SubsysRanBC;
    rteiSetModelMappingInfoPtr(LAFES_M->extModeInfo,
      &LAFES_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(LAFES_M->extModeInfo, LAFES_M->Sizes.checksums);
    rteiSetTPtr(LAFES_M->extModeInfo, rtmGetTPtr(LAFES_M));
  }

  LAFES_M->solverInfoPtr = (&LAFES_M->solverInfo);
  LAFES_M->Timing.stepSize = (0.01);
  rtsiSetFixedStepSize(&LAFES_M->solverInfo, 0.01);
  rtsiSetSolverMode(&LAFES_M->solverInfo, SOLVER_MODE_SINGLETASKING);

  /* block I/O */
  (void) memset(((void *) &LAFES_B), 0,
                sizeof(B_LAFES_T));

  {
    LAFES_B.State = State_Transition_TableModeType_None;
  }

  /* states (dwork) */
  (void) memset((void *)&LAFES_DW, 0,
                sizeof(DW_LAFES_T));

  /* data type transition information */
  {
    static DataTypeTransInfo dtInfo;
    (void) memset((char_T *) &dtInfo, 0,
                  sizeof(dtInfo));
    LAFES_M->SpecialInfo.mappingInfo = (&dtInfo);
    dtInfo.numDataTypes = 26;
    dtInfo.dataTypeSizes = &rtDataTypeSizes[0];
    dtInfo.dataTypeNames = &rtDataTypeNames[0];

    /* Block I/O transition table */
    dtInfo.BTransTable = &rtBTransTable;

    /* Parameters transition table */
    dtInfo.PTransTable = &rtPTransTable;
  }

  /* child S-Function registration */
  {
    RTWSfcnInfo *sfcnInfo = &LAFES_M->NonInlinedSFcns.sfcnInfo;
    LAFES_M->sfcnInfo = (sfcnInfo);
    rtssSetErrorStatusPtr(sfcnInfo, (&rtmGetErrorStatus(LAFES_M)));
    LAFES_M->Sizes.numSampTimes = (2);
    rtssSetNumRootSampTimesPtr(sfcnInfo, &LAFES_M->Sizes.numSampTimes);
    LAFES_M->NonInlinedSFcns.taskTimePtrs[0] = (&rtmGetTPtr(LAFES_M)[0]);
    LAFES_M->NonInlinedSFcns.taskTimePtrs[1] = (&rtmGetTPtr(LAFES_M)[1]);
    rtssSetTPtrPtr(sfcnInfo,LAFES_M->NonInlinedSFcns.taskTimePtrs);
    rtssSetTStartPtr(sfcnInfo, &rtmGetTStart(LAFES_M));
    rtssSetTFinalPtr(sfcnInfo, &rtmGetTFinal(LAFES_M));
    rtssSetTimeOfLastOutputPtr(sfcnInfo, &rtmGetTimeOfLastOutput(LAFES_M));
    rtssSetStepSizePtr(sfcnInfo, &LAFES_M->Timing.stepSize);
    rtssSetStopRequestedPtr(sfcnInfo, &rtmGetStopRequested(LAFES_M));
    rtssSetDerivCacheNeedsResetPtr(sfcnInfo, &LAFES_M->derivCacheNeedsReset);
    rtssSetZCCacheNeedsResetPtr(sfcnInfo, &LAFES_M->zCCacheNeedsReset);
    rtssSetContTimeOutputInconsistentWithStateAtMajorStepPtr(sfcnInfo,
      &LAFES_M->CTOutputIncnstWithState);
    rtssSetSampleHitsPtr(sfcnInfo, &LAFES_M->Timing.sampleHits);
    rtssSetPerTaskSampleHitsPtr(sfcnInfo, &LAFES_M->Timing.perTaskSampleHits);
    rtssSetSimModePtr(sfcnInfo, &LAFES_M->simMode);
    rtssSetSolverInfoPtr(sfcnInfo, &LAFES_M->solverInfoPtr);
  }

  LAFES_M->Sizes.numSFcns = (3);

  /* register each child */
  {
    (void) memset((void *)&LAFES_M->NonInlinedSFcns.childSFunctions[0], 0,
                  3*sizeof(SimStruct));
    LAFES_M->childSfunctions = (&LAFES_M->NonInlinedSFcns.childSFunctionPtrs[0]);
    LAFES_M->childSfunctions[0] = (&LAFES_M->NonInlinedSFcns.childSFunctions[0]);
    LAFES_M->childSfunctions[1] = (&LAFES_M->NonInlinedSFcns.childSFunctions[1]);
    LAFES_M->childSfunctions[2] = (&LAFES_M->NonInlinedSFcns.childSFunctions[2]);

    /* Level2 S-Function Block: LAFES/<S2>/S-Function (ec_EtherCAT_interface) */
    {
      SimStruct *rts = LAFES_M->childSfunctions[0];

      /* timing info */
      time_T *sfcnPeriod = LAFES_M->NonInlinedSFcns.Sfcn0.sfcnPeriod;
      time_T *sfcnOffset = LAFES_M->NonInlinedSFcns.Sfcn0.sfcnOffset;
      int_T *sfcnTsMap = LAFES_M->NonInlinedSFcns.Sfcn0.sfcnTsMap;
      (void) memset((void*)sfcnPeriod, 0,
                    sizeof(time_T)*1);
      (void) memset((void*)sfcnOffset, 0,
                    sizeof(time_T)*1);
      ssSetSampleTimePtr(rts, &sfcnPeriod[0]);
      ssSetOffsetTimePtr(rts, &sfcnOffset[0]);
      ssSetSampleTimeTaskIDPtr(rts, sfcnTsMap);

      {
        ssSetBlkInfo2Ptr(rts, &LAFES_M->NonInlinedSFcns.blkInfo2[0]);
      }

      _ssSetBlkInfo2PortInfo2Ptr(rts,
        &LAFES_M->NonInlinedSFcns.inputOutputPortInfo2[0]);

      /* Set up the mdlInfo pointer */
      ssSetRTWSfcnInfo(rts, LAFES_M->sfcnInfo);

      /* Allocate memory of model methods 2 */
      {
        ssSetModelMethods2(rts, &LAFES_M->NonInlinedSFcns.methods2[0]);
      }

      /* Allocate memory of model methods 3 */
      {
        ssSetModelMethods3(rts, &LAFES_M->NonInlinedSFcns.methods3[0]);
      }

      /* Allocate memory of model methods 4 */
      {
        ssSetModelMethods4(rts, &LAFES_M->NonInlinedSFcns.methods4[0]);
      }

      /* Allocate memory for states auxilliary information */
      {
        ssSetStatesInfo2(rts, &LAFES_M->NonInlinedSFcns.statesInfo2[0]);
        ssSetPeriodicStatesInfo(rts,
          &LAFES_M->NonInlinedSFcns.periodicStatesInfo[0]);
      }

      /* outputs */
      {
        ssSetPortInfoForOutputs(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn0.outputPortInfo[0]);
        ssSetPortInfoForOutputs(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn0.outputPortInfo[0]);
        _ssSetNumOutputPorts(rts, 1);
        _ssSetPortInfo2ForOutputUnits(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn0.outputPortUnits[0]);
        ssSetOutputPortUnit(rts, 0, 0);
        _ssSetPortInfo2ForOutputCoSimAttribute(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn0.outputPortCoSimAttribute[0]);
        ssSetOutputPortIsContinuousQuantity(rts, 0, 0);

        /* port 0 */
        {
          _ssSetOutputPortNumDimensions(rts, 0, 1);
          ssSetOutputPortWidthAsInt(rts, 0, 1);
          ssSetOutputPortSignal(rts, 0, ((uint8_T *) &LAFES_B.eCAT_okay));
        }
      }

      /* path info */
      ssSetModelName(rts, "S-Function");
      ssSetPath(rts, "LAFES/Subsystem/S-Function");
      ssSetRTModel(rts,LAFES_M);
      ssSetParentSS(rts, (NULL));
      ssSetRootSS(rts, rts);
      ssSetVersion(rts, SIMSTRUCT_VERSION_LEVEL2);

      /* parameters */
      {
        mxArray **sfcnParams = (mxArray **)
          &LAFES_M->NonInlinedSFcns.Sfcn0.params;
        ssSetSFcnParamsCount(rts, 1);
        ssSetSFcnParamsPtr(rts, &sfcnParams[0]);
        ssSetSFcnParam(rts, 0, (mxArray*)LAFES_P.SFunction_P1_Size);
      }

      /* work vectors */
      ssSetRWork(rts, (real_T *) &LAFES_DW.SFunction_RWORK[0]);

      {
        struct _ssDWorkRecord *dWorkRecord = (struct _ssDWorkRecord *)
          &LAFES_M->NonInlinedSFcns.Sfcn0.dWork;
        struct _ssDWorkAuxRecord *dWorkAuxRecord = (struct _ssDWorkAuxRecord *)
          &LAFES_M->NonInlinedSFcns.Sfcn0.dWorkAux;
        ssSetSFcnDWork(rts, dWorkRecord);
        ssSetSFcnDWorkAux(rts, dWorkAuxRecord);
        ssSetNumDWorkAsInt(rts, 1);

        /* RWORK */
        ssSetDWorkWidthAsInt(rts, 0, 519);
        ssSetDWorkDataType(rts, 0,SS_DOUBLE);
        ssSetDWorkComplexSignal(rts, 0, 0);
        ssSetDWork(rts, 0, &LAFES_DW.SFunction_RWORK[0]);
      }

      /* registration */
      ec_EtherCAT_interface(rts);
      sfcnInitializeSizes(rts);
      sfcnInitializeSampleTimes(rts);

      /* adjust sample time */
      ssSetSampleTime(rts, 0, 0.01);
      ssSetOffsetTime(rts, 0, 0.0);
      sfcnTsMap[0] = 1;

      /* set compiled values of dynamic vector attributes */
      ssSetNumNonsampledZCsAsInt(rts, 0);

      /* Update connectivity flags for each port */
      _ssSetOutputPortConnected(rts, 0, 1);
      _ssSetOutputPortBeingMerged(rts, 0, 0);

      /* Update the BufferDstPort flags for each input port */
    }

    /* Level2 S-Function Block: LAFES/<S5>/S-Function1 (ec_EPOS4_i) */
    {
      SimStruct *rts = LAFES_M->childSfunctions[1];

      /* timing info */
      time_T *sfcnPeriod = LAFES_M->NonInlinedSFcns.Sfcn1.sfcnPeriod;
      time_T *sfcnOffset = LAFES_M->NonInlinedSFcns.Sfcn1.sfcnOffset;
      int_T *sfcnTsMap = LAFES_M->NonInlinedSFcns.Sfcn1.sfcnTsMap;
      (void) memset((void*)sfcnPeriod, 0,
                    sizeof(time_T)*1);
      (void) memset((void*)sfcnOffset, 0,
                    sizeof(time_T)*1);
      ssSetSampleTimePtr(rts, &sfcnPeriod[0]);
      ssSetOffsetTimePtr(rts, &sfcnOffset[0]);
      ssSetSampleTimeTaskIDPtr(rts, sfcnTsMap);

      {
        ssSetBlkInfo2Ptr(rts, &LAFES_M->NonInlinedSFcns.blkInfo2[1]);
      }

      _ssSetBlkInfo2PortInfo2Ptr(rts,
        &LAFES_M->NonInlinedSFcns.inputOutputPortInfo2[1]);

      /* Set up the mdlInfo pointer */
      ssSetRTWSfcnInfo(rts, LAFES_M->sfcnInfo);

      /* Allocate memory of model methods 2 */
      {
        ssSetModelMethods2(rts, &LAFES_M->NonInlinedSFcns.methods2[1]);
      }

      /* Allocate memory of model methods 3 */
      {
        ssSetModelMethods3(rts, &LAFES_M->NonInlinedSFcns.methods3[1]);
      }

      /* Allocate memory of model methods 4 */
      {
        ssSetModelMethods4(rts, &LAFES_M->NonInlinedSFcns.methods4[1]);
      }

      /* Allocate memory for states auxilliary information */
      {
        ssSetStatesInfo2(rts, &LAFES_M->NonInlinedSFcns.statesInfo2[1]);
        ssSetPeriodicStatesInfo(rts,
          &LAFES_M->NonInlinedSFcns.periodicStatesInfo[1]);
      }

      /* outputs */
      {
        ssSetPortInfoForOutputs(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn1.outputPortInfo[0]);
        ssSetPortInfoForOutputs(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn1.outputPortInfo[0]);
        _ssSetNumOutputPorts(rts, 1);
        _ssSetPortInfo2ForOutputUnits(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn1.outputPortUnits[0]);
        ssSetOutputPortUnit(rts, 0, 0);
        _ssSetPortInfo2ForOutputCoSimAttribute(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn1.outputPortCoSimAttribute[0]);
        ssSetOutputPortIsContinuousQuantity(rts, 0, 0);

        /* port 0 */
        {
          _ssSetOutputPortNumDimensions(rts, 0, 1);
          ssSetOutputPortWidthAsInt(rts, 0, 2);
          ssSetOutputPortSignal(rts, 0, ((real_T *) LAFES_B.SFunction1));
        }
      }

      /* path info */
      ssSetModelName(rts, "S-Function1");
      ssSetPath(rts, "LAFES/Subsystem Reference/EPOS/S-Function1");
      ssSetRTModel(rts,LAFES_M);
      ssSetParentSS(rts, (NULL));
      ssSetRootSS(rts, rts);
      ssSetVersion(rts, SIMSTRUCT_VERSION_LEVEL2);

      /* parameters */
      {
        mxArray **sfcnParams = (mxArray **)
          &LAFES_M->NonInlinedSFcns.Sfcn1.params;
        ssSetSFcnParamsCount(rts, 2);
        ssSetSFcnParamsPtr(rts, &sfcnParams[0]);
        ssSetSFcnParam(rts, 0, (mxArray*)LAFES_P.SFunction1_P1_Size);
        ssSetSFcnParam(rts, 1, (mxArray*)LAFES_P.SFunction1_P2_Size);
      }

      /* work vectors */
      ssSetRWork(rts, (real_T *) &LAFES_DW.SFunction1_RWORK[0]);

      {
        struct _ssDWorkRecord *dWorkRecord = (struct _ssDWorkRecord *)
          &LAFES_M->NonInlinedSFcns.Sfcn1.dWork;
        struct _ssDWorkAuxRecord *dWorkAuxRecord = (struct _ssDWorkAuxRecord *)
          &LAFES_M->NonInlinedSFcns.Sfcn1.dWorkAux;
        ssSetSFcnDWork(rts, dWorkRecord);
        ssSetSFcnDWorkAux(rts, dWorkAuxRecord);
        ssSetNumDWorkAsInt(rts, 1);

        /* RWORK */
        ssSetDWorkWidthAsInt(rts, 0, 4);
        ssSetDWorkDataType(rts, 0,SS_DOUBLE);
        ssSetDWorkComplexSignal(rts, 0, 0);
        ssSetDWork(rts, 0, &LAFES_DW.SFunction1_RWORK[0]);
      }

      /* registration */
      ec_EPOS4_i(rts);
      sfcnInitializeSizes(rts);
      sfcnInitializeSampleTimes(rts);

      /* adjust sample time */
      ssSetSampleTime(rts, 0, 0.01);
      ssSetOffsetTime(rts, 0, 0.0);
      sfcnTsMap[0] = 1;

      /* set compiled values of dynamic vector attributes */
      ssSetNumNonsampledZCsAsInt(rts, 0);

      /* Update connectivity flags for each port */
      _ssSetOutputPortConnected(rts, 0, 1);
      _ssSetOutputPortBeingMerged(rts, 0, 0);

      /* Update the BufferDstPort flags for each input port */
    }

    /* Level2 S-Function Block: LAFES/<S5>/S-Function (ec_EPOS4_o) */
    {
      SimStruct *rts = LAFES_M->childSfunctions[2];

      /* timing info */
      time_T *sfcnPeriod = LAFES_M->NonInlinedSFcns.Sfcn2.sfcnPeriod;
      time_T *sfcnOffset = LAFES_M->NonInlinedSFcns.Sfcn2.sfcnOffset;
      int_T *sfcnTsMap = LAFES_M->NonInlinedSFcns.Sfcn2.sfcnTsMap;
      (void) memset((void*)sfcnPeriod, 0,
                    sizeof(time_T)*1);
      (void) memset((void*)sfcnOffset, 0,
                    sizeof(time_T)*1);
      ssSetSampleTimePtr(rts, &sfcnPeriod[0]);
      ssSetOffsetTimePtr(rts, &sfcnOffset[0]);
      ssSetSampleTimeTaskIDPtr(rts, sfcnTsMap);

      {
        ssSetBlkInfo2Ptr(rts, &LAFES_M->NonInlinedSFcns.blkInfo2[2]);
      }

      _ssSetBlkInfo2PortInfo2Ptr(rts,
        &LAFES_M->NonInlinedSFcns.inputOutputPortInfo2[2]);

      /* Set up the mdlInfo pointer */
      ssSetRTWSfcnInfo(rts, LAFES_M->sfcnInfo);

      /* Allocate memory of model methods 2 */
      {
        ssSetModelMethods2(rts, &LAFES_M->NonInlinedSFcns.methods2[2]);
      }

      /* Allocate memory of model methods 3 */
      {
        ssSetModelMethods3(rts, &LAFES_M->NonInlinedSFcns.methods3[2]);
      }

      /* Allocate memory of model methods 4 */
      {
        ssSetModelMethods4(rts, &LAFES_M->NonInlinedSFcns.methods4[2]);
      }

      /* Allocate memory for states auxilliary information */
      {
        ssSetStatesInfo2(rts, &LAFES_M->NonInlinedSFcns.statesInfo2[2]);
        ssSetPeriodicStatesInfo(rts,
          &LAFES_M->NonInlinedSFcns.periodicStatesInfo[2]);
      }

      /* inputs */
      {
        _ssSetNumInputPorts(rts, 1);
        ssSetPortInfoForInputs(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn2.inputPortInfo[0]);
        ssSetPortInfoForInputs(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn2.inputPortInfo[0]);
        _ssSetPortInfo2ForInputUnits(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn2.inputPortUnits[0]);
        ssSetInputPortUnit(rts, 0, 0);
        _ssSetPortInfo2ForInputCoSimAttribute(rts,
          &LAFES_M->NonInlinedSFcns.Sfcn2.inputPortCoSimAttribute[0]);
        ssSetInputPortIsContinuousQuantity(rts, 0, 0);

        /* port 0 */
        {
          real_T const **sfcnUPtrs = (real_T const **)
            &LAFES_M->NonInlinedSFcns.Sfcn2.UPtrs0;
          sfcnUPtrs[0] = ((const real_T*) &LAFES_RGND);
          sfcnUPtrs[1] = &LAFES_B.Z_out;
          ssSetInputPortSignalPtrs(rts, 0, (InputPtrsType)&sfcnUPtrs[0]);
          _ssSetInputPortNumDimensions(rts, 0, 1);
          ssSetInputPortWidthAsInt(rts, 0, 2);
        }
      }

      /* path info */
      ssSetModelName(rts, "S-Function");
      ssSetPath(rts, "LAFES/Subsystem Reference/EPOS/S-Function");
      ssSetRTModel(rts,LAFES_M);
      ssSetParentSS(rts, (NULL));
      ssSetRootSS(rts, rts);
      ssSetVersion(rts, SIMSTRUCT_VERSION_LEVEL2);

      /* parameters */
      {
        mxArray **sfcnParams = (mxArray **)
          &LAFES_M->NonInlinedSFcns.Sfcn2.params;
        ssSetSFcnParamsCount(rts, 1);
        ssSetSFcnParamsPtr(rts, &sfcnParams[0]);
        ssSetSFcnParam(rts, 0, (mxArray*)LAFES_P.SFunction_P1_Size_c);
      }

      /* work vectors */
      ssSetRWork(rts, (real_T *) &LAFES_DW.SFunction_RWORK_m[0]);

      {
        struct _ssDWorkRecord *dWorkRecord = (struct _ssDWorkRecord *)
          &LAFES_M->NonInlinedSFcns.Sfcn2.dWork;
        struct _ssDWorkAuxRecord *dWorkAuxRecord = (struct _ssDWorkAuxRecord *)
          &LAFES_M->NonInlinedSFcns.Sfcn2.dWorkAux;
        ssSetSFcnDWork(rts, dWorkRecord);
        ssSetSFcnDWorkAux(rts, dWorkAuxRecord);
        ssSetNumDWorkAsInt(rts, 1);

        /* RWORK */
        ssSetDWorkWidthAsInt(rts, 0, 4);
        ssSetDWorkDataType(rts, 0,SS_DOUBLE);
        ssSetDWorkComplexSignal(rts, 0, 0);
        ssSetDWork(rts, 0, &LAFES_DW.SFunction_RWORK_m[0]);
      }

      /* registration */
      ec_EPOS4_o(rts);
      sfcnInitializeSizes(rts);
      sfcnInitializeSampleTimes(rts);

      /* adjust sample time */
      ssSetSampleTime(rts, 0, 0.01);
      ssSetOffsetTime(rts, 0, 0.0);
      sfcnTsMap[0] = 1;

      /* set compiled values of dynamic vector attributes */
      ssSetNumNonsampledZCsAsInt(rts, 0);

      /* Update connectivity flags for each port */
      _ssSetInputPortConnected(rts, 0, 1);

      /* Update the BufferDstPort flags for each input port */
      ssSetInputPortBufferDstPort(rts, 0, -1);
    }
  }

  /* Matfile logging */
  rt_StartDataLoggingWithStartTime(LAFES_M->rtwLogInfo, 0.0, rtmGetTFinal
    (LAFES_M), LAFES_M->Timing.stepSize0, (&rtmGetErrorStatus(LAFES_M)));

  /* Start for S-Function (ec_EtherCAT_interface): '<S2>/S-Function' */
  /* Level2 S-Function Block: '<S2>/S-Function' (ec_EtherCAT_interface) */
  {
    SimStruct *rts = LAFES_M->childSfunctions[0];
    sfcnStart(rts);
    if (ssGetErrorStatus(rts) != (NULL))
      return;
  }

  /* Start for Constant: '<S1>/Constant' */
  LAFES_B.Constant = LAFES_P.main_switch;

  /* Start for Constant: '<S1>/Constant1' */
  LAFES_B.Constant1 = LAFES_P.quick_stop;

  /* Start for Constant: '<S1>/Constant2' */
  LAFES_B.Constant2 = LAFES_P.motor_e_stop;

  /* InitializeConditions for S-Function (ec_EPOS4_i): '<S5>/S-Function1' */
  /* Level2 S-Function Block: '<S5>/S-Function1' (ec_EPOS4_i) */
  {
    SimStruct *rts = LAFES_M->childSfunctions[1];
    sfcnInitializeConditions(rts);
    if (ssGetErrorStatus(rts) != (NULL))
      return;
  }

  /* InitializeConditions for Derivative: '<S6>/Derivative' */
  LAFES_DW.TimeStampA = (rtInf);
  LAFES_DW.TimeStampB = (rtInf);

  /* InitializeConditions for Derivative: '<S6>/Derivative1' */
  LAFES_DW.TimeStampA_e = (rtInf);
  LAFES_DW.TimeStampB_l = (rtInf);

  /* InitializeConditions for S-Function (ec_EPOS4_o): '<S5>/S-Function' */
  /* Level2 S-Function Block: '<S5>/S-Function' (ec_EPOS4_o) */
  {
    SimStruct *rts = LAFES_M->childSfunctions[2];
    sfcnInitializeConditions(rts);
    if (ssGetErrorStatus(rts) != (NULL))
      return;
  }

  /* SystemInitialize for Enabled SubSystem: '<S3>/Signal Generator' */
  /* SystemInitialize for Gain: '<S8>/Gain' incorporates:
   *  Outport: '<S8>/Out1'
   */
  LAFES_B.X_gen = LAFES_P.Out1_Y0;

  /* End of SystemInitialize for SubSystem: '<S3>/Signal Generator' */

  /* SystemInitialize for State Transition Table: '<S1>/State Transition Table' */
  LAFES_DW.sfEvent = LAFES_CALL_EVENT;
  LAFES_DW.is_active_c4_LAFES = 0U;
  LAFES_B.State = State_Transition_TableModeType_None;
}

/* Model terminate function */
void LAFES_terminate(void)
{
  /* Terminate for S-Function (ec_EtherCAT_interface): '<S2>/S-Function' */
  /* Level2 S-Function Block: '<S2>/S-Function' (ec_EtherCAT_interface) */
  {
    SimStruct *rts = LAFES_M->childSfunctions[0];
    sfcnTerminate(rts);
  }

  /* Terminate for S-Function (ec_EPOS4_i): '<S5>/S-Function1' */
  /* Level2 S-Function Block: '<S5>/S-Function1' (ec_EPOS4_i) */
  {
    SimStruct *rts = LAFES_M->childSfunctions[1];
    sfcnTerminate(rts);
  }

  /* Terminate for S-Function (ec_EPOS4_o): '<S5>/S-Function' */
  /* Level2 S-Function Block: '<S5>/S-Function' (ec_EPOS4_o) */
  {
    SimStruct *rts = LAFES_M->childSfunctions[2];
    sfcnTerminate(rts);
  }

  /* CleanupRuntimeResources for S-Function (ec_EtherCAT_interface): '<S2>/S-Function' */
  /* Level2 S-Function Block: '<S2>/S-Function' (ec_EtherCAT_interface) */
  {
    SimStruct *rts = LAFES_M->childSfunctions[0];
    sfcnCleanupRuntimeResources(rts);
  }
}
