{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  ninja,
  numpy,
  pybind11,
  # tests
  pytestCheckHook,
  pythonOlder,
  pyyaml,
  scikit-build-core,
  setuptools-scm,
  # dependencies
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "spglib";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "spglib";
    repo = "spglib";
    tag = "v${version}";
    hash = "sha256-RFvd/j/14YRIcQTpnYPx5edeF3zbHbi90jb32i3ZU/c=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  build-system = [
    cmake
    scikit-build-core
    numpy
    pybind11
    ninja
    setuptools-scm
  ];

  dependencies = [
    numpy
  ]
  ++ lib.optionals (pythonOlder "3.13") [
    typing-extensions
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "spglib" ];

  meta = {
    description = "Python bindings for C library for finding and handling crystal symmetries";
    homepage = "https://spglib.github.io/spglib/";
    changelog = "https://github.com/spglib/spglib/raw/${src.tag}/ChangeLog";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ psyanticy ];
  };
}
