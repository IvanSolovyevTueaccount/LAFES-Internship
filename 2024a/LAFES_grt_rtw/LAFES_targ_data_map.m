    function targMap = targDataMap(),

    ;%***********************
    ;% Create Parameter Map *
    ;%***********************
    
        nTotData      = 0; %add to this count as we go
        nTotSects     = 2;
        sectIdxOffset = 0;

        ;%
        ;% Define dummy sections & preallocate arrays
        ;%
        dumSection.nData = -1;
        dumSection.data  = [];

        dumData.logicalSrcIdx = -1;
        dumData.dtTransOffset = -1;

        ;%
        ;% Init/prealloc paramMap
        ;%
        paramMap.nSections           = nTotSects;
        paramMap.sectIdxOffset       = sectIdxOffset;
            paramMap.sections(nTotSects) = dumSection; %prealloc
        paramMap.nTotData            = -1;

        ;%
        ;% Auto data (LAFES_P)
        ;%
            section.nData     = 4;
            section.data(4)  = dumData; %prealloc

                    ;% LAFES_P.main_switch
                    section.data(1).logicalSrcIdx = 0;
                    section.data(1).dtTransOffset = 0;

                    ;% LAFES_P.motor_e_stop
                    section.data(2).logicalSrcIdx = 1;
                    section.data(2).dtTransOffset = 1;

                    ;% LAFES_P.quick_stop
                    section.data(3).logicalSrcIdx = 2;
                    section.data(3).dtTransOffset = 2;

                    ;% LAFES_P.useGenerator
                    section.data(4).logicalSrcIdx = 3;
                    section.data(4).dtTransOffset = 3;

            nTotData = nTotData + section.nData;
            paramMap.sections(1) = section;
            clear section

            section.nData     = 17;
            section.data(17)  = dumData; %prealloc

                    ;% LAFES_P.Out1_Y0
                    section.data(1).logicalSrcIdx = 4;
                    section.data(1).dtTransOffset = 0;

                    ;% LAFES_P.SineWave_Amp
                    section.data(2).logicalSrcIdx = 5;
                    section.data(2).dtTransOffset = 1;

                    ;% LAFES_P.SineWave_Bias
                    section.data(3).logicalSrcIdx = 6;
                    section.data(3).dtTransOffset = 2;

                    ;% LAFES_P.SineWave_Freq
                    section.data(4).logicalSrcIdx = 7;
                    section.data(4).dtTransOffset = 3;

                    ;% LAFES_P.SineWave_Phase
                    section.data(5).logicalSrcIdx = 8;
                    section.data(5).dtTransOffset = 4;

                    ;% LAFES_P.Gain_Gain
                    section.data(6).logicalSrcIdx = 9;
                    section.data(6).dtTransOffset = 5;

                    ;% LAFES_P.SFunction_P1_Size
                    section.data(7).logicalSrcIdx = 10;
                    section.data(7).dtTransOffset = 6;

                    ;% LAFES_P.SFunction_P1
                    section.data(8).logicalSrcIdx = 11;
                    section.data(8).dtTransOffset = 8;

                    ;% LAFES_P.SFunction1_P1_Size
                    section.data(9).logicalSrcIdx = 12;
                    section.data(9).dtTransOffset = 12;

                    ;% LAFES_P.SFunction1_P1
                    section.data(10).logicalSrcIdx = 13;
                    section.data(10).dtTransOffset = 14;

                    ;% LAFES_P.SFunction1_P2_Size
                    section.data(11).logicalSrcIdx = 14;
                    section.data(11).dtTransOffset = 15;

                    ;% LAFES_P.SFunction1_P2
                    section.data(12).logicalSrcIdx = 15;
                    section.data(12).dtTransOffset = 17;

                    ;% LAFES_P.Gain_Gain_f
                    section.data(13).logicalSrcIdx = 16;
                    section.data(13).dtTransOffset = 18;

                    ;% LAFES_P.Gain1_Gain
                    section.data(14).logicalSrcIdx = 17;
                    section.data(14).dtTransOffset = 19;

                    ;% LAFES_P.Gain2_Gain
                    section.data(15).logicalSrcIdx = 18;
                    section.data(15).dtTransOffset = 20;

                    ;% LAFES_P.SFunction_P1_Size_c
                    section.data(16).logicalSrcIdx = 19;
                    section.data(16).dtTransOffset = 21;

                    ;% LAFES_P.SFunction_P1_e
                    section.data(17).logicalSrcIdx = 20;
                    section.data(17).dtTransOffset = 23;

            nTotData = nTotData + section.nData;
            paramMap.sections(2) = section;
            clear section


            ;%
            ;% Non-auto Data (parameter)
            ;%


        ;%
        ;% Add final counts to struct.
        ;%
        paramMap.nTotData = nTotData;



    ;%**************************
    ;% Create Block Output Map *
    ;%**************************
    
        nTotData      = 0; %add to this count as we go
        nTotSects     = 4;
        sectIdxOffset = 0;

        ;%
        ;% Define dummy sections & preallocate arrays
        ;%
        dumSection.nData = -1;
        dumSection.data  = [];

        dumData.logicalSrcIdx = -1;
        dumData.dtTransOffset = -1;

        ;%
        ;% Init/prealloc sigMap
        ;%
        sigMap.nSections           = nTotSects;
        sigMap.sectIdxOffset       = sectIdxOffset;
            sigMap.sections(nTotSects) = dumSection; %prealloc
        sigMap.nTotData            = -1;

        ;%
        ;% Auto data (LAFES_B)
        ;%
            section.nData     = 5;
            section.data(5)  = dumData; %prealloc

                    ;% LAFES_B.SFunction1
                    section.data(1).logicalSrcIdx = 0;
                    section.data(1).dtTransOffset = 0;

                    ;% LAFES_B.Switch
                    section.data(2).logicalSrcIdx = 1;
                    section.data(2).dtTransOffset = 2;

                    ;% LAFES_B.Derivative
                    section.data(3).logicalSrcIdx = 2;
                    section.data(3).dtTransOffset = 3;

                    ;% LAFES_B.Z_out
                    section.data(4).logicalSrcIdx = 3;
                    section.data(4).dtTransOffset = 4;

                    ;% LAFES_B.X_gen
                    section.data(5).logicalSrcIdx = 4;
                    section.data(5).dtTransOffset = 5;

            nTotData = nTotData + section.nData;
            sigMap.sections(1) = section;
            clear section

            section.nData     = 1;
            section.data(1)  = dumData; %prealloc

                    ;% LAFES_B.State
                    section.data(1).logicalSrcIdx = 5;
                    section.data(1).dtTransOffset = 0;

            nTotData = nTotData + section.nData;
            sigMap.sections(2) = section;
            clear section

            section.nData     = 1;
            section.data(1)  = dumData; %prealloc

                    ;% LAFES_B.eCAT_okay
                    section.data(1).logicalSrcIdx = 6;
                    section.data(1).dtTransOffset = 0;

            nTotData = nTotData + section.nData;
            sigMap.sections(3) = section;
            clear section

            section.nData     = 3;
            section.data(3)  = dumData; %prealloc

                    ;% LAFES_B.Constant
                    section.data(1).logicalSrcIdx = 7;
                    section.data(1).dtTransOffset = 0;

                    ;% LAFES_B.Constant1
                    section.data(2).logicalSrcIdx = 8;
                    section.data(2).dtTransOffset = 1;

                    ;% LAFES_B.Constant2
                    section.data(3).logicalSrcIdx = 9;
                    section.data(3).dtTransOffset = 2;

            nTotData = nTotData + section.nData;
            sigMap.sections(4) = section;
            clear section


            ;%
            ;% Non-auto Data (signal)
            ;%


        ;%
        ;% Add final counts to struct.
        ;%
        sigMap.nTotData = nTotData;



    ;%*******************
    ;% Create DWork Map *
    ;%*******************
    
        nTotData      = 0; %add to this count as we go
        nTotSects     = 5;
        sectIdxOffset = 4;

        ;%
        ;% Define dummy sections & preallocate arrays
        ;%
        dumSection.nData = -1;
        dumSection.data  = [];

        dumData.logicalSrcIdx = -1;
        dumData.dtTransOffset = -1;

        ;%
        ;% Init/prealloc dworkMap
        ;%
        dworkMap.nSections           = nTotSects;
        dworkMap.sectIdxOffset       = sectIdxOffset;
            dworkMap.sections(nTotSects) = dumSection; %prealloc
        dworkMap.nTotData            = -1;

        ;%
        ;% Auto data (LAFES_DW)
        ;%
            section.nData     = 11;
            section.data(11)  = dumData; %prealloc

                    ;% LAFES_DW.TimeStampA
                    section.data(1).logicalSrcIdx = 0;
                    section.data(1).dtTransOffset = 0;

                    ;% LAFES_DW.LastUAtTimeA
                    section.data(2).logicalSrcIdx = 1;
                    section.data(2).dtTransOffset = 1;

                    ;% LAFES_DW.TimeStampB
                    section.data(3).logicalSrcIdx = 2;
                    section.data(3).dtTransOffset = 2;

                    ;% LAFES_DW.LastUAtTimeB
                    section.data(4).logicalSrcIdx = 3;
                    section.data(4).dtTransOffset = 3;

                    ;% LAFES_DW.TimeStampA_e
                    section.data(5).logicalSrcIdx = 4;
                    section.data(5).dtTransOffset = 4;

                    ;% LAFES_DW.LastUAtTimeA_c
                    section.data(6).logicalSrcIdx = 5;
                    section.data(6).dtTransOffset = 5;

                    ;% LAFES_DW.TimeStampB_l
                    section.data(7).logicalSrcIdx = 6;
                    section.data(7).dtTransOffset = 6;

                    ;% LAFES_DW.LastUAtTimeB_f
                    section.data(8).logicalSrcIdx = 7;
                    section.data(8).dtTransOffset = 7;

                    ;% LAFES_DW.SFunction_RWORK
                    section.data(9).logicalSrcIdx = 8;
                    section.data(9).dtTransOffset = 8;

                    ;% LAFES_DW.SFunction1_RWORK
                    section.data(10).logicalSrcIdx = 9;
                    section.data(10).dtTransOffset = 527;

                    ;% LAFES_DW.SFunction_RWORK_m
                    section.data(11).logicalSrcIdx = 10;
                    section.data(11).dtTransOffset = 531;

            nTotData = nTotData + section.nData;
            dworkMap.sections(1) = section;
            clear section

            section.nData     = 1;
            section.data(1)  = dumData; %prealloc

                    ;% LAFES_DW.sfEvent
                    section.data(1).logicalSrcIdx = 11;
                    section.data(1).dtTransOffset = 0;

            nTotData = nTotData + section.nData;
            dworkMap.sections(2) = section;
            clear section

            section.nData     = 1;
            section.data(1)  = dumData; %prealloc

                    ;% LAFES_DW.SignalGenerator_SubsysRanBC
                    section.data(1).logicalSrcIdx = 12;
                    section.data(1).dtTransOffset = 0;

            nTotData = nTotData + section.nData;
            dworkMap.sections(3) = section;
            clear section

            section.nData     = 1;
            section.data(1)  = dumData; %prealloc

                    ;% LAFES_DW.is_active_c4_LAFES
                    section.data(1).logicalSrcIdx = 13;
                    section.data(1).dtTransOffset = 0;

            nTotData = nTotData + section.nData;
            dworkMap.sections(4) = section;
            clear section

            section.nData     = 1;
            section.data(1)  = dumData; %prealloc

                    ;% LAFES_DW.SignalGenerator_MODE
                    section.data(1).logicalSrcIdx = 14;
                    section.data(1).dtTransOffset = 0;

            nTotData = nTotData + section.nData;
            dworkMap.sections(5) = section;
            clear section


            ;%
            ;% Non-auto Data (dwork)
            ;%


        ;%
        ;% Add final counts to struct.
        ;%
        dworkMap.nTotData = nTotData;



    ;%
    ;% Add individual maps to base struct.
    ;%

    targMap.paramMap  = paramMap;
    targMap.signalMap = sigMap;
    targMap.dworkMap  = dworkMap;

    ;%
    ;% Add checksums to base struct.
    ;%


    targMap.checksum0 = 3755760846;
    targMap.checksum1 = 3035390421;
    targMap.checksum2 = 3807190845;
    targMap.checksum3 = 923304473;

