#include <stdio.h>
#include <cuda.h>

#define MAX_TESS_POINTS 32 05
//A structure containing all parameters needed to tessellate a Bezier line

struct BezierLine {
  float2 CP[3]; //Control points for the line
  float2 vertexPos[MAX_TESS_POINTS]; //Vertex position array to tessellate into
  int nVertices; //Number of tessellated vertices
};

__global__ void computeBezierLines(BezierLine *bLines, int nLines) {

  int bidx = blockIdx.x;
  if(bidx < nLines){

  //Compute the curvature of the line
  float curvature = computeCurvature(bLines);
  //From the curvature, compute the number of tessellation points
  int nTessPoints = min(max((int)(curvature*16.0f),4),32); bLines[bidx].nVertices = nTessPoints;
  //Loop through vertices to be tessellated, incrementing by blockDim.x
  for(int inc = 0; inc < nTessPoints; inc += blockDim.x){
    int idx = inc + threadIdx.x; //Compute a unique index for this point if(idx < nTessPoints){
    float u = (float)idx/(float)(nTessPoints-1); //Compute u from idx float omu = 1.0f - u; //pre-compute one minus u
    float B3u[3]; //Compute quadratic Bezier coefficients
    B3u[0] = omu*omu;
    B3u[1] = 2.0f*u*omu;
    B3u[2] = u*u;
    float2 position = {0,0}; //Set position to zero for(int i = 0; i < 3; i++){
//Add the contribution of the i'th control point to position
    position = position + B3u[i] * bLines[bidx].CP[i]; }
//Assign value of vertex position to the correct array element
    bLines[bidx].vertexPos[idx] = position; }
}

#define N_LINES 256
#define BLOCK_DIM 32

int main( int argc, char **argv ) {
//Allocate and initialize array of lines in host memory
BezierLine *bLines_h = new BezierLine[N_LINES];
initializeBLines(bLines_h);

//Allocate device memory for array of Bezier lines
BezierLine *bLines_d;
cudaMalloc((void**)&bLines_d, N_LINES*sizeof(BezierLine));
cudaMemcpy(bLines_d,bLines_h, N_LINES*sizeof(BezierLine),cudaMemcpyHostToDevice);

  //Call the kernel to tessellate the lines
computeBezierLines<<<N_LINES, BLOCK_DIM>>>(bLines_d, N_LINES );

cudaFree(bLines_d); //Free the array of lines in device memory
delete[] bLines_h; //Free the array of lines in host memory
}
