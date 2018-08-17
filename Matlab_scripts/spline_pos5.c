#include "mex.h"
#include <math.h>
#include "spline.c"

/*
 * This function provides mex-implementation of spline_pos5.c as used in D2D
 *
 * This is a MEX-file for MATLAB.
 *
 * Example:
 * mex D2D_spline_pos5.c
 * z=D2D_spline_pos5(linspace(0,10,1001),10.^randn(1,5),linspace(0,10,5));
 * plot(z)
 */


double spline_pos5(double t, double t1, double p1, double t2, double p2, double t3, double p3, double t4, double p4, double t5, double p5, int ss, double dudt) {   
    int is;
    double uout;
    
    double ts[5];
    double us[5];
    double uslog[5];
    
    double b[5];
    double c[5];
    double d[5];
    
    ts[0] = t1;
    ts[1] = t2;
    ts[2] = t3;
    ts[3] = t4;
    ts[4] = t5;
    
    us[0] = p1;
    us[1] = p2;
    us[2] = p3;
    us[3] = p4;
    us[4] = p5;
    
    for (is = 0; is<5; is++){
        uslog[is] = log(us[is]);
    }
    
    spline(5, ss, 0, dudt, 0.0, ts, uslog, b, c, d);
    uout = seval(5, t, ts, uslog, b, c, d);
    
    return(exp(uout));
}



void coreFun(double *t, double *z, size_t m, size_t n, double p1, double knot1, double p2, double knot2, double p3, double knot3, double p4, double knot4, double p5, double knot5, int arg1, double arg2)
{
  mwSize i,j,count=0;
  
  double ttmp;
  
  for (i=0; i<n; i++) {
    for (j=0; j<m; j++) {
        ttmp = *(t+count); // inhalt von t
      *(z+count) = spline_pos5(ttmp,   p1,  knot1,  p2,  knot2,  p3,  knot3,  p4,  knot4,  p5,  knot5, arg1,  arg2);
      count++;
    }
  }
}

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  double *t,*p,*z,*knots;
  size_t mrows,ncols;
  
  /*  check for proper number of arguments */
  if(nrhs!=13) 
    mexErrMsgIdAndTxt( "MATLAB:Example5:invalidNumInputs",
            "Three inputs required.");
  if(nlhs!=1) 
    mexErrMsgIdAndTxt( "MATLAB:Example5:invalidNumOutputs",
            "One output required.");  


  /*  create a pointer to the input matrix t */
  t = mxGetPr(prhs[0]);
  
  double p1, knot1, p2, knot2, p3, knot3, p4, knot4, p5, knot5, arg2;
  int arg1;
  
  p1 = mxGetScalar(prhs[1]);     
  knot1 = mxGetScalar(prhs[2]);
  p2 = mxGetScalar(prhs[3]);     
  knot2 = mxGetScalar(prhs[4]);
  p3 = mxGetScalar(prhs[5]);     
  knot3 = mxGetScalar(prhs[6]);
  p4 = mxGetScalar(prhs[7]);     
  knot4 = mxGetScalar(prhs[8]);
  p5 = mxGetScalar(prhs[9]);     
  knot5 = mxGetScalar(prhs[10]);

  arg1 = (int) mxGetScalar(prhs[11]);     
  arg2 = mxGetScalar(prhs[12]);
          
  /*  get the dimensions of the matrix input t */
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);  

  
  /*  set the output pointer to the output matrix */
  plhs[0] = mxCreateDoubleMatrix( (mwSize)mrows, (mwSize)ncols, mxREAL);
  
  /*  create a C pointer to a copy of the output matrix */
  z = mxGetPr(plhs[0]);
  
  /*  call the C subroutine */
  coreFun(t,z,mrows,ncols,   p1,  knot1,  p2,  knot2,  p3,  knot3,  p4,  knot4,  p5,  knot5, arg1,  arg2);
  
}
