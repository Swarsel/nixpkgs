{
  lib,
  buildRedist,
  cudaOlder,
  numactl,
  rdma-core,
}:
buildRedist {
  pname = "libcufile";

  outputs = [
    "out"
    "dev"
    "include"
    "lib"
    "static"
  ];

  # TODO(@connorbaker): At some point before 12.6, libcufile depends on libcublas.
  buildInputs = [
    numactl
    rdma-core
  ];

  allowFHSReferences = true;

  # Before 11.7 libcufile depends on itself for some reason.
  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
  ]
  ++ lib.optionals (cudaOlder "11.7") [ "libcufile.so.0" ];

  redistName = "cuda";

  meta = {
    description = "Library to leverage GDS technology";
    homepage = "https://docs.nvidia.com/gpudirect-storage/api-reference-guide";
  };
}
