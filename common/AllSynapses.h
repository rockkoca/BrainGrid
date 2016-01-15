/**
 *      @file AllSynapses.h
 *
 *      @brief A container of all synapse data
 */

/** 
 * @authors Aaron Oziel, Sean Blackbourn
 * 
 * @class AllSynapses AllSynapses.h "AllSynapses.h"
 *
 * \latexonly  \subsubsection*{Implementation} \endlatexonly
 * \htmlonly   <h3>Implementation</h3> \endhtmlonly
 *
 *  The container holds synapse parameters of all synapses. 
 *  Each kind of synapse parameter is stored in a 2D array. Each item in the first 
 *  dimention of the array corresponds with each neuron, and each item in the second
 *  dimension of the array corresponds with a synapse parameter of each synapse of the neuron. 
 *  Bacause each neuron owns different number of synapses, the number of synapses 
 *  for each neuron is stored in a 1D array, synapse_counts.
 *
 *  For CUDA implementation, we used another structure, AllSynapsesDevice, where synapse
 *  parameters are stored in 1D arrays instead of 2D arrays, so that device functions
 *  can access these data less latency. When copying a synapse parameter, P[i][j],
 *  from host to device, it is stored in P[i * max_synapses_per_neuron + j] in 
 *  AllSynapsesDevice structure.
 *
 *  The latest implementation uses the identical data struture between host and CUDA;
 *  that is, synapse parameters are stored in a 1D array, so we don't need conversion 
 *  when copying data between host and device memory.
 *
 * \latexonly  \subsubsection*{Credits} \endlatexonly
 * \htmlonly   <h3>Credits</h3> \endhtmlonly
 *
 * Some models in this simulator is a rewrite of CSIM (2006) and other
 * work (Stiber and Kawasaki (2007?))
 */

#pragma once

#include "Global.h"
#include "SimulationInfo.h"

#ifdef _WIN32
typedef unsigned _int8 uint8_t;
#endif

class AllNeurons;

class AllSynapses
{
    public:
        AllSynapses();
        AllSynapses(const int num_neurons, const int max_synapses);
        virtual ~AllSynapses();

        /**
         *  Setup the internal structure of the class (allocate memories and initialize them).
         *
         *  @param  sim_info  SimulationInfo class to read information from.
         */
        virtual void setupSynapses(const int num_neurons, const int max_synapses);

        /**
         *  Setup the internal structure of the class (allocate memories and initialize them).
         *
         *  @param  num_neurons   Total number of neurons in the network.
         *  @param  max_synapses  Maximum number of synapses per neuron.
         */
        virtual void setupSynapses(SimulationInfo *sim_info);

        /**
         *  Cleanup the class (deallocate memories).
         */
        virtual void cleanupSynapses();

        /**
         *  Reset time varying state vars and recompute decay.
         *
         *  @param  iSyn     Index of the synapse to set.
         *  @param  deltaT   Inner simulation step duration
         */
        virtual void resetSynapse(const uint32_t iSyn, const BGFLOAT deltaT);

        /**
         *  Attempts to read parameters from a XML file.
         *
         *  @param  element TiXmlElement to examine.
         *  @return true if successful, false otherwise.
         */
        virtual bool readParameters(const TiXmlElement& element) = 0;

        /**
         *  Prints out all parameters of the neurons to ostream.
         *
         *  @param  output  ostream to send output to.
         */
        virtual void printParameters(ostream &output) const = 0;

        /**
         *  Sets the data for Synapses to input's data.
         *
         *  @param  input  istream to read from.
         *  @param  sim_info  SimulationInfo class to read information from.
         */
        void readSynapses(istream& input, AllNeurons &neurons, const SimulationInfo *sim_info);

        /**
         *  Write the synapses data to the stream.
         *
         *  @param  output  stream to print out to.
         *  @param  sim_info  SimulationInfo class to read information from.
         */
        void writeSynapses(ostream& output, const SimulationInfo *sim_info);

    protected:
        /**
         *  Sets the data for Synapse to input's data.
         *
         *  @param  input  istream to read from.
         *  @param  iSyn   Index of the synapse to set.
         */
        virtual void readSynapse(istream &input, const uint32_t iSyn);

        /**
         *  Write the synapse data to the stream.
         *
         *  @param  output  stream to print out to.
         *  @param  iSyn    Index of the synapse to print out.
         */
        virtual void writeSynapse(ostream& output, const uint32_t iSyn) const;

        /**
         *  Returns an appropriate synapseType object for the given integer.
         *
         *  @param  type_ordinal    Integer that correspond with a synapseType.
         *  @return the SynapseType that corresponds with the given integer.
         */
        synapseType synapseOrdinalToType(const int type_ordinal);

