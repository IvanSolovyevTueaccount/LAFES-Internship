# Copyright 1994-2020 The MathWorks, Inc.
#
# File    : mt_unix.tmf
#
# Abstract:
#	Template makefile for building a UNIX-based stand-alone generic
#       real-time version of Simulink model using generated C code.
#
# 	This makefile attempts to conform to the guidelines specified in the
# 	IEEE Std 1003.2-1992 (POSIX) standard. It is designed to be used
#       with GNU Make which is located in matlabroot/rtw/bin.
#
# 	Note that this template is automatically customized by the build
#       procedure to create "<model>.mk"
#
#       The following defines can be used to modify the behavior of the
#	build:
#	  OPT_OPTS       - Optimization options. Default is -O.
#	  CPP_OPTS       - C++ compiler options.
#	  OPTS           - User specific compile options.
#	  USER_SRCS      - Additional user sources, such as files needed by
#			   S-functions.
#	  USER_INCLUDES  - Additional include paths
#			   (i.e. USER_INCLUDES="-Iwhere-ever -Iwhere-ever2")
#
#       To enable debugging:
#         set DEBUG_BUILD = 1 below, which will trigger OPTS=-g and
#          LDFLAGS += -g (may vary with compiler version, see compiler doc)
#
#       This template makefile is designed to be used with a system target
#       file that contains 'rtwgensettings.BuildDirSuffix' see grt.tlc

#------------------------ Macros read by make_rtw ------------------------------
#
# The following macros are read by the build procedure:
#
#  MAKECMD         - This is the command used to invoke the make utility
#  HOST            - What platform this template makefile is targeted for
#                    (i.e. PC or UNIX)
#  BUILD           - Invoke make from the build procedure (yes/no)?
#  SYS_TARGET_FILE - Name of system target file.

MAKECMD         = /usr/local/MATLAB/R2024a/bin/glnxa64/gmake
HOST            = UNIX
BUILD           = yes
SYS_TARGET_FILE = mttarget.tlc

# Opt in to simplified format by specifying compatible Toolchain
TOOLCHAIN_NAME = ["Clang v3.1 | gmake (64-bit Mac)", \
             "GNU gcc/g++ | gmake (64-bit Linux)"]

#---------------------- Tokens expanded by make_rtw ----------------------------
#
# The following tokens, when wrapped with "|>" and "<|" are expanded by the
# build procedure.
#
#  MODEL_NAME          - Name of the Simulink block diagram
#  MODEL_MODULES       - Any additional generated source modules
#  MAKEFILE_NAME       - Name of makefile created from template makefile <model>.mk
#  MATLAB_ROOT         - Path to where MATLAB is installed.
#  S_FUNCTIONS_LIB     - List of S-functions libraries to link.
#  NUMST               - Number of sample times
#  TID01EQ             - yes (1) or no (0): Are sampling rates of continuous task
#                        (tid=0) and 1st discrete task equal.
#  NCSTATES            - Number of continuous states
#  COMPUTER            - Computer type. See the MATLAB computer command.
#  BUILDARGS           - Options passed in at the command line.
#  MULTITASKING        - yes (1) or no (0): Is solver mode multitasking
#  MAT_FILE            - yes (1) or no (0): Should mat file logging be done
#  GEN_MDLREF_SFCN     - (1/0): are we generating model reference wrapper s-function
#  TGT_FCN_LIB         - Target Funtion library to use
#  MODELREFS           - List of referenced models

