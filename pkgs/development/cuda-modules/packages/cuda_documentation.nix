{ buildRedist }:
buildRedist {
  pname = "cuda_documentation";
  outputs = [ "out" ];
  allowFHSReferences = true;
  redistName = "cuda";

  meta = {
    homepage = "https://docs.nvidia.com/cuda";
    changelog = "https://docs.nvidia.com/cuda/cuda-toolkit-release-notes";
  };
}
