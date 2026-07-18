{
  lib,
  fetchFromGitHub,
  async-timeout,
  buildPythonPackage,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage {
  pname = "pescea";
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "lazdavila";
    repo = "pescea";
    # https://github.com/lazdavila/pescea/issues/4
    rev = "a3dd7deedc64205e24adbc4ff406a2f6aed3b240";
    hash = "sha256-5TkFrGaSkQOORhf5a7SjkzggFLPyqe9k3M0B4ljhWTQ=";
  };

  postPatch = ''
    # https://github.com/lazdavila/pescea/pull/1
    substituteInPlace setup.py \
      --replace '"asyncio",' ""
  '';

  propagatedBuildInputs = [ async-timeout ];

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  disabledTests = [
    # AssertionError: assert <State.BUSY: 'BusyWaiting'>...
    "test_updates_while_busy"
    # Test requires network access
    "test_flow_control"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pescea" ];

  meta = {
    description = "Python interface to Escea fireplaces";
    homepage = "https://github.com/lazdavila/pescea";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
}