MODEL                = LAFES
MODULES              = rt_matrx.c rt_printf.c rt_logging.c LAFES.c LAFES_data.c rtGetInf.c rtGetNaN.c rt_nonfinite.c Rs485EthercatLibrary.c ethercatbase.c ethercatcoe.c ethercatconfig.c ethercatdc.c ethercatfoe.c ethercatmain.c ethercatprint.c ethercatsoe.c nicdrv.c osal.c oshw.c timer_posix.c timer_stats.c rt_main.c ext_svr.c updown.c ext_work.c rtiostream_interface.c rtiostream_tcpip.c rtiostream_utils.c ec_EPOS4_i.c ec_EPOS4_o.c ec_EtherCAT_interface.c
PRODUCT              = $(RELATIVE_PATH_TO_ANCHOR)/LAFES
MAKEFILE             = LAFES.mk
MATLAB_ROOT          = /usr/local/MATLAB/R2024a
ALT_MATLAB_ROOT      = /usr/local/MATLAB/R2024a
MATLAB_BIN           = /usr/local/MATLAB/R2024a/bin
START_DIR            = /home/robocup/Turtle3/LAFES/LAFES-Internship/2024a
S_FUNCTIONS_LIB      = 
NUMST                = 2
TID01EQ              = 1
NCSTATES             = 0
COMPUTER             = GLNXA64
BUILDARGS            = CC="ccache gcc" OPTS="-DEXT_MODE -DON_TARGET_WAIT_FOR_START=1 -DTID01EQ=1 -DNETIF_ID=0 -DTEST_CONN_MODEL -D_GNU_SOURCE -DPRIO=99" EXTMODE_STATIC_ALLOC=0 TMW_EXTMODE_TESTING=0 EXTMODE_STATIC_ALLOC_SIZE=1000000 EXTMODE_TRANSPORT=0 INCLUDE_MDL_TERMINATE_FCN=1
MULTITASKING         = 0
MAT_FILE             = 1
TGT_FCN_LIB          = GNU
MODELREFS            = 
TARGET_LANG_EXT      = c
OPTIMIZATION_FLAGS   = -O2 -g -W
ADDITIONAL_LDFLAGS   = 
DEFINES_CUSTOM       = 
DEFINES_OTHER        = -DHAVESTDIO -DRT -DUSE_RTMODEL
COMPILE_FLAGS_OTHER  = 
SYSTEM_LIBS          = 
CODE_INTERFACE_PACKAGING = Nonreusable function

CLASSIC_INTERFACE    = 0
# Optional for GRT
ALLOCATIONFCN        = 0
ONESTEPFCN           = 1
TERMFCN              = 1
MULTI_INSTANCE_CODE  = 0

# To enable debugging:
# set DEBUG_BUILD = 1
DEBUG_BUILD          = 0

#--------------------------- Model and reference models -----------------------
MODELLIB                  = 
MODELREF_LINK_LIBS        = 
RELATIVE_PATH_TO_ANCHOR   = ..
# NONE: standalone, SIM: modelref sim, RTW: modelref coder target
MODELREF_TARGET_TYPE       = NONE

#-- In the case when directory name contains space ---
ifneq ($(MATLAB_ROOT),$(ALT_MATLAB_ROOT))
MATLAB_ROOT := $(ALT_MATLAB_ROOT)
endif

#--------------------------- Tool Specifications -------------------------------

include $(MATLAB_ROOT)/rtw/c/tools/unixtools.mk

# By default, the language standard is set to C99. However, we require a newer
# version, e.g. C17.
ANSI_OPTS:=$(subst -std=c99,-std=c17,$(ANSI_OPTS))
# Disable pedantic warnings
ANSI_OPTS:=$(subst -pedantic ,,$(ANSI_OPTS))

# "Temporarily" remove a massive amount of maybe-uninitialized warnings when
# building motion.c. According to @jkon and @fschoen, fixing the warnings is
# low priority, and the warnings can also be disabled.
ANSI_OPTS:=$(subst -std=c17,-std=c17 -Wno-maybe-uninitialized,$(ANSI_OPTS))

#------------------------------ Include Path -----------------------------------

