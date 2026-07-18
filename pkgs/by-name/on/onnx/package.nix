{
  lib,
  stdenv,
  fetchFromGitHub,
  # nativeBuildInputs
  cmake,
  # checkInputs
  gtest,
  ninja,
  # buildInputs
  protobuf,
  python3Packages,
}:
let
  inherit (lib)
    cmakeFeature
    licenses
    maintainers
    mapAttrsToList
    ;
  inherit (python3Packages)
    build
    pybind11
    python
    setuptools
    ;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "onnx";
  version = "1.21.0";

  src = fetchFromGitHub {
    owner = "onnx";
    repo = "onnx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eF6BdTwTuHh6ckuLGN1d6z2GLU47lPqtzu4zIv8+cTs=";
  };

  outputs = [
    "out"
    "dist" # Python wheel output
  ];

  strictDeps = true;

  nativeBuildInputs = [
    build
    cmake
    ninja
    pybind11
    python
    setuptools
  ];

  # NOTE: python3Packages.protobuf does not propagate a dependency on protobuf's dev output, so we must bring it in
  # for the CMake files.
  buildInputs = [
    protobuf
    python3Packages.protobuf
  ];

  cmakeFlags = mapAttrsToList cmakeFeature finalAttrs.env;

  # Python setup.py just takes stuff from the environment.
  env = {
    # NOTE: Darwin requires a static build; otherwise, tests fail in the Python package.
    BUILD_SHARED_LIBS = if stdenv.hostPlatform.isDarwin then "0" else "1";
    ONNX_BUILD_PYTHON = "1";
    ONNX_BUILD_TESTS = if finalAttrs.doCheck then "1" else "0";
    # ONNX_ML is enabled by default.
    # See: https://github.com/onnx/onnx/blob/b751946c3d59a3c8358abcc0569b59e6ddb08cdd/CMakeLists.txt#L66-L73
    ONNX_ML = "1";
    ONNX_NAMESPACE = "onnx";
    ONNX_USE_PROTOBUF_SHARED_LIBS = "1";
    nanobind_DIR = "${python3Packages.nanobind}/${python.sitePackages}/nanobind/cmake";
  };

  preConfigure = ''
    export MAX_JOBS=$NIX_BUILD_CORES
  '';

  # Leave the CMake bulid directory, export the `cmakeFlags` environment variable as CMAKE_ARGS so setup.py will pick
  # them up, do the python build from the top-level, then resume the C++ build.
  preBuild = ''
    pushd ..
    nixLog "exporting cmakeFlags as CMAKE_ARGS for Python build"
    export CMAKE_ARGS="''${cmakeFlags[*]}"
    nixLog "building Python wheel"
    pyproject-build \
      --no-isolation \
      --outdir "$dist/" \
      --wheel
    popd >/dev/null
  '';

  # NOTE: Python specific tests happen in the python package.
  doCheck = true;
  checkInputs = [ gtest ];

  preCheck = ''
    nixLog "running C++ tests with $PWD/onnx_gtests"
    "$PWD/onnx_gtests"
  '';

  postInstall = ''
    nixLog "removing empty directories in $out/include/onnx"
    find "$out/include/onnx" -type d -empty -delete
  '';

  __structuredAttrs = true;
  # Declared in setup.py
  cmakeBuildDir = ".setuptools-cmake-build";

  meta = {
    description = "Open Neural Network Exchange";
    homepage = "https://onnx.ai";
    changelog = "https://github.com/onnx/onnx/releases/tag/v${finalAttrs.version}";
    license = licenses.asl20;

    maintainers = with maintainers; [
      acairncross
      connorbaker
    ];
  };
})
