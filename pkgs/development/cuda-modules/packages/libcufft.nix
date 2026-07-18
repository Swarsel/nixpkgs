{ buildRedist }:
buildRedist {
  pname = "libcufft";

  outputs = [
    "out"
    "dev"
    "include"
    "lib"
    "static"
    "stubs"
  ];

  redistName = "cuda";

  meta = {
    description = "High-performance FFT product CUDA library";
    homepage = "https://developer.nvidia.com/cufft";
  };
}
