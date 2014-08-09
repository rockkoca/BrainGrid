/**
 *      @file ISInput.h
 *
 *      @brief Header file for ISInput.h
 */
//! An interface for stimulus input classes.

/**
 ** \class ISInput ISInput.h "ISInput.h"
 **
 ** \latexonly  \subsubsection*{Implementation} \endlatexonly
 ** \htmlonly   <h3>Implementation</h3> \endhtmlonly
 **
 ** The ISInput provides an interface for stimulus input classes.
 **
 ** \latexonly  \subsubsection*{Credits} \endlatexonly
 ** \htmlonly   <h3>Credits</h3> \endhtmlonly
 **
 ** This simulator is a rewrite of CSIM (2006) and other work (Stiber and Kawasaki (2007?))
 **
 **
 **     @author Fumitaka Kawasaki
 **/

#pragma once

#ifndef _ISINPUT_H_
#define _ISINPUT_H_

#include "Global.h"
#include "SimulationInfo.h"
#include "tinyxml.h"

class ISInput
{
public:
    virtual ~ISInput() {}

    /**
     * Initialize data
     * @param[in] psi 
     */
    virtual void init(SimulationInfo* psi, TiXmlElement* parms) = 0;

    /**
     * Terminate process
     */
    virtual void term() = 0;

    /**
     * Process input stimulus for each time step
     * @param[in] psi 
     * @param[in] summationPoint
     */
    virtual void inputStimulus(SimulationInfo* psi, BGFLOAT* summationPoint) = 0;
};

#endif // _ISINPUT_H_
