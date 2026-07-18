{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  networkx,
  numpy,
  pandas,
  # tests
  pytestCheckHook,
  scipp,
  # build-system
  setuptools,
  setuptools-scm,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "cyclebane";
  version = "24.10.0";

  src = fetchFromGitHub {
    owner = "scipp";
    repo = "cyclebane";
    tag = finalAttrs.version;
    hash = "sha256-vD/Ajym37GdsJ7iMuhao1SgX+Pd7aapc3b2oujwcopk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    numpy
    pandas
    scipp
    xarray
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    networkx
  ];

  pyproject = true;

  pythonImportsCheck = [
    "cyclebane"
  ];

  meta = {
    description = "Transform directed acyclic graphs using map-reduce and groupby operations";
    homepage = "https://scipp.github.io/cyclebane/";
    changelog = "https://github.com/scipp/cyclebane/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
