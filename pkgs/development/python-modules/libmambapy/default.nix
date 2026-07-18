{
  lib,
  buildPythonPackage,
  bzip2,
  cmake,
  curl,
  fmt,
  libmamba,
  libsolv,
  msgpack-c,
  ninja,
  nlohmann_json,
  pybind11,
  python,
  reproc,
  scikit-build-core,
  spdlog,
  tl-expected,
  yaml-cpp,
  zstd,
}:

buildPythonPackage rec {
  inherit (libmamba) version src;
  pname = "libmambapy";

  buildInputs = [
    (libmamba.override { python3 = python; })
    bzip2
    curl
    fmt
    libsolv
    msgpack-c
    nlohmann_json
    reproc
    spdlog
    tl-expected
    yaml-cpp
    zstd
  ];

  build-system = [
    cmake
    ninja
    pybind11
    scikit-build-core
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "libmambapy"
    "libmambapy.bindings"
  ];

  sourceRoot = "${src.name}/libmambapy";

  meta = {
    description = "Python library for the fast Cross-Platform Package Manager";
    homepage = "https://github.com/mamba-org/mamba";
    changelog = "https://github.com/mamba-org/mamba/blob/${src.tag}/libmambapy/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.ericthemagician ];
  };
}
