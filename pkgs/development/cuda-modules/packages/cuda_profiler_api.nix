{ buildRedist }:
buildRedist {
  pname = "cuda_profiler_api";

  outputs = [
    "out"
    "dev"
    "include"
  ];

  redistName = "cuda";
  meta.description = "API for profiling CUDA runtime";
}
