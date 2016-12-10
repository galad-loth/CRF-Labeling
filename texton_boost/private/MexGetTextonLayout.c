//=================================================================================
//  MexGetTextonLayout.c
//  Get texton-layout feature based on input texton-map and region-window
//  Author: 2016-12-08, jlfeng

//=================================================================================
/*Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of EPFL nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 #include<mex.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <string.h>  
#include <stdint.h>

#define MX_MAX(a,b) ((a) > (b) ? (a) : (b)) 
#define MX_MIN(a,b) ((a) < (b) ? (a) : (b))
// #define 2D_INDEX_MAT(pr,pc,nr) (pc*nr+pr)

void SetPadSize(int32_t *ptRegionRange, int32_t nregion, int32_t *ptPadSize)
{
    int32_t maxPadSize=100;
    ptPadSize[0]=maxPadSize;
    ptPadSize[1]=-maxPadSize;
    ptPadSize[2]=maxPadSize;
    ptPadSize[3]=-maxPadSize;
    for (int32_t ii=0; ii<nregion; ii++)
    {
        if ((ptRegionRange[nregion+ii]<=ptRegionRange[ii])
            || (ptRegionRange[nregion*3+ii]<=ptRegionRange[nregion*2+ii]))
            {
                mexErrMsgTxt("Invalid Layout Filtering region");
            }
        ptPadSize[0]=MX_MIN(ptPadSize[0], ptRegionRange[ii]);
        ptPadSize[1]=MX_MAX(ptPadSize[1], ptRegionRange[nregion+ii]);
        ptPadSize[2]=MX_MIN(ptPadSize[2], ptRegionRange[nregion*2+ii]);
        ptPadSize[3]=MX_MAX(ptPadSize[3], ptRegionRange[nregion*3+ii]);
    }
    ptPadSize[0]=MX_MAX(-ptPadSize[0],0);
    ptPadSize[1]=MX_MAX(ptPadSize[1],0);
    ptPadSize[2]=MX_MAX(-ptPadSize[2],0);
    ptPadSize[3]=MX_MAX(ptPadSize[3],0);
}

void PadTextonMap(int32_t *ptMapData, int32_t nrow, int32_t ncol, 
    int32_t *ptPadSize, int32_t ntexton, int32_t *ptPadMap)
{
    int32_t nrpad=nrow+ptPadSize[0]+ptPadSize[1];
    int32_t ncpad=ncol+ptPadSize[2]+ptPadSize[3];    
    int32_t prpad, pcpad;
    memset(ptPadMap, 0, sizeof(int32_t)*nrpad*ncpad);
    int32_t val=0;
    for (int32_t pc=0; pc<ncol; pc++)
    {
        pcpad=pc+ptPadSize[2];
        for (int32_t pr=0; pr<nrow; pr++)
        {
            prpad=pr+ptPadSize[0];
            val=ptMapData[pc*nrow+pr];
            if (val<0 || val>=ntexton)
            {
                mexErrMsgTxt("Texton map value out of range");
            }
            ptPadMap[prpad*ncpad+pcpad]=val+1;
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //Check input parameter
    if (nrhs<1 || nrhs>3)
    {
        mexErrMsgTxt("This function takes three input argments.");
    }   
    
    // Get input data and malloc output data
    const mwSize *dimTextonMap=mxGetDimensions(prhs[0]);
    int32_t *ptMapData=(int32_t *)mxGetData(prhs[0]);
    int32_t nrow=dimTextonMap[0];
    int32_t ncol=dimTextonMap[1];
    int32_t numpix=nrow*ncol;
    int32_t ntexton=(int32_t) mxGetScalar(prhs[1]);
    const mwSize * dimRegion=mxGetDimensions(prhs[2]);
    int32_t nregion=dimRegion[0];
    int32_t *ptRegionRange=(int32_t *)mxGetData(prhs[2]); 
    int32_t ndfeat=ntexton*nregion;
    
    plhs[0] = mxCreateNumericMatrix(ndfeat, numpix, mxDOUBLE_CLASS,mxREAL);
    double *ptOutFeat=(double *)mxGetData(plhs[0]);
    memset(ptOutFeat,0,sizeof(double)*ndfeat*numpix);  
    
    //Pad the texton map
    int32_t ptPadSize[4];
    SetPadSize(ptRegionRange, nregion, ptPadSize);    
    int32_t nrpad=nrow+ptPadSize[0]+ptPadSize[1];
    int32_t ncpad=ncol+ptPadSize[2]+ptPadSize[3];
    int32_t * ptPadMap=mxMalloc(sizeof(int32_t)*nrpad*ncpad);
    PadTextonMap(ptMapData, nrow, ncol, ptPadSize, ntexton, ptPadMap);    
  
    double *ptHistTemp=mxMalloc(sizeof(double)*(1+ntexton));
    double *ptHistRec=mxMalloc(sizeof(double)*(1+ntexton));
    double histSum=0, histSumRec=0;
    int32_t pr, pc, prpad, pcpad; 
    int32_t prout, pcout, prin, pcin;
    int32_t *ptRowPad;
    double *ptOutFeatCur;
    for (int32_t ir=0; ir<nregion; ir++)
    {
        ptOutFeatCur=ptOutFeat+ir*ntexton;     
       
       //Initialization histogram
       memset(ptHistTemp, 0, sizeof(double)*(1+ntexton));
       histSum=1e-6;
       int32_t prStart=ptPadSize[0]+ptRegionRange[ir];
       int32_t prEnd=ptPadSize[0]+ptRegionRange[nregion+ir];
       int32_t pcStart=ptPadSize[2]+ptRegionRange[nregion*2+ir];
       int32_t pcEnd=ptPadSize[2]+ptRegionRange[nregion*3+ir];      
       for (prpad=prStart; prpad<=prEnd; prpad++)
       {
           ptRowPad=ptPadMap+prpad*ncpad;
           pr=prpad-ptPadSize[0];
           for (pcpad=pcStart; pcpad<=pcEnd; pcpad++)
           {
               pc=pcpad-ptPadSize[2];
               ptHistTemp[ptRowPad[pcpad]]++;
               histSum+=(ptRowPad[pcpad]>0);
           }
       }    
       //Save the first hitogram feature
        for (int32_t id=0; id<ntexton; id++)
        {
            ptOutFeatCur[id]=ptHistTemp[id+1]/histSum;            
        }
        ptOutFeatCur+=ndfeat;
        memcpy(ptHistRec, ptHistTemp, sizeof(double)*(ntexton+1));
        histSumRec=histSum;
        
        for (int32_t pp=1; pp<nrow*ncol; pp++)
        {
            pr=pp%nrow;
            pc=pp/nrow;
            if (0==pr) // a new coloum starts
            {
                /*copy the recorded histogram*/
                memcpy(ptHistTemp, ptHistRec, sizeof(double)*(ntexton+1));
                histSum=histSumRec;
                
               /*substract the out-pixels*/
                prout=pr+ ptPadSize[0]+ptRegionRange[ir];
                pcout=pc+ptPadSize[2]+ptRegionRange[nregion*2+ir]-1;
                ptRowPad=ptPadMap+prout*ncpad;                
                for (int32_t ppout=0; ppout<=ptRegionRange[nregion+ir]-ptRegionRange[ir]; ppout++)
                {                    
                    ptHistTemp[ptRowPad[pcout]]++;
                    histSum-=(ptRowPad[pcout]>0);
                    ptRowPad=ptRowPad+ncpad;
                }
                /*add the in-pixels*/
                prin=pr+ptPadSize[0]+ptRegionRange[ir];
                pcin=pc+ptPadSize[2]+ptRegionRange[nregion*3+ir];
                ptRowPad=ptPadMap+prin*ncpad;                
                for (int32_t ppin=0; ppin<=ptRegionRange[nregion+ir]-ptRegionRange[ir]; ppin++)
                {                    
                    ptHistTemp[ptRowPad[pcin]]++;
                    histSum+=(ptRowPad[pcin]>0);
                    ptRowPad=ptRowPad+ncpad;
                }
                
                /*save feature and recorded histogram*/
                for (int32_t id=0; id<ntexton; id++)
                {
                    ptOutFeatCur[id]=ptHistTemp[id+1]/histSum;            
                }
                ptOutFeatCur+=ndfeat;
                memcpy(ptHistRec, ptHistTemp, sizeof(double)*(ntexton+1));
                histSumRec=histSum;
            }
            else
            {
                /*substract the out-pixels*/
                prout=pr+ ptPadSize[0]+ptRegionRange[ir]-1;
                pcout=pc+ptPadSize[2]+ptRegionRange[nregion*2+ir];
                ptRowPad=ptPadMap+prout*ncpad;                
                for (int32_t ppout=0; ppout<=ptRegionRange[3*nregion+ir]-ptRegionRange[nregion*2+ir]; ppout++)
                {                    
                    ptHistTemp[ptRowPad[pcout]]--;
                    histSum-=(ptRowPad[pcout]>0);
                    pcout++;
                }
                
               /*add the in-pixels*/
                prin=pr+ptPadSize[0]+ptRegionRange[nregion+ir];
                pcin=pc+ptPadSize[2]+ptRegionRange[nregion*2+ir];                
                ptRowPad=ptPadMap+prin*ncpad;                
                for (int32_t ppin=0; ppin<=ptRegionRange[3*nregion+ir]-ptRegionRange[nregion*2+ir]; ppin++)
                {                    
                    ptHistTemp[ptRowPad[pcin]]++;
                    histSum+=(ptRowPad[pcin]>0);
                    pcin++;
                }                
                
                for (int32_t id=0; id<ntexton; id++)
                {
                    ptOutFeatCur[id]=ptHistTemp[id+1]/histSum;            
                }
                ptOutFeatCur+=ndfeat;
            }
       }       
    }    
    
    // Deallocate memory
    mxFree(ptPadMap);
    mxFree(ptHistTemp);
    mxFree(ptHistRec);
} 


