{
  lib,
  stdenv,
  fetchFromGitHub,
  biocframe,
  biocutils,
  buildPythonPackage,
  cmake,
  pandas,
  pkg-config,
  pybind11,
  pytest-cov-stub,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
  zlib,
}:

buildPythonPackage rec {
  pname = "rds2py";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "BiocPy";
    repo = "rds2py";
    tag = version;
    hash = "sha256-GbRpkt+K2HXuAT7KtI4h1SnZ4RtSo5hrea2L92VZj/o=";
  };

  # Patch upstream CMakeLists.txt files to use our vendored sources instead of
  # calling FetchContent. We point add_subdirectory() to the copies staged in
  # build/_deps above. We also patch rds2cpp's own extern/CMakeLists.txt to
  # disable its nested FetchContent call for byteme, since we already provide it.
  postPatch = ''
    substituteInPlace lib/CMakeLists.txt \
      --replace-fail \
        "FetchContent_MakeAvailable(byteme)" \
        "add_subdirectory(\''${CMAKE_BINARY_DIR}/../_deps/byteme-src \''${CMAKE_CURRENT_BINARY_DIR}/byteme)" \
      --replace-fail \
        "FetchContent_MakeAvailable(rds2cpp)" \
        "add_subdirectory(\''${CMAKE_BINARY_DIR}/../_deps/rds2cpp-src \''${CMAKE_CURRENT_BINARY_DIR}/rds2cpp)"

    substituteInPlace build/_deps/rds2cpp-src/extern/CMakeLists.txt \
      --replace-fail "FetchContent_MakeAvailable(byteme)" "# FetchContent_MakeAvailable(byteme) -- Patched by Nix"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    pybind11
    zlib
  ];

  # We use the MORE_CMAKE_OPTIONS environment variable, which is a hook provided
  # by the upstream setup.py, to pass our zlib flags to the CMake configure step.
  preConfigure = ''
    export MORE_CMAKE_OPTIONS="-DZLIB_INCLUDE_DIR=${lib.getDev zlib}/include -DZLIB_LIBRARY=${lib.getLib zlib}/lib/libz.so"
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    biocframe
    pandas
    scipy
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  byteme-src = fetchFromGitHub {
    hash = "sha256-rM/pSMGlaMWE69lYORaa8SQYGQyzhdyQnXImmAesxFA=";
    owner = "LTLA";
    repo = "byteme";
    rev = "v1.2.2";
  };

  dependencies = [
    biocutils
  ];

  disabledTestPaths = [
    # Requires packages not in Nixpkgs
    "tests/test_delayedmatrices.py"
    "tests/test_granges.py"
    "tests/test_mae.py"
    "tests/test_sce.py"
    "tests/test_se.py"
  ];

  # setuptools drives the build, so disable cmake configure hook
  dontUseCmakeConfigure = true;

  # Upstream uses CMake's FetchContent to download rds2cpp and byteme into
  # build/_deps at configure time. We pre-fetch both repos and copy them
  # into build/_deps manually. This way the build tree matches what upstream expects.
  prePatch = ''
    mkdir -p build/_deps
    cp -r ${rds2cpp-src} build/_deps/rds2cpp-src
    cp -r ${byteme-src} build/_deps/byteme-src
    chmod -R u+w build/_deps
  '';

  pyproject = true;
  pythonImportsCheck = [ "rds2py" ];

  rds2cpp-src = fetchFromGitHub {
    hash = "sha256-q7C/oORmhgXlqnZnslhyrxBc3RRF2gdgGuQU4TimxtI=";
    owner = "LTLA";
    repo = "rds2cpp";
    rev = "v1.1.0";
  };

  meta = {
    description = "Read RDS files, in Python";
    homepage = "https://github.com/BiocPy/rds2py";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ b-rodrigues ];
  };
}
