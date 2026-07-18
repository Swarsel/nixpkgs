{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorcet,
  hatch-vcs,
  hatchling,
  hypothesis,
  multipledispatch,
  numba,
  numpy,
  packaging,
  pandas,
  param,
  pyct,
  pytest-xdist,
  pytestCheckHook,
  requests,
  scipy,
  toolz,
  writableTmpDirAsHomeHook,
  xarray,
}:

buildPythonPackage rec {
  pname = "datashader";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "holoviz";
    repo = "datashader";
    tag = "v${version}";
    hash = "sha256-jP6e7YmLyg3wd8QQZ4Vzr7vRFsRmttjIrEgIFqd6+hQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    writableTmpDirAsHomeHook
    hypothesis
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    colorcet
    multipledispatch
    numba
    numpy
    pandas
    param
    pyct
    requests
    scipy
    toolz
    packaging
    xarray
  ];

  disabledTestPaths = [
    "scripts/download_data.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "datashader" ];

  meta = {
    description = "Data visualization toolchain based on aggregating into a grid";
    homepage = "https://datashader.org";
    changelog = "https://github.com/holoviz/datashader/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      nickcao
      locnide
    ];

    mainProgram = "datashader";
  };
}
