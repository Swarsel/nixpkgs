{
  lib,
  stdenv,
  callPackage,
  cudaSupport,
  rocmSupport,
  torchaudio,
  torchcodec,
  torchvision,
}:

let
  cudaOnly = {
    tester-compileCuda = callPackage ./mk-torch-compile-check.nix {
      feature = "cuda";
      libraries = ps: [ ps.torchWithCuda ];
    };

    # To perform the runtime check use either
    # `nix run .#python3Packages.torch.tests.tester-cudaAvailable` (outside the sandbox), or
    # `nix build .#python3Packages.torch.tests.tester-cudaAvailable.gpuCheck` (in a relaxed sandbox)
    tester-cudaAvailable = callPackage ./mk-runtime-check.nix {
      feature = "cuda";
      libraries = ps: [ ps.torchWithCuda ];
      versionAttr = "cuda";
    };
  };

  rocmOnly = {
    tester-compileRocm = callPackage ./mk-torch-compile-check.nix {
      feature = "rocm";
      libraries = ps: [ ps.torchWithRocm ];
    };

    tester-rocmAvailable = callPackage ./mk-runtime-check.nix {
      feature = "rocm";
      libraries = ps: [ ps.torchWithRocm ];
      versionAttr = "hip";
    };
  };
in
let
  tester-compileCpu = callPackage ./mk-torch-compile-check.nix {
    feature = null;
    libraries = ps: [ ps.torch ];
  };
in
{
  inherit tester-compileCpu;
  # Core packages from the torch ecosystem
  inherit torchvision torchaudio torchcodec;
  compileCpu = tester-compileCpu.gpuCheck;
  mnist-example = callPackage ./mnist-example { };
}
// lib.optionalAttrs cudaSupport cudaOnly
// lib.optionalAttrs rocmSupport rocmOnly
