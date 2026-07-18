{
  lib,
  fetchFromGitHub,
  cctools,
  cmake,
  config,
  gitUpdater,
  llvmPackages,
  ninja,
  openssl,
  python3Packages,
  ragel,
  yasm,
  zlib,
  cudaPackages ? { },
  cudaSupport ? config.cudaSupport,
  pythonSupport ? false,
}:
let
  stdenv = if cudaSupport then cudaPackages.backendStdenv else llvmPackages.stdenv;
  buildPythonBindingsEnv = python3Packages.python.withPackages (
    ps: with ps; [
      cython
      numpy
    ]
  );
in

stdenv.mkDerivation (finalAttrs: {
  pname = "catboost";
  version = "1.2.10";

  src = fetchFromGitHub {
    owner = "catboost";
    repo = "catboost";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z68vflYgO3cWeOkb417Gyco1Fqb98ulyRgI+OS+B4is=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace cmake/common.cmake \
      --replace-fail  "\''${RAGEL_BIN}" "${ragel}/bin/ragel" \
      --replace-fail "\''${YASM_BIN}" "${yasm}/bin/yasm"

    shopt -s globstar
    for cmakelists in **/CMakeLists.*; do
      sed -i "s/openssl::openssl/OpenSSL::SSL/g" $cmakelists
    done
  '';

  nativeBuildInputs = [
    buildPythonBindingsEnv
    cmake
    llvmPackages.bintools
    ninja
    ragel
    yasm
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    openssl
    zlib
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_cudart
    cudaPackages.cccl
    cudaPackages.libcublas
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_BINARY_DIR" "$out")
    (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
    (lib.cmakeFeature "CATBOOST_COMPONENTS" "app;libs${lib.optionalString pythonSupport ";python-package"}")
    (lib.cmakeBool "HAVE_CUDA" cudaSupport)
  ]
  ++ lib.optional pythonSupport (
    lib.cmakeFeature "Python_EXECUTABLE" "${buildPythonBindingsEnv.interpreter}"
  );

  env = {
    # catboost requires clang 14+ for build, but does clang 12 for cuda build.
    # after bumping the default version of llvm, check for compatibility with the cuda backend and pin it.
    # see https://catboost.ai/en/docs/installation/build-environment-setup-for-cmake#compilers,-linkers-and-related-tools
    CUDAHOSTCXX = lib.optionalString cudaSupport "${stdenv.cc}/bin/cc";

    NIX_CFLAGS_COMPILE = toString (
      lib.optionals stdenv.cc.isClang [
        "-Wno-error=missing-template-arg-list-after-template-kw"
      ]
    );

    NIX_CFLAGS_LINK = lib.optionalString stdenv.hostPlatform.isLinux "-fuse-ld=lld";
    NIX_LDFLAGS = "-lc -lm";
    PROGRAM_VERSION = finalAttrs.version;
  };

  installPhase = ''
    runHook preInstall

    mkdir $dev
    cp -r catboost $dev
    install -Dm555 catboost/app/catboost -t $out/bin
    install -Dm444 catboost/libs/model_interface/static/lib/libmodel_interface-static-lib.a -t $out/lib
    install -Dm444 catboost/libs/model_interface/libcatboostmodel${stdenv.hostPlatform.extensions.sharedLibrary} -t $out/lib
    install -Dm444 catboost/libs/train_interface/libcatboost${stdenv.hostPlatform.extensions.sharedLibrary} -t $out/lib

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "High-performance library for gradient boosting on decision trees";

    longDescription = ''
      A fast, scalable, high performance Gradient Boosting on Decision Trees
      library, used for ranking, classification, regression and other machine
      learning tasks for Python, R, Java, C++. Supports computation on CPU and GPU.
    '';

    homepage = "https://catboost.ai";
    changelog = "https://github.com/catboost/catboost/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      PlushBeaver
      natsukium
    ];

    platforms = lib.platforms.unix;
    mainProgram = "catboost";

    broken =
      # See: <https://github.com/catboost/catboost/issues/2755>
      cudaSupport
      # /nix/store/hzxiynjmmj35fpy3jla7vcqwmzj9i449-Libsystem-1238.60.2/include/sys/_types/_mbstate_t.h:31:9: error: unknown type name '__darwin_mbstate_t'
      || (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64);
  };
})
