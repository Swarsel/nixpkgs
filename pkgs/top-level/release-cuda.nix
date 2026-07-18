/*
    Test CUDA packages.

    This release file is currently not tested on hydra.nixos.org
    because it requires unfree software.

    Test for example like this:

        $ hydra-eval-jobs pkgs/top-level/release-cuda.nix -I .
*/

let
  lib = import ../../lib;
  cudaLib = (import ../development/cuda-modules/_cuda).lib;
in

{
  # Attributes passed to nixpkgs.
  nixpkgsArgs ? {
    __allowFileset = false;

    config = {
      "${variant}Support" = true;
      # Don't evaluate duplicate and/or deprecated attributes
      allowAliases = false;
      # [CVE-2026-24188](https://github.com/NixOS/nixpkgs/issues/522570):
      # OOB write
      allowInsecurePredicate = p: lib.getName p == "tensorrt";
      allowUnfreePredicate = cudaLib.allowUnfreeCudaPredicate;
      inHydra = true;
    };
  },
  # The platforms for which we build Nixpkgs.
  supportedSystems ? [
    "x86_64-linux"
    "aarch64-linux"
  ],
  variant ? "cuda",
  ...
}@args:

assert builtins.elem variant [
  "cuda"
  "rocm"
  null
];

let
  mkReleaseLib = import ./release-lib.nix;
  release-lib = mkReleaseLib (
    { inherit supportedSystems nixpkgsArgs; } // lib.intersectAttrs (lib.functionArgs mkReleaseLib) args
  );

  inherit (release-lib)
    linux
    mapTestOn
    packagePlatforms
    pkgs
    ;

  # Package sets to evaluate whole
  # Derivations from these package sets are selected based on the value
  # of their meta.{hydraPlatforms,platforms,badPlatforms} attributes
  autoPackageSets = builtins.filter (lib.strings.hasPrefix "cudaPackages") (builtins.attrNames pkgs);
  autoPackagePlatforms = lib.genAttrs autoPackageSets (pset: packagePlatforms pkgs.${pset});

  # Explicitly select additional packages to also evaluate
  # The desired platforms must be set explicitly here
  explicitPackagePlatforms =
    # This comment prevents nixfmt from changing the indentation level, lol
    {
      blas = linux;
      blender = linux;
      cctag = linux; # Failed in https://github.com/NixOS/nixpkgs/pull/233581
      cholmod-extra = linux;
      colmap = linux;
      ctranslate2 = linux;
      faiss = linux;
      ffmpeg-full = linux;
      firefox = linux;
      firefox-beta = linux;
      firefox-beta-unwrapped = linux;
      firefox-devedition = linux;
      firefox-devedition-unwrapped = linux;
      firefox-unwrapped = linux;
      freecad = linux;
      gimp = linux;
      gpu-screen-recorder = linux;
      gst_all_1.gst-plugins-bad = linux;
      jellyfin-ffmpeg = linux;
      kdePackages.kdenlive = linux;
      krita = linux;
      lapack = linux;
      lightgbm = linux;
      llama-cpp = linux;
      magma = linux;
      meshlab = linux;
      mistral-rs = linux;
      monado = linux; # Failed in https://github.com/NixOS/nixpkgs/pull/233581
      mpich = linux;
      noisetorch = linux;
      obs-studio-plugins.obs-backgroundremoval = linux;
      octave = linux; # because depend on SuiteSparse which need rebuild when cuda enabled
      ollama = linux;
      onnxruntime = linux;
      opencv = linux;
      openmpi = linux;
      openmvg = linux;
      openmvs = linux;
      opentrack = linux;
      openvino = linux;
      pixinsight = linux; # Failed in https://github.com/NixOS/nixpkgs/pull/233581

      python3Packages = {
        catboost = linux;
        cupy = linux;
        faiss = linux;
        faster-whisper = linux;
        flashinfer = linux;
        flax = linux;
        gpt-2-simple = linux;
        grad-cam = linux;
        jax = linux;
        jaxlib = linux;
        keras = linux;
        kornia = linux;
        mmcv = linux;
        mxnet = linux;
        numpy = linux; # Only affected by MKL?
        onnx = linux;
        openai-whisper = linux;
        opencv4 = linux;
        opencv4Full = linux;
        opensfm = linux;
        pycuda = linux;
        pymc = linux;
        pyrealsense2WithCuda = linux;
        pytorch-lightning = linux;
        scikit-image = linux;
        scikit-learn = linux; # Only affected by MKL?
        scipy = linux; # Only affected by MKL?
        spacy-transformers = linux;
        tensorflow = linux;
        tensorflow-probability = linux;
        tesserocr = linux;
        tiny-cuda-nn = linux;
        torch = linux;
        torchaudio = linux;
        torchvision = linux;
        transformers = linux;
        triton = linux;
        ttstokenizer = linux;
        vidstab = linux;
        vllm = linux;
      };

      qgis = linux;
      rtabmap = linux;
      saga = linux;
      suitesparse = linux;
      sunshine = linux;
      thunderbird = linux;
      thunderbird-unwrapped = linux;
      truecrack-cuda = linux;
      tts = linux;
      ucx = linux;
      ueberzugpp = linux; # Failed in https://github.com/NixOS/nixpkgs/pull/233581
      wyoming-faster-whisper = linux;
      xgboost = linux;
    };

  # Explicitly specified platforms take precedence over the platforms
  # automatically inferred in autoPackagePlatforms
  allPackagePlatforms = lib.recursiveUpdate autoPackagePlatforms explicitPackagePlatforms;
  jobs = mapTestOn allPackagePlatforms;
in
jobs
