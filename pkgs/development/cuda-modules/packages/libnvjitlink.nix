{
  lib,
  buildRedist,
  cudaAtLeast,
}:
buildRedist {
  pname = "libnvjitlink";

  outputs = [
    "out"
    "dev"
    "include"
    "lib"
    "static"
  ]
  ++ lib.optionals (cudaAtLeast "12.2") [ "stubs" ];

  redistName = "cuda";

  meta = {
    description = "APIs which can be used at runtime to link together GPU device code";
    homepage = "https://docs.nvidia.com/cuda/nvjitlink";
  };
}
