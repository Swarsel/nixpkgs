{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pandas,
  pytest-asyncio,
  pytest-timeout,
  pytestCheckHook,
  rich,
  setuptools,
  setuptools-scm,
  tkinter,
  wheel,
}:

buildPythonPackage rec {
  pname = "tqdm";
  version = "4.67.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fYJfA/iSRO9z8dTOGTyxd0qBef2W8x1+Hc3mIJK5YLs=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  env.LC_ALL = "en_US.UTF-8";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-timeout
    # tests of optional features
    numpy
    rich
    tkinter
    pandas
  ];

  # Remove performance testing.
  # Too sensitive for on Hydra.
  disabledTests = [ "perf" ];
  pyproject = true;

  pytestFlags = [
    "-Wignore::FutureWarning"
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "tqdm" ];

  meta = {
    description = "Fast, Extensible Progress Meter";
    homepage = "https://github.com/tqdm/tqdm";
    changelog = "https://tqdm.github.io/releases/";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ miniharinn ];
    mainProgram = "tqdm";
  };
}
