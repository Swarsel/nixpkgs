{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  dpkt,
  # tests
  mock,
  pytest-asyncio,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiortsp";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "marss";
    repo = "aiortsp";
    tag = "v${version}";
    hash = "sha256-/ydsu+53WOocdWk3AW0/cXBEx1qAlhIC0LUDy459pbQ=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ dpkt ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
    pytest-asyncio
  ];

  disabledTestPaths = [
    # these tests get stuck, could be pytest-asyncio compat issue
    "tests/test_connection.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiortsp" ];

  meta = {
    description = "Asyncio-based RTSP library";
    homepage = "https://github.com/marss/aiortsp";
    changelog = "https://github.com/marss/aiortsp/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
