{
  lib,
  aioresponses,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  poetry-core,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-aioresponses";
  version = "0.3.0";

  # no tags on GitHub
  src = fetchPypi {
    inherit version;
    hash = "sha256-VnezLfoaNpCLNHUktYZ6qzWsHFzh1JcCRNb2YAm8p7Y=";
    pname = "pytest_aioresponses";
  };

  patches = [
    # https://github.com/pheanex/pytest-aioresponses/pull/5
    (fetchpatch {
      hash = "sha256-CejYyzAYwsueI0k9O4fcTGC0O8dz0vgE057IrvC5YRo=";
      name = "use-poetry-core.patch";
      url = "https://github.com/pheanex/pytest-aioresponses/commit/05595c1b73a9d9b01179bd434fb7cc57230c9251.patch";
    })
  ];

  buildInputs = [
    pytest
  ];

  # test_pytest_aioresponses.py isn't distributed on PyPI
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aioresponses
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_aioresponses" ];

  meta = {
    description = "Py.test integration for aioresponses";
    homepage = "https://github.com/pheanex/pytest-aioresponses";
    changelog = "https://github.com/pheanex/pytest-aioresponses/blob/main/Changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
