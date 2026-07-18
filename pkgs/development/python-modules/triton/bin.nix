{
  lib,
  stdenv,
  fetchurl,
  addDriverRunpath,
  autoPatchelfHook,
  buildPythonPackage,
  config,
  cudaPackages,
  python,
  rocmPackages,
  zlib,
  rocmSupport ? config.rocmSupport,
}:

buildPythonPackage (finalAttrs: {
  pname = "triton";
  version = "3.7.0";

  src =
    let
      pyVerNoDot = lib.replaceStrings [ "." ] [ "" ] python.pythonVersion;
      unsupported = throw "Unsupported system";
      srcs =
        (import ./binary-hashes.nix finalAttrs.version)."${stdenv.system}-${pyVerNoDot}" or unsupported;
    in
    fetchurl srcs;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ zlib ];

  postFixup = ''
    mkdir -p $out/${python.sitePackages}/triton/third_party/cuda/bin/
    ln -s ${cudaPackages.cuda_nvcc}/bin/ptxas $out/${python.sitePackages}/triton/third_party/cuda/bin/
  ''
  # Ugly patch to circumvent the heuristic-based search logic of libcuda.so
  + ''
    substituteInPlace "${placeholder "out"}/${python.sitePackages}/triton/backends/nvidia/driver.py" \
      --replace-fail \
        "if env_libcuda_path := knobs.nvidia.libcuda_path:" \
        "return '${addDriverRunpath.driverLink}/lib/libcuda.so'" \
      --replace-fail \
        "return [env_libcuda_path]" \
        ""
  ''
  + lib.optionalString rocmSupport ''
    substituteInPlace "${placeholder "out"}/${python.sitePackages}/triton/backends/amd/driver.py" \
      --replace-fail \
        "lib_name = "libamdhip64.so" \
        "return '${rocmPackages.clr}/lib/libamdhip64.so'"
  '';

  __structuredAttrs = true;
  dontStrip = true;
  format = "wheel";

  pythonRemoveDeps = [
    "cmake"
    # torch and triton refer to each other so this hook is included to mitigate that.
    "torch"
  ];

  meta = {
    description = "Language and compiler for custom Deep Learning operations";
    homepage = "https://github.com/triton-lang/triton/";
    changelog = "https://github.com/triton-lang/triton/releases/tag/v${finalAttrs.version}";

    # Includes NVIDIA's ptxas, but redistributions of the binary are not limited.
    # https://docs.nvidia.com/cuda/eula/index.html
    # triton's license is MIT.
    # triton-bin includes ptxas binary, therefore unfreeRedistributable is set.
    license = with lib.licenses; [
      unfreeRedistributable
      mit
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      GaetanLepage
      junjihashimoto
    ];
  };
})
