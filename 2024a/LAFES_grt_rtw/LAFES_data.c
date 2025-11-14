/*
 * LAFES_data.c
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

/* Block parameters (default storage) */
P_LAFES_T LAFES_P = {
  /* Variable: main_switch
   * Referenced by: '<S1>/Constant'
   */
  true,

  /* Variable: motor_e_stop
   * Referenced by: '<S1>/Constant2'
   */
  false,

  /* Variable: quick_stop
   * Referenced by: '<S1>/Constant1'
   */
  false,

  /* Variable: useGenerator
   * Referenced by: '<S3>/Constant'
   */
  true,

  /* Computed Parameter: Out1_Y0
   * Referenced by: '<S8>/Out1'
   */
  0.0,

  /* Expression: 1
   * Referenced by: '<S8>/Sine Wave'
   */
  1.0,

  /* Expression: 0
   * Referenced by: '<S8>/Sine Wave'
   */
  0.0,

  /* Expression: 1
   * Referenced by: '<S8>/Sine Wave'
   */
  1.0,

  /* Expression: 0
   * Referenced by: '<S8>/Sine Wave'
   */
  0.0,

  /* Expression: 100
   * Referenced by: '<S8>/Gain'
   */
  100.0,

  /* Computed Parameter: SFunction_P1_Size
   * Referenced by: '<S2>/S-Function'
   */
  { 1.0, 4.0 },

  /* Computed Parameter: SFunction_P1
   * Referenced by: '<S2>/S-Function'
   */
  { 101.0, 116.0, 104.0, 48.0 },

  /* Computed Parameter: SFunction1_P1_Size
   * Referenced by: '<S5>/S-Function1'
   */
  { 1.0, 1.0 },

  /* Expression: link_id
   * Referenced by: '<S5>/S-Function1'
   */
  1.0,

  /* Computed Parameter: SFunction1_P2_Size
   * Referenced by: '<S5>/S-Function1'
   */
  { 1.0, 1.0 },

  /* Expression: operating_mode
   * Referenced by: '<S5>/S-Function1'
   */
  3.0,

  /* Expression: 0
   * Referenced by: '<S6>/Gain'
   */
  0.0,

  /* Expression: 0
   * Referenced by: '<S6>/Gain1'
   */
  0.0,

  /* Expression: 0
   * Referenced by: '<S6>/Gain2'
   */
  0.0,

  /* Computed Parameter: SFunction_P1_Size_c
   * Referenced by: '<S5>/S-Function'
   */
  { 1.0, 1.0 },

  /* Expression: link_id
   * Referenced by: '<S5>/S-Function'
   */
  1.0
};
