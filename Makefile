################################################################################
# Default Target
################################################################################
all: growth growth_cuda

################################################################################
# Conditional Flags
################################################################################
CUSEHDF5 = no
CPMETRICS = no

# Stopgap approach for selecting model types, until parameter file selection
# is implemented. Uncomment each of NEURONTYPE, SYNAPSETYPE, and CONNTYPE
NEURONTYPE = "AllIZHNeurons"
# NEURONTYPE = "AllLIFNeurons"

SYNAPSETYPE = "AllSpikingSynapses"
#SYNAPSETYPE = "AllDSSynapses"
#SYNAPSETYPE = "AllSTDPSynapses"
#SYNAPSETYPE = "AllDynamicSTDPSynapses"

CONNTYPE = "ConnStatic"
#CONNTYPE = "ConnGrowth"

MODELFLAGS = -DNEURONTYPE=$(NEURONTYPE) -DSYNAPSETYPE=$(SYNAPSETYPE) -DCONNTYPE=$(CONNTYPE)

################################################################################
# Source Directories
################################################################################
MAIN = .
CUDADIR = $(MAIN)/cuda
COMMDIR = $(MAIN)/common
MATRIXDIR = $(MAIN)/matrix
PARAMDIR = $(MAIN)/paramcontainer
RNGDIR = $(MAIN)/rng
XMLDIR = $(MAIN)/tinyxml
SINPUTDIR = $(MAIN)/sinput
ifeq ($(CUSEHDF5), yes)
	H5INCDIR = /opt/hdf5/latest/include
else
	H5INCDIR =
endif

################################################################################
# Build tools
################################################################################
CXX = g++
LD = g++
OPT = g++ 

################################################################################
# Flags
################################################################################
ifeq ($(CPMETRICS), yes)
	PMFLAGS = -DPERFORMANCE_METRICS
else
	PMFLAGS = 
endif
ifeq ($(CUSEHDF5), yes)
	LH5FLAGS =  -L/opt/hdf5/latest/lib -lhdf5_hl_cpp -lhdf5_cpp -lhdf5_hl -lhdf5 -lsz
	H5FLAGS = -DUSE_HDF5
else
	LH5FLAGS =
	H5FLAGS = 
endif
CXXFLAGS = -O2 -s -I$(COMMDIR) -I$(H5INCDIR) -I$(MATRIXDIR) -I$(PARAMDIR) -I$(RNGDIR) -I$(XMLDIR) -I$(SINPUTDIR) -Wall -g -pg -c -DTIXML_USE_STL -DDEBUG_OUT $(PMFLAGS) $(H5FLAGS) $(MODELFLAGS)
CGPUFLAGS = -DUSE_GPU $(PMFLAGS) $(H5FLAGS)
LDFLAGS = -lstdc++ 
LGPUFLAGS = -L/usr/local/cuda/lib64 -lcuda -lcudart

################################################################################
# Objects
################################################################################

CUDAOBJS =   \
	    $(CUDADIR)/GPUSpikingModel.o \
            $(CUDADIR)/AllNeurons_cuda.o \
            $(CUDADIR)/AllSpikingNeurons_cuda.o \
            $(CUDADIR)/AllSpikingNeurons_d.o \
            $(CUDADIR)/AllIFNeurons_cuda.o \
            $(CUDADIR)/AllIFNeurons_d.o \
            $(CUDADIR)/AllLIFNeurons_cuda.o \
            $(CUDADIR)/AllLIFNeurons_d.o \
            $(CUDADIR)/AllIZHNeurons_cuda.o \
            $(CUDADIR)/AllIZHNeurons_d.o \
            $(CUDADIR)/AllSynapses_cuda.o \
            $(CUDADIR)/AllSpikingSynapses_cuda.o \
            $(CUDADIR)/AllSpikingSynapses_d.o \
            $(CUDADIR)/AllDSSynapses_cuda.o \
            $(CUDADIR)/AllDSSynapses_d.o \
            $(CUDADIR)/AllSTDPSynapses_cuda.o \
            $(CUDADIR)/AllSTDPSynapses_d.o \
            $(CUDADIR)/AllDynamicSTDPSynapses_cuda.o \
            $(CUDADIR)/AllDynamicSTDPSynapses_d.o \
            $(CUDADIR)/Connections_cuda.o \
            $(CUDADIR)/ConnGrowth_cuda.o \
            $(CUDADIR)/ConnStatic_cuda.o \
            $(CUDADIR)/ConnGrowth_d.o \
            $(CUDADIR)/MersenneTwister_kernel.o \
            $(CUDADIR)/BGDriver_cuda.o \
            $(SINPUTDIR)/GpuSInputRegular.o \
            $(SINPUTDIR)/GpuSInputPoisson.o \
            $(SINPUTDIR)/FSInput_cuda.o \
            $(CUDADIR)/FClassOfCategory_cuda.o \
            $(CUDADIR)/Global_cuda.o

