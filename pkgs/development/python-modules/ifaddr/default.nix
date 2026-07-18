{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "ifaddr";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zAy/yqv3ZdRFlYJfuWqZuxLHlxa3O0QzDqOO4rDErtQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "ifaddr" ];

  meta = {
    description = "Enumerates all IP addresses on all network adapters of the system";
    homepage = "https://github.com/pydron/ifaddr";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
