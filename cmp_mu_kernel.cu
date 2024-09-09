__global__ void cmpMu(float* rPhi, iPhi, rD, iD, rMu, iMu) {
int m = blockIdx.x*MU_THREAEDS_PER_BLOCK + threadIdx.x;
        rMu[m] = rPhi[m]*rD[m] + iPhi[m]*iD[m];
        iMu[m] = rPhi[m]*iD[m] – iPhi[m]*rD[m];
      }
