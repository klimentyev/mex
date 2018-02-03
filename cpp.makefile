MATLAB_DIR = /opt/MATLAB

OBJ_DIR    = obj
BIN_DIR    = .

TARGET_NAME = gatewayCpp
TARGET      = $(TARGET_NAME).$(EXT)

RM          = rm

# compiles mex files using g++
CXX = g++
LD  = g++

# compiler flags for g++
CFLAGS = -O3 -fpic -fno-omit-frame-pointer -pthread -Wall
CXXFLAGS = $(CFLAGS)

CPPFLAGS  = -MMD -MP

# to use the intel compiler instead, uncomment CC and CCFLAGS below:

# compiles mex file using the intel compiler
# CC = icpc

# compiler flags for intel compiler
# CCFLAGS = -O3 -fPIC -D__amd64

# Figure out which platform we're on
UNAME = $(shell uname -s)

# Linux
ifeq ($(findstring Linux,${UNAME}), Linux)
	# define which files to be included
	CINCLUDE = $(MATLAB_DIR)/extern/include
	LDFLAGS= -pthread -Wl,--no-undefined -Wl,-rpath-link,$(MATLAB_DIR)/bin/glnxa64 -shared -L$(MATLAB_DIR)/bin/glnxa64 -lmx -lmex -lmat -lm -lstdc++
	# define extension
	EXT = mexa64
endif

# Mac OS X
ifeq ($(findstring Darwin,${UNAME}), Darwin)
	# define which files to be included
	CINCLUDE = -L$(MATLAB_DIR)/bin/maci64
	LDFLAGS= -pthread -Wl,--no-undefined -Wl,-rpath-link,$(MATLAB_DIR)/bin/maci64 -shared -L$(MATLAB_DIR)/bin/maci64 -lmx -lmex -lmat -lm -lstdc++
	# define extension
	EXT = mexmaci64
	CCFLAGS += -std=c++11
endif

MEX_SRC += c++/fibonacci.cpp
MEX_SRC += c++/gatewayCpp.cpp

CINCLUDE += c++

CPPFLAGS += $(addprefix -I,$(CINCLUDE))

OBJECTS = $(addprefix $(OBJ_DIR)/,$(notdir $(MEX_SRC:.cpp=.o)))

all:   build

build: $(BIN_DIR)/$(TARGET)

$(BIN_DIR)/$(TARGET): $(OBJECTS)
	$(LD) $(OBJECTS) $(LDFLAGS) -o $@

$(OBJ_DIR)/%.o: %.cpp | dir
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@

dir:
	mkdir -p $(OBJ_DIR)

clean:
	$(RM) -rf $(OBJ_DIR) $(BIN_DIR)/$(TARGET)


vpath %.cpp $(sort $(dir $(MEX_SRC)))

-include $(OBJECTS:.o=.d)
