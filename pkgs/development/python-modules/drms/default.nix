{
  lib,
  fetchFromGitHub,
  astropy,
  buildPythonPackage,
  # dependencies
  numpy,
  packaging,
  pandas,
  pytest-doctestplus,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "drms";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "sunpy";
    repo = "drms";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f5t59a24aD8iXa3/zikgBnJeuUnZ4cvvpJuOfc80Xcw=";
  };

  nativeCheckInputs = [
    astropy
    pytestCheckHook
    pytest-doctestplus
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    pandas
    packaging
  ];

  disabledTestPaths = [ "docs/tutorial.rst" ];

  disabledTests = [
    "test_query_hexadecimal_strings"
    "test_jsocinfoconstants" # Need network
  ];

  pyproject = true;
  pythonImportsCheck = [ "drms" ];

  meta = {
    description = "Access HMI, AIA and MDI data with Python";
    homepage = "https://github.com/sunpy/drms";
    changelog = "https://github.com/sunpy/drms/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
  };
})
