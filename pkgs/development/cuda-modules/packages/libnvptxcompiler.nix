{ buildRedist }:
buildRedist {
  pname = "libnvptxcompiler";
  outputs = [ "out" ];
  redistName = "cuda";

  meta = {
    description = "APIs which can be used to compile a PTX program into GPU assembly code";
    homepage = "https://docs.nvidia.com/cuda/ptx-compiler-api";
  };
}
