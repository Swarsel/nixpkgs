{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cgen,
  codepy,
  colorama,
  constantdict,
  fparser,
  genpy,
  # build-system
  hatchling,
  islpy,
  mako,
  numpy,
  ply,
  pymbolic,
  # optional-dependencies
  pyopencl,
  # dependencies
  pytools,
  typing-extensions,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "loopy";
  version = "2025.2";

  src = fetchFromGitHub {
    owner = "inducer";
    repo = "loopy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VgsUOMCIg61mYNDMcGpMs5I1CkobhUFVjoQFdD8Vchs=";
    fetchSubmodules = true; # submodule at `loopy/target/c/compyte`
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  # pyopencl._cl.LogicError: clGetPlatformIDs failed: PLATFORM_NOT_FOUND_KHR
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    pytools
    pymbolic
    genpy
    numpy
    cgen
    islpy
    codepy
    colorama
    mako
    constantdict
    typing-extensions
  ];

  optional-dependencies = {
    fortran = [
      fparser
      ply
    ];

    pyopencl = [
      pyopencl
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "loopy" ];

  meta = {
    description = "Code generator for array-based code on CPUs and GPUs";
    homepage = "https://github.com/inducer/loopy";
    changelog = "https://github.com/inducer/loopy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
