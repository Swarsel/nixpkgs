{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  # native dependencies
  libsoxr,
  nanobind,
  ninja,
  # dependencies
  numpy,
  # tests
  pytestCheckHook,
  scikit-build-core,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "soxr";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "dofuuz";
    repo = "python-soxr";
    tag = "v${version}";
    hash = "sha256-XdSInR0ogbcku6yvMkGEEIxu2nlqa0mffBtd+ifvzoU=";
  };

  patches = [ ./cmake-nanobind.patch ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [ libsoxr ];

  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_LIBSOXR" true)
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    scikit-build-core
    nanobind
    setuptools
    setuptools-scm
  ];

  dependencies = [ numpy ];
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "soxr" ];

  meta = {
    description = "High quality, one-dimensional sample-rate conversion library";
    homepage = "https://github.com/dofuuz/python-soxr/tree/main";
    changelog = "https://github.com/dofuuz/python-soxr/releases/tag/${src.tag}";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
