{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "statsd";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "jsocol";
    repo = "pystatsd";
    tag = "v${version}";
    hash = "sha256-g830TjFERKUguFKlZeaOhCTlaUs0wcDg4bMdRDr3smw=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  enabledTestPaths = [ "statsd/tests.py" ];
  pyproject = true;

  meta = {
    description = "Simple statsd client";
    homepage = "https://github.com/jsocol/pystatsd";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
