{
  buildRedist,
  libGLU,
  libcufft,
  libcurand,
  libglut,
  libglvnd,
}:
buildRedist {
  pname = "cuda_demo_suite";
  outputs = [ "out" ];

  buildInputs = [
    libcufft
    libcurand
    libGLU
    libglut
    libglvnd
  ];

  redistName = "cuda";

  meta = {
    description = "Pre-built applications which use CUDA";

    longDescription = ''
      The CUDA Demo Suite contains pre-built applications which use CUDA. These applications demonstrate the
      capabilities and details of NVIDIA GPUs.
    '';

    homepage = "https://docs.nvidia.com/cuda/demo-suite";
  };
}
