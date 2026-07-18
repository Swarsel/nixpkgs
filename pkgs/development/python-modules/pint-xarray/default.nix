{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pint,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  toolz,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "pint-xarray";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "xarray-contrib";
    repo = "pint-xarray";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t2I17dyl/XoO7NBvEyz7TRZkG/uQKPDHUUCG+bQXdOo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    pint
    toolz
    xarray
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pint_xarray"
  ];

  meta = {
    description = "Interface for using pint with xarray, providing convenience accessors";
    homepage = "https://github.com/xarray-contrib/pint-xarray";
    changelog = "https://github.com/xarray-contrib/pint-xarray/blob/${finalAttrs.src.tag}/docs/whats-new.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
