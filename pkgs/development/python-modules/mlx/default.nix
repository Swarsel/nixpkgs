{
  lib,
  stdenv,
  fetchFromGitHub,
  # buildInputs
  apple-sdk,
  buildPythonPackage,
  # build-system
  cmake,
  fmt,
  # passthru
  mlx,
  nanobind,
  nlohmann_json,
  # tests
  numpy,
  # linux-only
  openblas,
  psutil,
  pytestCheckHook,
  python,
  replaceVars,
  runCommand,
  setuptools,
  typing-extensions,
}:

let
  # static dependencies included directly during compilation
  gguf-tools = fetchFromGitHub {
    hash = "sha256-15FvyPOFqTOr5vdWQoPnZz+mYH919++EtghjozDlnSA=";
    owner = "antirez";
    repo = "gguf-tools";
    # Tag from https://github.com/ml-explore/mlx/blob/v0.31.1/mlx/io/CMakeLists.txt#L14
    rev = "8fa6eb65236618e28fd7710a0fba565f7faa1848";
  };

in
buildPythonPackage (finalAttrs: {
  pname = "mlx";
  version = "0.31.2";

  src = fetchFromGitHub {
    owner = "ml-explore";
    repo = "mlx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0Oxacz61WGWZrpWw+fMQjEQfwOx1l1L2d0kWl54/LrQ=";
  };

  patches = [
    # Use nix packages instead of fetching their sources
    ./dont-fetch-nanobind.patch
    ./dont-fetch-json.patch
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (replaceVars ./darwin-build-fixes.patch {
      sdkVersion = apple-sdk.version;
    })
  ];

  postPatch = ''
    substituteInPlace mlx/backend/cpu/jit_compiler.cpp \
      --replace-fail "g++" "${lib.getExe' stdenv.cc "c++"}"
  '';

  buildInputs = [
    fmt
    nlohmann_json
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    openblas
  ];

  env = {
    CMAKE_ARGS = toString (
      [
        # NOTE The `metal` command-line utility used to build the Metal kernels is not open-source.
        # To build mlx with Metal support in Nix, you'd need to use one of the sandbox escape
        # hatches which let you interact with a native install of Xcode, such as `composeXcodeWrapper`
        # or by changing the upstream (e.g., https://github.com/zed-industries/zed/discussions/7016).
        (lib.cmakeBool "MLX_BUILD_METAL" false)
        (lib.cmakeBool "USE_SYSTEM_FMT" true)
        (lib.cmakeOptionType "filepath" "FETCHCONTENT_SOURCE_DIR_GGUFLIB" "${gguf-tools}")
        (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-I${lib.getDev nlohmann_json}/include/nlohmann")

        # Cmake cannot find nanobind-config.cmake by itself
        (lib.cmakeFeature "nanobind_DIR" "${nanobind}/${python.sitePackages}/nanobind/cmake")
      ]
      ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
        (lib.cmakeBool "MLX_ENABLE_X64_MAC" true)
      ]
    );

    PYPI_RELEASE = 1;
  };

  # Run the mlx Python test suite.
  nativeCheckInputs = [
    numpy
    psutil
    pytestCheckHook
  ];

  # patchelf is only available on Linux and no patching is needed on darwin.
  # Otherwise mlx/core.cpython-313-x86_64-linux-gnu.so contains a reference to
  # /build/source/build/temp.linux-x86_64-cpython-313/mlx.core/libmlx.so in its rpath.
  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --replace-needed \
      libmlx.so \
      $out/${python.sitePackages}/mlx/lib64/libmlx.so \
      $out/${python.sitePackages}/mlx/core.cpython-*.so
  '';

  __structuredAttrs = true;

  build-system = [
    cmake
    setuptools
    typing-extensions
  ];

  disabledTestPaths = lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64) [
    # Segmentation fault
    "python/tests/test_linalg.py"
  ];

  disabledTests = [
    # brittle memory leak test, see: https://github.com/ml-explore/mlx/pull/3088
    "test_siblings_without_eval"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64) [
    # Segmentation fault
    "test_lapack"
    "test_multivariate_normal"
    "test_orthogonal"
    "test_vmap_inverse"
    "test_vmap_svd"
  ];

  dontUseCmakeConfigure = true;
  enableParallelBuilding = true;

  enabledTestPaths = [
    "python/tests/"
  ];

  # Allows multiple cores to be used in Python builds.
  postUnpack = ''
    export MAKEFLAGS+="''${enableParallelBuilding:+-j$NIX_BUILD_CORES}"
  '';

  pyproject = true;
  pythonImportsCheck = [ "mlx" ];
  # updates the wrong fetcher rev attribute
  passthru.skipBulkUpdate = true;

  # Additional testing by executing the example Python scripts supplied with mlx
  # using the version of the library we've built.
  passthru.tests = {
    mlxTest =
      runCommand "run-mlx-examples"
        {
          nativeBuildInputs = [ python ];
          buildInputs = [ mlx ];
        }
        ''
          cp ${finalAttrs.src}/examples/python/logistic_regression.py .
          ${python.interpreter} logistic_regression.py
          rm logistic_regression.py

          cp ${finalAttrs.src}/examples/python/linear_regression.py .
          ${python.interpreter} linear_regression.py
          rm linear_regression.py

          touch $out
        '';
  };

  meta = {
    description = "Array framework for Apple silicon";
    homepage = "https://github.com/ml-explore/mlx";
    changelog = "https://github.com/ml-explore/mlx/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      booxter
      cameronyule
      viraptor
    ];
  };
})