ifeq ($(CUSEHDF5), yes)
LIBOBJS =               \
			$(COMMDIR)/Simulator.o \
			$(COMMDIR)/Model.o \
			$(COMMDIR)/Layout.o \
			$(COMMDIR)/ParseParamError.o \
			$(COMMDIR)/Timer.o \
			$(COMMDIR)/Util.o \
			$(COMMDIR)/XmlRecorder.o \
			$(COMMDIR)/XmlGrowthRecorder.o \
			$(COMMDIR)/Hdf5Recorder.o \
			$(COMMDIR)/Hdf5GrowthRecorder.o 
else
LIBOBJS =               \
			$(COMMDIR)/Simulator.o \
			$(COMMDIR)/Model.o \
			$(COMMDIR)/Layout.o \
			$(COMMDIR)/ParseParamError.o \
			$(COMMDIR)/Timer.o \
			$(COMMDIR)/Util.o \
			$(COMMDIR)/XmlRecorder.o \
			$(COMMDIR)/XmlGrowthRecorder.o 
endif
 
		
MATRIXOBJS = $(MATRIXDIR)/CompleteMatrix.o \
				$(MATRIXDIR)/Matrix.o \
				$(MATRIXDIR)/SparseMatrix.o \
				$(MATRIXDIR)/VectorMatrix.o \

PARAMOBJS = $(PARAMDIR)/ParamContainer.o
		
RNGOBJS = $(RNGDIR)/Norm.o

SINGLEOBJS = $(MAIN)/BGDriver.o  \
			$(COMMDIR)/SingleThreadedSpikingModel.o \
			$(SINPUTDIR)/FSInput.o \
			$(COMMDIR)/FClassOfCategory.o \
			$(COMMDIR)/AllNeurons.o \
			$(COMMDIR)/AllSpikingNeurons.o \
			$(COMMDIR)/AllIFNeurons.o \
			$(COMMDIR)/AllLIFNeurons.o \
			$(COMMDIR)/AllIZHNeurons.o \
			$(COMMDIR)/AllSynapses.o \
			$(COMMDIR)/AllSpikingSynapses.o \
			$(COMMDIR)/AllDSSynapses.o \
			$(COMMDIR)/AllSTDPSynapses.o \
			$(COMMDIR)/AllDynamicSTDPSynapses.o \
			$(COMMDIR)/Connections.o \
			$(COMMDIR)/ConnGrowth.o \
			$(COMMDIR)/ConnStatic.o \
			$(COMMDIR)/Global.o 

XMLOBJS = $(XMLDIR)/tinyxml.o \
			$(XMLDIR)/tinyxmlparser.o \
			$(XMLDIR)/tinyxmlerror.o \
			$(XMLDIR)/tinystr.o

SINPUTOBJS = $(SINPUTDIR)/HostSInputRegular.o \
			$(SINPUTDIR)/SInputRegular.o \
			$(SINPUTDIR)/HostSInputPoisson.o \
			$(SINPUTDIR)/SInputPoisson.o 

