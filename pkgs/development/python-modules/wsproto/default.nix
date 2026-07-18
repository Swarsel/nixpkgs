{
  lib,
  buildPythonPackage,
  fetchPypi,
  h11,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "wsproto";
  version = "1.3.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uGiF3PKU4VIEkZlQ9mbgb/xsfBFMqQCwYNbhYpNSgpQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ h11 ];
  pyproject = true;
  pythonImportsCheck = [ "wsproto" ];

  meta = {
    description = "Pure Python, pure state-machine WebSocket implementation";
    homepage = "https://github.com/python-hyper/wsproto/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
