{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  llvmPackages,
  python3,
  enablePython ? false,
}:

let
  pyEnv = python3.withPackages (
    p: with p; [
      numpy
      scipy
      distutils
    ]
  );

in
stdenv.mkDerivation (finalAttrs: {
  pname = "taco";
  version = "0-unstable-2025-04-14";

  src = fetchFromGitHub {
    owner = "tensor-compiler";
    repo = "taco";
    rev = "0e79acb56cb5f3d1785179536256e206790b2a9e";
    hash = "sha256-mdT6ZLxtJ7fqyjRqdWf6+RltvMy7YDr9AEnJtnaDmTw=";
    fetchSubmodules = true;
  };

  # Remove test cases from cmake build as they violate modern C++ expectations
  patches = [ ./taco.patch ];

  postPatch = ''
    rm -rf python_bindings/pybind11/*
    cp -r ${finalAttrs.src-new-pybind11}/* python_bindings/pybind11
    find python_bindings/pybind11 -exec chmod +w {} \;

    # CMake4 no longer support version < 3.5
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 3.4.0 FATAL_ERROR)" \
      "cmake_minimum_required(VERSION 3.5)"
    substituteInPlace apps/tensor_times_vector/CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 2.8.12)" \
      "cmake_minimum_required(VERSION 3.5)"

    # Newer pybind11 typing wrappers require a single concrete lambda return type.
    substituteInPlace python_bindings/src/pytaco.cpp --replace-fail \
      'm.def("get_parallel_schedule", [](){' \
      'm.def("get_parallel_schedule", []() -> py::tuple {'
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = lib.optional stdenv.hostPlatform.isDarwin llvmPackages.openmp;
  propagatedBuildInputs = lib.optional enablePython pyEnv;

  cmakeFlags = [
    "-DOPENMP=ON"
  ]
  ++ lib.optional enablePython "-DPYTHON=ON";

  # The standard CMake test suite fails a single test of the CLI interface.
  doCheck = false;

  postInstall = lib.strings.optionalString enablePython ''
    mkdir -p $out/${python3.sitePackages}
    cp -r lib/pytaco $out/${python3.sitePackages}/.
  '';

  # Cython somehow gets built with references to /build/.
  # However, the python module works flawlessly.
  dontFixup = enablePython;
  src-new-pybind11 = python3.pkgs.pybind11.src;

  meta = {
    description = "Computes sparse tensor expressions on CPUs and GPUs";
    homepage = "https://github.com/tensor-compiler/taco";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sheepforce ];
    mainProgram = "taco";
  };
})
