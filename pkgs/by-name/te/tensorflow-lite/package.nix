{
  lib,
  stdenv,
  fetchFromGitHub,
  buildBazelPackage,
  buildPackages,
}:
let
  buildPlatform = stdenv.buildPlatform;
  hostPlatform = stdenv.hostPlatform;
  pythonEnv = buildPackages.python3.withPackages (
    ps: with ps; [
      distutils
      numpy
    ]
  );
  bazelDepsSha256ByBuildAndHost = {
    aarch64-linux = {
      aarch64-linux = "sha256-MJU4y9Dt9xJWKgw7iKW+9Ur856rMIHeFD5u05s+Q7rQ=";
    };

    x86_64-linux = {
      aarch64-linux = "sha256-sOIYpp98wJRz3RGvPasyNEJ05W29913Lsm+oi/aq/Ag=";
      x86_64-linux = "sha256-61qmnAB80syYhURWYJOiOnoGOtNa1pPkxfznrFScPAo=";
    };
  };
  bazelHostConfigName.aarch64-linux = "elinux_aarch64";
  bazelDepsSha256ByHost =
    bazelDepsSha256ByBuildAndHost.${buildPlatform.system}
      or (throw "unsupported build system ${buildPlatform.system}");
  bazelDepsSha256 =
    bazelDepsSha256ByHost.${hostPlatform.system}
      or (throw "unsupported host system ${hostPlatform.system} with build system ${buildPlatform.system}");
in
buildBazelPackage rec {
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "tensorflow";
    repo = "tensorflow";
    rev = "v${version}";
    hash = "sha256-Rq5pAVmxlWBVnph20fkAwbfy+iuBNlfFy14poDPd5h0=";
  };

  postPatch = ''
    rm .bazelversion

    # Fix gcc-13 build failure by including missing include headers
    sed -e '1i #include <cstdint>' -i \
      tensorflow/lite/kernels/internal/spectrogram.cc
  '';

  nativeBuildInputs = [
    pythonEnv
    buildPackages.perl
  ];

  env.PYTHON_BIN_PATH = pythonEnv.interpreter;

  preConfigure = ''
    patchShebangs configure
  '';

  #bazel = buildPackages.bazel_5;
  bazel = buildPackages.bazel;
  bazelBuildFlags = [ "--cxxopt=--std=c++17" ];

  bazelFlags = [
    "--config=opt"
  ]
  ++ lib.optionals (hostPlatform.system != buildPlatform.system) [
    "--config=${bazelHostConfigName.${hostPlatform.system}}"
  ];

  bazelTargets = [
    "//tensorflow/lite:libtensorflowlite.so"
    "//tensorflow/lite/c:tensorflowlite_c"
    "//tensorflow/lite/tools/benchmark:benchmark_model"
    "//tensorflow/lite/tools/benchmark:benchmark_model_performance_options"
  ];

  buildAttrs = {
    installPhase = ''
      mkdir -p $out/{bin,lib}

      # copy the libs and binaries into the output dir
      cp ./bazel-bin/tensorflow/lite/c/libtensorflowlite_c.so $out/lib
      cp ./bazel-bin/tensorflow/lite/libtensorflowlite.so $out/lib
      cp ./bazel-bin/tensorflow/lite/tools/benchmark/benchmark_model $out/bin
      cp ./bazel-bin/tensorflow/lite/tools/benchmark/benchmark_model_performance_options $out/bin

      find . -type f -name '*.h' | while read f; do
        path="$out/include/''${f/.\//}"
        install -D "$f" "$path"

        # remove executable bit from headers
        chmod -x "$path"
      done
    '';
  };

  configurePlatforms = [ ];
  dontAddBazelOpts = true;
  # configure script freaks out when parameters are passed
  dontAddPrefix = true;
  fetchAttrs.sha256 = bazelDepsSha256;
  name = "tensorflow-lite";
  removeRulesCC = false;

  meta = {
    description = "Open source deep learning framework for on-device inference";
    homepage = "https://www.tensorflow.org/lite";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      mschwaig
      cpcloud
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    # Bazel 5 was removed.
    broken = true;
  };
}