# Additional file include paths
ADD_INCLUDES = \
	-I$(START_DIR) \
	-I$(START_DIR)/LAFES_grt_rtw \
	-I$(START_DIR)/S_Functions \
	-I$(MATLAB_ROOT)/extern/include \
	-I$(MATLAB_ROOT)/simulink/include \
	-I$(MATLAB_ROOT)/rtw/c/src \
	-I$(MATLAB_ROOT)/rtw/c/src/ext_mode/common \
	-I$(MATLAB_ROOT)/toolbox/coder/rtiostream/src \
	-I$(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip \
	-I$(MATLAB_ROOT)/toolbox/coder/rtiostream/src/utils \
	-I/home/robocup/Turtle3/Libs/Simulink/Ethercat \


INCLUDES = -I. -I$(RELATIVE_PATH_TO_ANCHOR) $(ADD_INCLUDES) $(USER_INCLUDES) \
	$(INSTRUMENT_INCLUDES)

#----------------------------- Real-Time Model ---------------------------------
RTM_CC_OPTS = -DUSE_RTMODEL

#-------------------------------- C Flags --------------------------------------

# Optimization Options
ifndef OPT_OPTS
OPT_OPTS = $(DEFAULT_OPT_OPTS)
endif

# General User Options
ifeq ($(DEBUG_BUILD),0)
DBG_FLAG =
else
#   Set OPTS=-g and any additional flags for debugging
DBG_FLAG = -g
LDFLAGS += -g
endif

LDFLAGS += -Wl,-rpath,"$(MATLAB_ROOT)/bin/$(ARCH)" -L"$(MATLAB_ROOT)/bin/$(ARCH)"

# Compiler options, etc:
ifneq ($(OPTIMIZATION_FLAGS),)
CC_OPTS = $(OPTS) $(COMPILE_FLAGS_OTHER) $(RTM_CC_OPTS) $(OPTIMIZATION_FLAGS)
else
CC_OPTS = $(OPTS) $(COMPILE_FLAGS_OTHER) $(OPT_OPTS) $(RTM_CC_OPTS)
endif


CPP_REQ_DEFINES = -DMODEL=$(MODEL) -DNUMST=$(NUMST) \
                  -DTID01EQ=$(TID01EQ) -DNCSTATES=$(NCSTATES) -DUNIX \
                  -DMT=$(MULTITASKING) -DHAVESTDIO -DMAT_FILE=$(MAT_FILE) \
		  -DONESTEPFCN=$(ONESTEPFCN) -DTERMFCN=$(TERMFCN) \
		  -DMULTI_INSTANCE_CODE=$(MULTI_INSTANCE_CODE) \
		  -DCLASSIC_INTERFACE=$(CLASSIC_INTERFACE) \
		  -DALLOCATIONFCN=$(ALLOCATIONFCN)


DEFINES = $(DEFINES_CUSTOM) $(CPP_REQ_DEFINES) $(DEFINES_OTHER)
CFLAGS   = $(ANSI_OPTS) $(DBG_FLAG) $(CC_OPTS) $(DEFINES) $(INCLUDES)
CPPFLAGS = $(CPP_ANSI_OPTS) $(DBG_FLAG) $(CPP_OPTS) $(CC_OPTS) $(DEFINES) $(INCLUDES)
#-------------------------- Additional Libraries ------------------------------

SYSTEM_LIBS += -lm -pthread

LIBS =
 
LIBS += $(S_FUNCTIONS_LIB) $(INSTRUMENT_LIBS)

#----------------------------- Source Files ------------------------------------

USER_SRCS = ${ROBOCUP_REPO_PATH}/Targets/mttarget/mt_main.c

USER_OBJS       = $(addsuffix .o, $(basename $(USER_SRCS)))
LOCAL_USER_OBJS = $(notdir $(USER_OBJS))

# This is a robocup hack to filter out default rt_main.c and force our mt_main.c
SRCS = $(MODULES:rt_main.c=)

OBJS      = $(addsuffix .o, $(basename $(SRCS))) $(USER_OBJS)
LINK_OBJS = $(addsuffix .o, $(basename $(SRCS))) $(LOCAL_USER_OBJS)

ADDITIONAL_LDFLAGS += $(ARCH_SPECIFIC_LDFLAGS)

#------------- Test Compile using gcc -Wall to look for warnings ---------------
#
# DO_GCC_TEST=1 runs gcc with compiler warning flags on all the source files
# used in this build. This includes the generated code, and any user source
# files needed for the build and placed in this directory.
#
# WARN_ON_GLNX=1 runs the linux compiler with warnings flags. On hand-written
# code we use the max amount of flags availabe while on the generated code, a
# few less.
#
# See rtw/c/tools/unixtools.mk for the definition of GCC_WARN_OPTS
GCC_TEST_CMD  := echo
GCC_TEST_OUT  := > /dev/null
ifeq ($(DO_GCC_TEST), 1)
  GCC_TEST := gcc -c -o /dev/null $(GCC_WARN_OPTS_MAX) $(CPP_REQ_DEFINES) \
                                     $(INCLUDES)
  GCC_TEST_CMD := echo; echo "\#\#\# GCC_TEST $(GCC_TEST) $<"; $(GCC_TEST)
  GCC_TEST_OUT := ; echo
endif

#--------------------------------- Rules ---------------------------------------
ifeq ($(MODELREF_TARGET_TYPE),NONE)
  BIN_SETTING        = $(LD) $(LDFLAGS) -o $(PRODUCT)
$(PRODUCT) : $(OBJS) $(LIBS) $(MODELREF_LINK_LIBS)
	$(BIN_SETTING) $(LINK_OBJS) $(MODELREF_LINK_LIBS) $(LIBS) $(ADDITIONAL_LDFLAGS) $(SYSTEM_LIBS)
	@echo "### Created $(BUILD_PRODUCT_TYPE): $@"
else
$(PRODUCT) : $(OBJS)
	@rm -f $(MODELLIB)
	$(AR) ruvs $(MODELLIB) $(LINK_OBJS)
	@echo "### Created $(MODELLIB)"
	@echo "### Created $(BUILD_PRODUCT_TYPE): $@"
endif

%.o : %.c
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG) "$<"

