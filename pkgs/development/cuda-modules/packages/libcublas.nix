{ buildRedist }:
buildRedist {
  pname = "libcublas";

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
    description = "CUDA Basic Linear Algebra Subroutine library";

    longDescription = ''
      The cuBLAS library is an implementation of BLAS (Basic Linear Algebra Subprograms) on top of the NVIDIA CUDA runtime.
    '';

    homepage = "https://developer.nvidia.com/cublas";
  };
}
