{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  extension-helpers,
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "gstools-cython";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "GeoStat-Framework";
    repo = "GSTools-Cython";
    tag = "v${version}";
    hash = "sha256-D5oOSOVfmwAOF7MYpMmOMXIS82NJeztRJh4sDXS+Ouc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [
    cython
    extension-helpers
    numpy
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "gstools_cython"
  ];

  meta = {
    description = "Cython backend for GSTools";
    homepage = "https://github.com/GeoStat-Framework/GSTools-Cython";
    changelog = "https://github.com/GeoStat-Framework/GSTools-Cython/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ sarahec ];
  };
}
