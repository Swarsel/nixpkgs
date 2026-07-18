{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  nose2,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "setuptools-dso";
  version = "2.12.3";

  src = fetchFromGitHub {
    owner = "epics-base";
    repo = "setuptools_dso";
    tag = version;
    hash = "sha256-M2Gca1QA9fuSvnzKLqY/RaN+NBRAiThl0tkdMbrhGVo=";
  };

  nativeCheckInputs = [
    nose2
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # distutils.compilers.C.errors.CompileError: command '/nix/store/...-clang-wrapper-21.1.2/bin/clang' failed with exit code 1
    # fatal error: 'string' file not found
    "test_cxx"
  ];

  pyproject = true;

  meta = {
    description = "Setuptools extension for building non-Python Dynamic Shared Objects";
    homepage = "https://github.com/mdavidsaver/setuptools_dso";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
}
