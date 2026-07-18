{
  lib,
  fetchFromGitHub,
  addDriverRunpath,
  autoAddDriverRunpath,
  autoPatchelfHook,
  backendStdenv,
  cccl,
  cmake,
  cuda_cudart,
  cuda_nvcc,
  cudatoolkit,
  libcusparse,
  libcusparse_lt,
  libcutensor,
  setupCudaHook,
}:
let
  base = backendStdenv.mkDerivation (finalAttrs: {
    version =
      lib.strings.substring 0 7 finalAttrs.src.rev + "-" + lib.versions.majorMinor cudatoolkit.version;

    src = fetchFromGitHub {
      owner = "NVIDIA";
      repo = "CUDALibrarySamples";
      rev = "e57b9c483c5384b7b97b7d129457e5a9bdcdb5e1";
      sha256 = "0g17afsmb8am0darxchqgjz1lmkaihmnn7k1x4ahg5gllcmw8k3l";
    };

    nativeBuildInputs = [
      cmake
      addDriverRunpath
    ];

    buildInputs = [ cudatoolkit ];

    postFixup = ''
      for exe in $out/bin/*; do
        addDriverRunpath $exe
      done
    '';

    meta = {
      description = "examples of using libraries using CUDA";

      longDescription = ''
        CUDA Library Samples contains examples demonstrating the use of
        features in the math and image processing libraries cuBLAS, cuTENSOR,
        cuSPARSE, cuSOLVER, cuFFT, cuRAND, NPP and nvJPEG.
      '';

      license = lib.licenses.bsd3;
      platforms = [ "x86_64-linux" ];
      teams = [ lib.teams.cuda ];
    };
  });
in

{
  cublas = base.overrideAttrs (
    finalAttrs: _: {
      pname = "cuda-library-samples-cublas";
      sourceRoot = "${finalAttrs.src.name}/cuBLASLt";
    }
  );

  cusolver = base.overrideAttrs (
    finalAttrs: _: {
      pname = "cuda-library-samples-cusolver";
      sourceRoot = "${finalAttrs.src.name}/cuSOLVER/gesv";
    }
  );

  cusparselt = base.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "cuda-library-samples-cusparselt";

      postPatch = prevAttrs.postPatch or "" + ''
        substituteInPlace CMakeLists.txt \
          --replace-fail "''${CUSPARSELT_ROOT}/lib64/libcusparseLt.so" "${lib.getLib libcusparse_lt}/lib/libcusparseLt.so" \
          --replace-fail "''${CUSPARSELT_ROOT}/lib64/libcusparseLt_static.a" "${lib.getStatic libcusparse_lt}/lib/libcusparseLt_static.a"
      '';

      nativeBuildInputs = prevAttrs.nativeBuildInputs or [ ] ++ [
        cmake
        addDriverRunpath
        (lib.getDev libcusparse_lt)
        (lib.getDev libcusparse)
        cuda_nvcc
        (lib.getDev cuda_cudart) # <cuda_runtime_api.h>
        cccl # <nv/target>
      ];

      postInstall = prevAttrs.postInstall or "" + ''
        mkdir -p $out/bin
        cp matmul_example $out/bin/
        cp matmul_example_static $out/bin/
      '';

      CUDA_TOOLKIT_PATH = lib.getLib cudatoolkit;
      CUSPARSELT_PATH = lib.getLib libcusparse_lt;
      sourceRoot = "${finalAttrs.src.name}/cuSPARSELt/matmul";
    }
  );

  cutensor = base.overrideAttrs (
    finalAttrs: prevAttrs: {
      pname = "cuda-library-samples-cutensor";

      # CUTENSOR_ROOT is double escaped
      postPatch = prevAttrs.postPatch or "" + ''
        substituteInPlace CMakeLists.txt \
          --replace-fail "\''${CUTENSOR_ROOT}/include" "${lib.getOutput "include" libcutensor}/include"
      '';

      buildInputs = prevAttrs.buildInputs or [ ] ++ [ libcutensor ];

      cmakeFlags = prevAttrs.cmakeFlags or [ ] ++ [
        "-DCUTENSOR_EXAMPLE_BINARY_INSTALL_DIR=${placeholder "out"}/bin"
      ];

      CUTENSOR_ROOT = libcutensor;
      sourceRoot = "${finalAttrs.src.name}/cuTENSOR";
    }
  );
}