%.o : %.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) $(GCC_WALL_FLAG) "$<"

%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.c
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG) "$<"

%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) "$<"

%.o : /home/robocup/Turtle3/Libs/Simulink/Ethercat/%.c
ifeq ($(notdir $<),rt_logging.c)
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) "$<"
else
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) "$<"
endif

%.o : $(START_DIR)/S_Functions/%.c
ifeq ($(notdir $<),rt_logging.c)
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) "$<"
else
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) "$<"
endif

%.o : $(MATLAB_ROOT)/rtw/c/src/%.c
ifeq ($(notdir $<),rt_logging.c)
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) "$<"
else
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) "$<"
endif

%.o : $(MATLAB_ROOT)/simulink/src/%.c
ifeq ($(notdir $<),rt_logging.c)
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) "$<"
else
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) "$<"
endif

%.o : $(MATLAB_ROOT)/toolbox/simulink/blocks/src/%.c
ifeq ($(notdir $<),rt_logging.c)
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) "$<"
else
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) "$<"
endif

%.o : $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/%.c
ifeq ($(notdir $<),rt_logging.c)
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) "$<"
else
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) "$<"
endif

%.o : $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/%.c
ifeq ($(notdir $<),rt_logging.c)
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) "$<"
else
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) "$<"
endif

%.o : $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/utils/%.c
ifeq ($(notdir $<),rt_logging.c)
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) "$<"
else
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) "$<"
endif

