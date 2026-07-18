{
  lib,
  _cuda,
  cudaNamePrefix,
  runCommand,
}:
let
  inherit (builtins) deepSeq toJSON tryEval;
  inherit (_cuda.bootstrapData) cudaCapabilityToInfo;
  inherit (_cuda.lib) formatCapabilities;
  inherit (lib.asserts) assertMsg;
in
# When changing names or formats: pause, validate, and update the assert
assert assertMsg (
  cudaCapabilityToInfo ? "7.5" && cudaCapabilityToInfo ? "8.6"
) "The following test requires both 7.5 and 8.6 be known CUDA capabilities";
assert
  let
    expected = {
      # Sorted alphabetically
      archNames = [
        "Ampere"
        "Turing"
      ];

      arches = [
        "sm_75"
        "sm_86"
        "compute_86"
      ];

      cmakeCudaArchitecturesString = "75;86";

      cudaCapabilities = [
        "7.5"
        "8.6"
      ];

      cudaForwardCompat = true;

      gencode = [
        "-gencode=arch=compute_75,code=sm_75"
        "-gencode=arch=compute_86,code=sm_86"
        "-gencode=arch=compute_86,code=compute_86"
      ];

      gencodeString = "-gencode=arch=compute_75,code=sm_75 -gencode=arch=compute_86,code=sm_86 -gencode=arch=compute_86,code=compute_86";

      realArches = [
        "sm_75"
        "sm_86"
      ];

      virtualArches = [
        "compute_75"
        "compute_86"
      ];
    };
    actual = formatCapabilities {
      inherit cudaCapabilityToInfo;

      cudaCapabilities = [
        "7.5"
        "8.6"
      ];

      cudaForwardCompat = true;
    };
    actualWrapped = (tryEval (deepSeq actual actual)).value;
  in
  assertMsg (expected == actualWrapped) ''
    Expected: ${toJSON expected}
    Actual: ${toJSON actualWrapped}
  '';
runCommand "${cudaNamePrefix}-tests-flags"
  {
    strictDeps = true;
    __structuredAttrs = true;
  }
  ''
    touch "$out"
  ''