################################################################################
# Targets
################################################################################
growth: $(LIBOBJS) $(MATRIXOBJS) $(PARAMOBJS) $(RNGOBJS) $(SINGLEOBJS) $(XMLOBJS) $(SINPUTOBJS)
	$(LD) -o growth -g $(LDFLAGS) $(LIBOBJS) $(LH5FLAGS) $(MATRIXOBJS) $(PARAMOBJS) $(RNGOBJS) $(SINGLEOBJS) $(XMLOBJS) $(SINPUTOBJS)

growth_cuda:$(LIBOBJS) $(MATRIXOBJS) $(PARAMOBJS) $(RNGOBJS) $(XMLOBJS) $(OTHEROBJS) $(CUDAOBJS) $(SINPUTOBJS)
	nvcc -o growth_cuda -g -arch=sm_20 -rdc=true $(LDFLAGS) $(LH5FLAGS) $(LGPUFLAGS) $(LIBOBJS) $(CUDAOBJS) $(MATRIXOBJS) $(PARAMOBJS) $(RNGOBJS) $(XMLOBJS) $(OTHEROBJS) $(SINPUTOBJS)

clean:
	rm -f $(MAIN)/*.o $(COMMDIR)/*.o $(MATRIXDIR)/*.o $(PARAMDIR)/*.o $(RNGDIR)/*.o $(XMLDIR)/*.o $(CUDADIR)/*.o $(SINPUTDIR)/*.o ./growth
	

################################################################################
# Build Source Files
################################################################################

# CUDA
# ------------------------------------------------------------------------------
$(CUDADIR)/MersenneTwister_kernel.o: $(CUDADIR)/MersenneTwister_kernel.cu $(COMMDIR)/Global.h $(CUDADIR)/MersenneTwister.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/MersenneTwister_kernel.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/MersenneTwister_kernel.o


$(CUDADIR)/GPUSpikingModel.o: $(CUDADIR)/GPUSpikingModel.cu $(COMMDIR)/Global.h $(CUDADIR)/GPUSpikingModel.h $(COMMDIR)/AllIFNeurons.h $(COMMDIR)/AllSynapses.h $(COMMDIR)/IModel.h  
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/GPUSpikingModel.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/GPUSpikingModel.o

$(CUDADIR)/AllSpikingNeurons_d.o: $(CUDADIR)/AllSpikingNeurons_d.cu $(COMMDIR)/Global.h $(COMMDIR)/AllSpikingNeurons.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/AllSpikingNeurons_d.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/AllSpikingNeurons_d.o

$(CUDADIR)/AllIFNeurons_d.o: $(CUDADIR)/AllIFNeurons_d.cu $(COMMDIR)/Global.h $(COMMDIR)/AllIFNeurons.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/AllIFNeurons_d.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/AllIFNeurons_d.o

$(CUDADIR)/AllLIFNeurons_d.o: $(CUDADIR)/AllLIFNeurons_d.cu $(COMMDIR)/Global.h $(COMMDIR)/AllLIFNeurons.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/AllLIFNeurons_d.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/AllLIFNeurons_d.o

$(CUDADIR)/AllIZHNeurons_d.o: $(CUDADIR)/AllIZHNeurons_d.cu $(COMMDIR)/Global.h $(COMMDIR)/AllIZHNeurons.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/AllIZHNeurons_d.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/AllIZHNeurons_d.o

$(CUDADIR)/AllSpikingSynapses_d.o: $(CUDADIR)/AllSpikingSynapses_d.cu $(COMMDIR)/Global.h $(COMMDIR)/AllSpikingSynapses.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/AllSpikingSynapses_d.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/AllSpikingSynapses_d.o

$(CUDADIR)/AllDSSynapses_d.o: $(CUDADIR)/AllDSSynapses_d.cu $(COMMDIR)/Global.h $(COMMDIR)/AllDSSynapses.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/AllDSSynapses_d.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/AllDSSynapses_d.o

$(CUDADIR)/AllSTDPSynapses_d.o: $(CUDADIR)/AllSTDPSynapses_d.cu $(COMMDIR)/Global.h $(COMMDIR)/AllSTDPSynapses.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/AllSTDPSynapses_d.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/AllSTDPSynapses_d.o

$(CUDADIR)/AllDynamicSTDPSynapses_d.o: $(CUDADIR)/AllDynamicSTDPSynapses_d.cu $(COMMDIR)/Global.h $(COMMDIR)/AllDynamicSTDPSynapses.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/AllDynamicSTDPSynapses_d.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/AllDynamicSTDPSynapses_d.o

$(CUDADIR)/ConnGrowth_d.o: $(CUDADIR)/ConnGrowth_d.cu $(COMMDIR)/Global.h $(COMMDIR)/ConnGrowth.h
	nvcc -c -g -arch=sm_20 -rdc=true $(CUDADIR)/ConnGrowth_d.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(MATRIXDIR) -o $(CUDADIR)/ConnGrowth_d.o

$(CUDADIR)/BGDriver_cuda.o: $(MAIN)/BGDriver.cpp $(COMMDIR)/Global.h $(COMMDIR)/IModel.h $(COMMDIR)/AllIFNeurons.h $(COMMDIR)/AllSynapses.h 
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) -I$(CUDADIR) -c $(MAIN)/BGDriver.cpp -o $(CUDADIR)/BGDriver_cuda.o

$(CUDADIR)/AllNeurons_cuda.o: $(COMMDIR)/AllNeurons.cpp $(COMMDIR)/AllNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllNeurons.cpp -o $(CUDADIR)/AllNeurons_cuda.o
	
$(CUDADIR)/AllSpikingNeurons_cuda.o: $(COMMDIR)/AllSpikingNeurons.cpp $(COMMDIR)/AllSpikingNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllSpikingNeurons.cpp -o $(CUDADIR)/AllSpikingNeurons_cuda.o
        
$(CUDADIR)/AllIFNeurons_cuda.o: $(COMMDIR)/AllIFNeurons.cpp $(COMMDIR)/AllIFNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllIFNeurons.cpp -o $(CUDADIR)/AllIFNeurons_cuda.o
	
$(CUDADIR)/AllLIFNeurons_cuda.o: $(COMMDIR)/AllLIFNeurons.cpp $(COMMDIR)/AllLIFNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllLIFNeurons.cpp -o $(CUDADIR)/AllLIFNeurons_cuda.o
	
$(CUDADIR)/AllIZHNeurons_cuda.o: $(COMMDIR)/AllIZHNeurons.cpp $(COMMDIR)/AllIZHNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllIZHNeurons.cpp -o $(CUDADIR)/AllIZHNeurons_cuda.o
	
$(CUDADIR)/AllSynapses_cuda.o: $(COMMDIR)/AllSynapses.cpp $(COMMDIR)/AllSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllSynapses.cpp -o $(CUDADIR)/AllSynapses_cuda.o

$(CUDADIR)/AllSpikingSynapses_cuda.o: $(COMMDIR)/AllSpikingSynapses.cpp $(COMMDIR)/AllSpikingSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllSpikingSynapses.cpp -o $(CUDADIR)/AllSpikingSynapses_cuda.o

$(CUDADIR)/AllDSSynapses_cuda.o: $(COMMDIR)/AllDSSynapses.cpp $(COMMDIR)/AllDSSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllDSSynapses.cpp -o $(CUDADIR)/AllDSSynapses_cuda.o

$(CUDADIR)/AllSTDPSynapses_cuda.o: $(COMMDIR)/AllSTDPSynapses.cpp $(COMMDIR)/AllSTDPSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllSTDPSynapses.cpp -o $(CUDADIR)/AllSTDPSynapses_cuda.o

$(CUDADIR)/AllDynamicSTDPSynapses_cuda.o: $(COMMDIR)/AllDynamicSTDPSynapses.cpp $(COMMDIR)/AllDynamicSTDPSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/AllDynamicSTDPSynapses.cpp -o $(CUDADIR)/AllDynamicSTDPSynapses_cuda.o

$(CUDADIR)/Connections_cuda.o: $(COMMDIR)/Connections.cpp $(COMMDIR)/Connections.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/Connections.cpp -o $(CUDADIR)/Connections_cuda.o

$(CUDADIR)/ConnGrowth_cuda.o: $(COMMDIR)/ConnGrowth.cpp $(COMMDIR)/ConnGrowth.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/ConnGrowth.cpp -o $(CUDADIR)/ConnGrowth_cuda.o

$(CUDADIR)/ConnStatic_cuda.o: $(COMMDIR)/ConnStatic.cpp $(COMMDIR)/ConnStatic.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/ConnStatic.cpp -o $(CUDADIR)/ConnStatic_cuda.o

$(CUDADIR)/Global_cuda.o: $(COMMDIR)/Global.cpp $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/Global.cpp -o $(CUDADIR)/Global_cuda.o

$(CUDADIR)/FClassOfCategory_cuda.o: $(COMMDIR)/FClassOfCategory.cpp $(COMMDIR)/FClassOfCategory.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) $(COMMDIR)/FClassOfCategory.cpp -o $(CUDADIR)/FClassOfCategory_cuda.o


# Library
# ------------------------------------------------------------------------------

$(COMMDIR)/AllNeurons.o: $(COMMDIR)/AllNeurons.cpp $(COMMDIR)/AllNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllNeurons.cpp -o $(COMMDIR)/AllNeurons.o
	
$(COMMDIR)/AllSpikingNeurons.o: $(COMMDIR)/AllSpikingNeurons.cpp $(COMMDIR)/AllSpikingNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllSpikingNeurons.cpp -o $(COMMDIR)/AllSpikingNeurons.o
	
$(COMMDIR)/AllIFNeurons.o: $(COMMDIR)/AllIFNeurons.cpp $(COMMDIR)/AllIFNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllIFNeurons.cpp -o $(COMMDIR)/AllIFNeurons.o
	
$(COMMDIR)/AllLIFNeurons.o: $(COMMDIR)/AllLIFNeurons.cpp $(COMMDIR)/AllLIFNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllLIFNeurons.cpp -o $(COMMDIR)/AllLIFNeurons.o
	
$(COMMDIR)/AllIZHNeurons.o: $(COMMDIR)/AllIZHNeurons.cpp $(COMMDIR)/AllIZHNeurons.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllIZHNeurons.cpp -o $(COMMDIR)/AllIZHNeurons.o
	
$(COMMDIR)/AllSynapses.o: $(COMMDIR)/AllSynapses.cpp $(COMMDIR)/AllSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllSynapses.cpp -o $(COMMDIR)/AllSynapses.o

$(COMMDIR)/AllSpikingSynapses.o: $(COMMDIR)/AllSpikingSynapses.cpp $(COMMDIR)/AllSpikingSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllSpikingSynapses.cpp -o $(COMMDIR)/AllSpikingSynapses.o

$(COMMDIR)/AllDSSynapses.o: $(COMMDIR)/AllDSSynapses.cpp $(COMMDIR)/AllDSSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllDSSynapses.cpp -o $(COMMDIR)/AllDSSynapses.o

$(COMMDIR)/AllSTDPSynapses.o: $(COMMDIR)/AllSTDPSynapses.cpp $(COMMDIR)/AllSTDPSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllSTDPSynapses.cpp -o $(COMMDIR)/AllSTDPSynapses.o

$(COMMDIR)/AllDynamicSTDPSynapses.o: $(COMMDIR)/AllDynamicSTDPSynapses.cpp $(COMMDIR)/AllDynamicSTDPSynapses.h $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/AllDynamicSTDPSynapses.cpp -o $(COMMDIR)/AllDynamicSTDPSynapses.o

$(COMMDIR)/Global.o: $(COMMDIR)/Global.cpp $(COMMDIR)/Global.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/Global.cpp -o $(COMMDIR)/Global.o

$(COMMDIR)/Simulator.o: $(COMMDIR)/Simulator.cpp $(COMMDIR)/Simulator.h $(COMMDIR)/Global.h $(COMMDIR)/SimulationInfo.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/Simulator.cpp -o $(COMMDIR)/Simulator.o

$(COMMDIR)/Model.o: $(COMMDIR)/Model.cpp $(COMMDIR)/Model.h $(COMMDIR)/IModel.h $(COMMDIR)/ParseParamError.h $(COMMDIR)/Util.h $(XMLDIR)/tinyxml.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/Model.cpp -o $(COMMDIR)/Model.o

$(COMMDIR)/Connections.o: $(COMMDIR)/Connections.cpp $(COMMDIR)/Connections.h 
	$(CXX) $(CXXFLAGS) $(COMMDIR)/Connections.cpp -o $(COMMDIR)/Connections.o

$(COMMDIR)/ConnStatic.o: $(COMMDIR)/ConnStatic.cpp $(COMMDIR)/ConnStatic.h 
	$(CXX) $(CXXFLAGS) $(COMMDIR)/ConnStatic.cpp -o $(COMMDIR)/ConnStatic.o

$(COMMDIR)/ConnGrowth.o: $(COMMDIR)/ConnGrowth.cpp $(COMMDIR)/ConnGrowth.h 
	$(CXX) $(CXXFLAGS) $(COMMDIR)/ConnGrowth.cpp -o $(COMMDIR)/ConnGrowth.o

$(COMMDIR)/Layout.o: $(COMMDIR)/Layout.cpp $(COMMDIR)/Layout.h 
	$(CXX) $(CXXFLAGS) $(COMMDIR)/Layout.cpp -o $(COMMDIR)/Layout.o

$(COMMDIR)/SingleThreadedSpikingModel.o: $(COMMDIR)/SingleThreadedSpikingModel.cpp $(COMMDIR)/SingleThreadedSpikingModel.h $(COMMDIR)/Model.h 
	$(CXX) $(CXXFLAGS) $(COMMDIR)/SingleThreadedSpikingModel.cpp -o $(COMMDIR)/SingleThreadedSpikingModel.o

$(COMMDIR)/ParseParamError.o: $(COMMDIR)/ParseParamError.cpp $(COMMDIR)/ParseParamError.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/ParseParamError.cpp -o $(COMMDIR)/ParseParamError.o

$(COMMDIR)/Timer.o: $(COMMDIR)/Timer.cpp $(COMMDIR)/Timer.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/Timer.cpp -o $(COMMDIR)/Timer.o

$(COMMDIR)/Util.o: $(COMMDIR)/Util.cpp $(COMMDIR)/Util.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/Util.cpp -o $(COMMDIR)/Util.o

$(COMMDIR)/XmlRecorder.o: $(COMMDIR)/XmlRecorder.cpp $(COMMDIR)/XmlRecorder.h $(COMMDIR)/IRecorder.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/XmlRecorder.cpp -o $(COMMDIR)/XmlRecorder.o

$(COMMDIR)/XmlGrowthRecorder.o: $(COMMDIR)/XmlGrowthRecorder.cpp $(COMMDIR)/XmlGrowthRecorder.h $(COMMDIR)/IRecorder.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/XmlGrowthRecorder.cpp -o $(COMMDIR)/XmlGrowthRecorder.o

ifeq ($(CUSEHDF5), yes)
$(COMMDIR)/Hdf5GrowthRecorder.o: $(COMMDIR)/Hdf5GrowthRecorder.cpp $(COMMDIR)/Hdf5GrowthRecorder.h $(COMMDIR)/IRecorder.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/Hdf5GrowthRecorder.cpp -o $(COMMDIR)/Hdf5GrowthRecorder.o


$(COMMDIR)/Hdf5Recorder.o: $(COMMDIR)/Hdf5Recorder.cpp $(COMMDIR)/Hdf5Recorder.h $(COMMDIR)/IRecorder.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/Hdf5Recorder.cpp -o $(COMMDIR)/Hdf5Recorder.o
endif

$(COMMDIR)/FClassOfCategory.o: $(COMMDIR)/FClassOfCategory.cpp $(COMMDIR)/FClassOfCategory.h
	$(CXX) $(CXXFLAGS) $(COMMDIR)/FClassOfCategory.cpp -o $(COMMDIR)/FClassOfCategory.o


# Matrix
# ------------------------------------------------------------------------------

$(MATRIXDIR)/CompleteMatrix.o: $(MATRIXDIR)/CompleteMatrix.cpp  $(MATRIXDIR)/CompleteMatrix.h $(MATRIXDIR)/MatrixExceptions.h $(MATRIXDIR)/Matrix.h $(MATRIXDIR)/VectorMatrix.h
	$(CXX) $(CXXFLAGS) $(MATRIXDIR)/CompleteMatrix.cpp -o $(MATRIXDIR)/CompleteMatrix.o

$(MATRIXDIR)/Matrix.o: $(MATRIXDIR)/Matrix.cpp $(MATRIXDIR)/Matrix.h  $(MATRIXDIR)/MatrixExceptions.h  $(XMLDIR)/tinyxml.h
	$(CXX) $(CXXFLAGS) $(MATRIXDIR)/Matrix.cpp -o $(MATRIXDIR)/Matrix.o

$(MATRIXDIR)/SparseMatrix.o: $(MATRIXDIR)/SparseMatrix.cpp $(MATRIXDIR)/SparseMatrix.h  $(MATRIXDIR)/MatrixExceptions.h $(MATRIXDIR)/Matrix.h $(MATRIXDIR)/VectorMatrix.h
	$(CXX) $(CXXFLAGS) $(MATRIXDIR)/SparseMatrix.cpp -o $(MATRIXDIR)/SparseMatrix.o

$(MATRIXDIR)/VectorMatrix.o: $(MATRIXDIR)/VectorMatrix.cpp $(MATRIXDIR)/VectorMatrix.h $(MATRIXDIR)/CompleteMatrix.h $(MATRIXDIR)/SparseMatrix.h $(MATRIXDIR)/
	$(CXX) $(CXXFLAGS) $(MATRIXDIR)/VectorMatrix.cpp -o $(MATRIXDIR)/VectorMatrix.o


# ParamContainer
# ------------------------------------------------------------------------------

$(PARAMDIR)/ParamContainer.o: $(PARAMDIR)/ParamContainer.cpp $(PARAMDIR)/ParamContainer.h
	$(CXX) $(CXXFLAGS) $(PARAMDIR)/ParamContainer.cpp -o $(PARAMDIR)/ParamContainer.o

# RNG
# ------------------------------------------------------------------------------

$(RNGDIR)/Norm.o: $(RNGDIR)/Norm.cpp $(RNGDIR)/Norm.h $(RNGDIR)/MersenneTwister.h $(COMMDIR)/BGTypes.h
	$(CXX) $(CXXFLAGS) $(RNGDIR)/Norm.cpp -o $(RNGDIR)/Norm.o


# XML
# ------------------------------------------------------------------------------

$(XMLDIR)/tinyxml.o: $(XMLDIR)/tinyxml.cpp $(XMLDIR)/tinyxml.h $(XMLDIR)/tinystr.h $(COMMDIR)/BGTypes.h
	$(CXX) $(CXXFLAGS) $(XMLDIR)/tinyxml.cpp -o $(XMLDIR)/tinyxml.o

$(XMLDIR)/tinyxmlparser.o: $(XMLDIR)/tinyxmlparser.cpp $(XMLDIR)/tinyxml.h
	$(CXX) $(CXXFLAGS) $(XMLDIR)/tinyxmlparser.cpp -o $(XMLDIR)/tinyxmlparser.o

$(XMLDIR)/tinyxmlerror.o: $(XMLDIR)/tinyxmlerror.cpp $(XMLDIR)/tinyxml.h
	$(CXX) $(CXXFLAGS) $(XMLDIR)/tinyxmlerror.cpp -o $(XMLDIR)/tinyxmlerror.o

$(XMLDIR)/tinystr.o: $(XMLDIR)/tinystr.cpp $(XMLDIR)/tinystr.h
	$(CXX) $(CXXFLAGS) $(XMLDIR)/tinystr.cpp -o $(XMLDIR)/tinystr.o

# SInput
# ------------------------------------------------------------------------------
$(SINPUTDIR)/FSInput.o: $(SINPUTDIR)/FSInput.cpp $(SINPUTDIR)/ISInput.h $(SINPUTDIR)/FSInput.h $(SINPUTDIR)/HostSInputRegular.h $(SINPUTDIR)/GpuSInputRegular.h $(SINPUTDIR)/HostSInputPoisson.h $(SINPUTDIR)/GpuSInputPoisson.h $(XMLDIR)/tinyxml.h
	$(CXX) $(CXXFLAGS) $(SINPUTDIR)/FSInput.cpp -o $(SINPUTDIR)/FSInput.o

$(SINPUTDIR)/FSInput_cuda.o: $(SINPUTDIR)/FSInput.cpp $(SINPUTDIR)/ISInput.h $(SINPUTDIR)/FSInput.h $(SINPUTDIR)/HostSInputRegular.h $(SINPUTDIR)/GpuSInputRegular.h $(SINPUTDIR)/HostSInputPoisson.h $(SINPUTDIR)/GpuSInputPoisson.h $(XMLDIR)/tinyxml.h
	$(CXX) $(CXXFLAGS) $(CGPUFLAGS) -I$(CUDADIR) $(SINPUTDIR)/FSInput.cpp -o $(SINPUTDIR)/FSInput_cuda.o

$(SINPUTDIR)/SInputRegular.o: $(SINPUTDIR)/SInputRegular.cpp $(SINPUTDIR)/ISInput.h $(SINPUTDIR)/SInputRegular.h $(XMLDIR)/tinyxml.h
	$(CXX) $(CXXFLAGS) $(SINPUTDIR)/SInputRegular.cpp -o $(SINPUTDIR)/SInputRegular.o

$(SINPUTDIR)/SInputPoisson.o: $(SINPUTDIR)/SInputPoisson.cpp $(SINPUTDIR)/ISInput.h $(SINPUTDIR)/SInputPoisson.h $(XMLDIR)/tinyxml.h
	$(CXX) $(CXXFLAGS) $(SINPUTDIR)/SInputPoisson.cpp -o $(SINPUTDIR)/SInputPoisson.o

$(SINPUTDIR)/HostSInputRegular.o: $(SINPUTDIR)/HostSInputRegular.cpp $(SINPUTDIR)/ISInput.h $(SINPUTDIR)/HostSInputRegular.h
	$(CXX) $(CXXFLAGS) $(SINPUTDIR)/HostSInputRegular.cpp -o $(SINPUTDIR)/HostSInputRegular.o

$(SINPUTDIR)/HostSInputPoisson.o: $(SINPUTDIR)/HostSInputPoisson.cpp $(SINPUTDIR)/ISInput.h $(SINPUTDIR)/HostSInputPoisson.h $(XMLDIR)/tinyxml.h
	$(CXX) $(CXXFLAGS) $(SINPUTDIR)/HostSInputPoisson.cpp -o $(SINPUTDIR)/HostSInputPoisson.o

$(SINPUTDIR)/GpuSInputRegular.o: $(SINPUTDIR)/GpuSInputRegular.cu $(SINPUTDIR)/ISInput.h $(SINPUTDIR)/GpuSInputRegular.h
	nvcc -c -g -arch=sm_20 -rdc=true $(SINPUTDIR)/GpuSInputRegular.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(XMLDIR) -I$(SINPUTDIR) -o $(SINPUTDIR)/GpuSInputRegular.o

$(SINPUTDIR)/GpuSInputPoisson.o: $(SINPUTDIR)/GpuSInputPoisson.cu $(SINPUTDIR)/ISInput.h $(SINPUTDIR)/GpuSInputPoisson.h
	nvcc -c -g -arch=sm_20 -rdc=true $(SINPUTDIR)/GpuSInputPoisson.cu $(CGPUFLAGS) -I$(CUDADIR) -I$(COMMDIR) -I$(XMLDIR) -I$(SINPUTDIR) -o $(SINPUTDIR)/GpuSInputPoisson.o

# Single Threaded
# ------------------------------------------------------------------------------

$(MAIN)/BGDriver.o: $(MAIN)/BGDriver.cpp $(COMMDIR)/Global.h 
	$(CXX) $(CXXFLAGS) $(MAIN)/BGDriver.cpp -o $(MAIN)/BGDriver.o



