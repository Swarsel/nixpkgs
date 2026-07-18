{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  # dependencies
  eigen,
  jax,
  jaxlib,
  nanobind,
  ninja,
  numpy,
  pathspec,
  # tests
  pytestCheckHook,
  scikit-build-core,
  scipy,
  tensorflow-bin,
  torch,
}:
buildPythonPackage (finalAttrs: {
  pname = "nanobind";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "wjakob";
    repo = "nanobind";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s9TshE3V50BtrnVv56j4BxZOloNsOVgi0PUT6xyF7yY=";
    fetchSubmodules = true;
  };

  # nanobind check requires heavy dependencies such as tensorflow
  # which are less than ideal to be imported in children packages that
  # use it as build-system parameter.
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    numpy
    scipy
    torch
  ]
  ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform tensorflow-bin) [
    tensorflow-bin
    jax
    jaxlib
  ];

  preCheck = ''
    # build tests
    make -j $NIX_BUILD_CORES
  '';

  build-system = [
    cmake
    ninja
    pathspec
    scikit-build-core
  ];

  dependencies = [ eigen ];
  dontUseCmakeBuildDir = true;
  pyproject = true;

  passthru.tests = {
    pytest = nanobind.overridePythonAttrs { doCheck = true; };
  };

  meta = {
    description = "Tiny and efficient C++/Python bindings";

    longDescription = ''
      nanobind is a small binding library that exposes C++ types in Python and
      vice versa. It is reminiscent of Boost.Python and pybind11 and uses
      near-identical syntax. In contrast to these existing tools, nanobind is
      more efficient: bindings compile in a shorter amount of time, produce
      smaller binaries, and have better runtime performance.
    '';

    homepage = "https://github.com/wjakob/nanobind";
    changelog = "https://github.com/wjakob/nanobind/blob/${finalAttrs.src.tag}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ parras ];
  };
})