rt_matrx.o : $(MATLAB_ROOT)/rtw/c/src/rt_matrx.c
ifeq ($(notdir $(MATLAB_ROOT)/rtw/c/src/rt_matrx.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/rt_matrx.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/rt_matrx.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/rt_matrx.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/rt_matrx.c
endif

rt_printf.o : $(MATLAB_ROOT)/rtw/c/src/rt_printf.c
ifeq ($(notdir $(MATLAB_ROOT)/rtw/c/src/rt_printf.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/rt_printf.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/rt_printf.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/rt_printf.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/rt_printf.c
endif

rt_logging.o : $(MATLAB_ROOT)/rtw/c/src/rt_logging.c
ifeq ($(notdir $(MATLAB_ROOT)/rtw/c/src/rt_logging.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/rt_logging.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/rt_logging.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/rt_logging.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/rt_logging.c
endif

Rs485EthercatLibrary.o : $(START_DIR)/S_Functions/Rs485EthercatLibrary.c
ifeq ($(notdir $(START_DIR)/S_Functions/Rs485EthercatLibrary.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/Rs485EthercatLibrary.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/Rs485EthercatLibrary.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/Rs485EthercatLibrary.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/Rs485EthercatLibrary.c
endif

ethercatbase.o : $(START_DIR)/S_Functions/ethercatbase.c
ifeq ($(notdir $(START_DIR)/S_Functions/ethercatbase.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatbase.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatbase.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatbase.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatbase.c
endif

ethercatcoe.o : $(START_DIR)/S_Functions/ethercatcoe.c
ifeq ($(notdir $(START_DIR)/S_Functions/ethercatcoe.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatcoe.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatcoe.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatcoe.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatcoe.c
endif

ethercatconfig.o : $(START_DIR)/S_Functions/ethercatconfig.c
ifeq ($(notdir $(START_DIR)/S_Functions/ethercatconfig.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatconfig.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatconfig.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatconfig.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatconfig.c
endif

ethercatdc.o : $(START_DIR)/S_Functions/ethercatdc.c
ifeq ($(notdir $(START_DIR)/S_Functions/ethercatdc.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatdc.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatdc.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatdc.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatdc.c
endif

ethercatfoe.o : $(START_DIR)/S_Functions/ethercatfoe.c
ifeq ($(notdir $(START_DIR)/S_Functions/ethercatfoe.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatfoe.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatfoe.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatfoe.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatfoe.c
endif

ethercatmain.o : $(START_DIR)/S_Functions/ethercatmain.c
ifeq ($(notdir $(START_DIR)/S_Functions/ethercatmain.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatmain.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatmain.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatmain.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatmain.c
endif

ethercatprint.o : $(START_DIR)/S_Functions/ethercatprint.c
ifeq ($(notdir $(START_DIR)/S_Functions/ethercatprint.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatprint.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatprint.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatprint.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatprint.c
endif

ethercatsoe.o : $(START_DIR)/S_Functions/ethercatsoe.c
ifeq ($(notdir $(START_DIR)/S_Functions/ethercatsoe.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatsoe.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatsoe.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/ethercatsoe.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/ethercatsoe.c
endif

nicdrv.o : $(START_DIR)/S_Functions/nicdrv.c
ifeq ($(notdir $(START_DIR)/S_Functions/nicdrv.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/nicdrv.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/nicdrv.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/nicdrv.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/nicdrv.c
endif

osal.o : $(START_DIR)/S_Functions/osal.c
ifeq ($(notdir $(START_DIR)/S_Functions/osal.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/osal.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/osal.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/osal.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/osal.c
endif

oshw.o : $(START_DIR)/S_Functions/oshw.c
ifeq ($(notdir $(START_DIR)/S_Functions/oshw.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/oshw.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/oshw.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/oshw.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/oshw.c
endif

timer_posix.o : $(START_DIR)/S_Functions/timer_posix.c
ifeq ($(notdir $(START_DIR)/S_Functions/timer_posix.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/timer_posix.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/timer_posix.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/timer_posix.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/timer_posix.c
endif

timer_stats.o : $(START_DIR)/S_Functions/timer_stats.c
ifeq ($(notdir $(START_DIR)/S_Functions/timer_stats.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/timer_stats.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/timer_stats.c
else
	@$(GCC_TEST_CMD) $(START_DIR)/S_Functions/timer_stats.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(START_DIR)/S_Functions/timer_stats.c
endif

rt_main.o : $(MATLAB_ROOT)/rtw/c/src/common/rt_main.c
ifeq ($(notdir $(MATLAB_ROOT)/rtw/c/src/common/rt_main.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/common/rt_main.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/common/rt_main.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/common/rt_main.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/common/rt_main.c
endif

ext_svr.o : $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_svr.c
ifeq ($(notdir $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_svr.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_svr.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_svr.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_svr.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_svr.c
endif

updown.o : $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/updown.c
ifeq ($(notdir $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/updown.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/updown.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/updown.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/updown.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/updown.c
endif

ext_work.o : $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_work.c
ifeq ($(notdir $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_work.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_work.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_work.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_work.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/ext_work.c
endif

rtiostream_interface.o : $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/rtiostream_interface.c
ifeq ($(notdir $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/rtiostream_interface.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/rtiostream_interface.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/rtiostream_interface.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/rtiostream_interface.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/rtiostream_interface.c
endif

rtiostream_tcpip.o : $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c
ifeq ($(notdir $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/rtiostream_tcpip.c
endif

rtiostream_utils.o : $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/utils/rtiostream_utils.c
ifeq ($(notdir $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/utils/rtiostream_utils.c),rt_logging.c)
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/utils/rtiostream_utils.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/utils/rtiostream_utils.c
else
	@$(GCC_TEST_CMD) $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/utils/rtiostream_utils.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/utils/rtiostream_utils.c
endif

ec_EPOS4_i.o : /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_i.c
ifeq ($(notdir /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_i.c),rt_logging.c)
	@$(GCC_TEST_CMD) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_i.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_i.c
else
	@$(GCC_TEST_CMD) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_i.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_i.c
endif

ec_EPOS4_o.o : /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_o.c
ifeq ($(notdir /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_o.c),rt_logging.c)
	@$(GCC_TEST_CMD) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_o.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_o.c
else
	@$(GCC_TEST_CMD) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_o.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EPOS4_o.c
endif

ec_EtherCAT_interface.o : /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EtherCAT_interface.c
ifeq ($(notdir /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EtherCAT_interface.c),rt_logging.c)
	@$(GCC_TEST_CMD) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EtherCAT_interface.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) -Wno-unused-result $(GCC_WALL_FLAG_MAX) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EtherCAT_interface.c
else
	@$(GCC_TEST_CMD) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EtherCAT_interface.c $(GCC_TEST_OUT)
	$(CC) -c $(CFLAGS) $(GCC_WALL_FLAG_MAX) /home/robocup/Turtle3/Libs/Simulink/Ethercat/ec_EtherCAT_interface.c
endif



%.o : /home/robocup/Turtle3/Libs/Simulink/Ethercat/%.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) "$<"
%.o : $(START_DIR)/S_Functions/%.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) "$<"
%.o : $(MATLAB_ROOT)/rtw/c/src/%.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) "$<"
%.o : $(MATLAB_ROOT)/simulink/src/%.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) "$<"
%.o : $(MATLAB_ROOT)/toolbox/simulink/blocks/src/%.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) "$<"
%.o : $(MATLAB_ROOT)/rtw/c/src/ext_mode/common/%.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) "$<"
%.o : $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/rtiostreamtcpip/%.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) "$<"
%.o : $(MATLAB_ROOT)/toolbox/coder/rtiostream/src/utils/%.cpp
	@$(GCC_TEST_CMD) "$<" $(GCC_TEST_OUT)
	$(CPP) -c $(CPPFLAGS) "$<"


#------------------------------- Libraries -------------------------------------





#----------------------------- Dependencies ------------------------------------

$(OBJS) : $(MAKEFILE) rtw_proj.tmw
