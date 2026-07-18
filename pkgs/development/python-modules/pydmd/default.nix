{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  ezyrb,
  future,
  h5netcdf,
  matplotlib,
  numpy,
  # tests
  pytest-mock,
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  setuptools-git-versioning,
  xarray,
}:

buildPythonPackage rec {
  pname = "pydmd";
  version = "2025.08.01";

  src = fetchFromGitHub {
    owner = "PyDMD";
    repo = "PyDMD";
    tag = version;
    hash = "sha256-u8dW90FZSZaVbPNeILeZyOwAU0WOAeTAMCHpe7n4Bi4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools-git-versioning>=2.0,<3" "setuptools-git-versioning"
  '';

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-git-versioning
  ];

  dependencies = [
    ezyrb
    future
    h5netcdf
    matplotlib
    numpy
    scipy
    xarray
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydmd" ];

  meta = {
    description = "Python Dynamic Mode Decomposition";
    homepage = "https://pydmd.github.io/PyDMD/";
    changelog = "https://github.com/PyDMD/PyDMD/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yl3dy ];
  };
}
