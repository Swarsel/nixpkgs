{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pandas,
  pytest-cov-stub,
  # test framework
  pytestCheckHook,
  # build-system
  setuptools-scm,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "pandas-flavor";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "pyjanitor-devs";
    repo = "pandas_flavor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c1pHH8vQOl1qicJJCVGuQoPbJp9uK03KDVr+rJWByhY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    pandas
    xarray
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pandas_flavor"
  ];

  meta = {
    description = "The easy way to write your own flavor of Pandas";
    homepage = "https://github.com/pyjanitor-devs/pandas_flavor";
    changelog = "https://github.com/pyjanitor-devs/pandas_flavor/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ grandjeanlab ];
  };
})
