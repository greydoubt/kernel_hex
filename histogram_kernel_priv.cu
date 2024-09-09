__global__ void histogram_privatized_kernel(
  unsigned char* input, 
  unsigned int* bins, 
  unsigned int num_elements, 
  unsigned int num_bins
) { 
  unsigned int tid = blockIdx.x*blockDim.x + threadIdx.x;
// Privatized bins
  extern __shared__ unsigned int histo_s[];

  for(unsigned int binIdx = threadIdx.x; binIdx < num_bins; binIdx +=blockDim.x) {
  histo_s[binIdx] = 0u; 
    }
__syncthreads();
  
  // Histogram
for (unsigned int i = tid; i < num_elements; i += blockDim.x*gridDim.x) {
  int alphabet_position = buffer[i] – “a”;
  if (alphabet_position >= 0 && alpha_position < 26) atomicAdd(&(histo_s[alphabet_position/4]), 1);
} 
__syncthreads();
  
// Commit to global memory
for(unsigned int binIdx = threadIdx.x; binIdx < num_bins; binIdx += blockDim.x) {
  atomicAdd(&(histo[binIdx]), histo_s[binIdx]);
} }