    public:
#if defined(USE_GPU)
        virtual void allocSynapseDeviceStruct( void** allSynapsesDevice, const SimulationInfo *sim_info ) = 0;
        virtual void allocSynapseDeviceStruct( void** allSynapsesDevice, int num_neurons, int maxSynapsesPerNeuron ) = 0;
        virtual void deleteSynapseDeviceStruct( void* allSynapsesDevice ) = 0;
        virtual void copySynapseHostToDevice( void* allSynapsesDevice, const SimulationInfo *sim_info ) = 0;
        virtual void copySynapseHostToDevice( void* allSynapsesDevice, int num_neurons, int maxSynapsesPerNeuron ) = 0;
        virtual void copySynapseDeviceToHost( void* allSynapsesDevice, const SimulationInfo *sim_info ) = 0;
        virtual void copyDeviceSynapseCountsToHost(void* allSynapsesDevice, const SimulationInfo *sim_info) = 0;
        virtual void copyDeviceSynapseSumIdxToHost(void* allSynapsesDevice, const SimulationInfo *sim_info) = 0;
        // Update the state of all synapses for a time step
        virtual void advanceSynapses(AllSynapses* allSynapsesDevice, AllNeurons* allNeuronsDevice, void* synapseIndexMapDevice, const SimulationInfo *sim_info) = 0;
        virtual void getFpCreateSynapse(unsigned long long& fpCreateSynapse_h) = 0;
        virtual void getFpChangePSR(unsigned long long& fpChangePSR_h) = 0;

        virtual void setAdvanceSynapsesDeviceParams() = 0;
#else
        /**
         *  Advance all the Synapses in the simulation.
         *  Update the state of all synapses for a time step.
         *
         *  @param  sim_info  SimulationInfo class to read information from.
         *  @param  neurons   The Neuron list to search from.
         */
        virtual void advanceSynapses(const SimulationInfo *sim_info, AllNeurons *neurons);

        /**
         *  Advance one specific Synapse.
         *
         *  @param  iSyn      Index of the Synapse to connect to.
         *  @param  sim_info  SimulationInfo class to read information from.
         *  @param  neurons   The Neuron list to search from.
         */
        virtual void advanceSynapse(const uint32_t iSyn, const SimulationInfo *sim_info, AllNeurons *neurons) = 0;

        /**
         *  Remove a synapse from the network.
         *
         *  @param  neuron_index   Index of a neuron to remove from.
         *  @param  iSyn           Index of a synapse to remove.
         */
        virtual void eraseSynapse(const int neuron_index, const uint32_t iSyn);
#endif

        /**
         *  Adds a Synapse to the model, connecting two Neurons.
         *
         *  @param  iSyn        Index of the synapse to be added.
         *  @param  type        The type of the Synapse to add.
         *  @param  src_neuron  The Neuron that sends to this Synapse.
         *  @param  dest_neuron The Neuron that receives from the Synapse.
         *  @param  sum_point   Summation point address.
         *  @param  deltaT      Inner simulation step duration
         */
        virtual void addSynapse(uint32_t &iSyn, synapseType type, const int src_neuron, const int dest_neuron, BGFLOAT *sum_point, const BGFLOAT deltaT);

        /**
         *  Create a Synapse and connect it to the model.
         *
         *  @param  synapses    The synapse list to reference.
         *  @param  iSyn        Index of the synapse to set.
         *  @param  source      Coordinates of the source Neuron.
         *  @param  dest        Coordinates of the destination Neuron.
         *  @param  sum_point   Summation point address.
         *  @param  deltaT      Inner simulation step duration.
         *  @param  type        Type of the Synapse to create.
         */
        virtual void createSynapse(const uint32_t iSyn, int source_index, int dest_index, BGFLOAT* sp, const BGFLOAT deltaT, synapseType type) = 0;

        /**
         *  Get the sign of the synapseType.
         *
         *  @param    type    synapseType I to I, I to E, E to I, or E to E
         *  @return   1 or -1, or 0 if error
         */
        int synSign(const synapseType type);

        // TODO
        static const BGFLOAT SYNAPSE_STRENGTH_ADJUSTMENT = 1.0e-8;
 
        /**
         *  The location of the synapse.
         */
        int *sourceNeuronIndex;

        /** 
         *  The coordinates of the summation point.
         */
        int *destNeuronIndex;

        /**
         *   The weight (scaling factor, strength, maximal amplitude) of the synapse.
         */
         BGFLOAT *W;

        /**
         *  This synapse's summation point's address.
         */
        BGFLOAT **summationPoint;

    	/**
         *  Synapse type
         */
        synapseType *type;

        /** 
         *  The post-synaptic response is the result of whatever computation 
         *  is going on in the synapse.
         */
        BGFLOAT *psr;

    	/**
         *  The boolean value indicating the entry in the array is in use.
         */
        bool *in_use;

        /**
         *  The number of synapses for each neuron.
         *  Note: Likely under a different name in GpuSim_struct, see synapse_count. -Aaron
         */
        size_t *synapse_counts;

        /**
         *  The total number of active synapses.
         */
        size_t total_synapse_counts;

    	/**
         *  The maximum number of synapses for each neurons.
         */
        size_t maxSynapsesPerNeuron;

    protected:

        /**
         *  The number of neurons
         *  Aaron: Is this even supposed to be here?!
         *  Usage: Used by destructor
         */
        int count_neurons;
};
