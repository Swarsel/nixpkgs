{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ipy";
  version = "1.01";

  src = fetchPypi {
    inherit version;
    hash = "sha256-7eynQd6i1UrKVo+iN0AojD/obA8+pwA0RXHp7xSnzBo=";
    pname = "IPy";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "IPy" ];

  meta = {
    description = "Class and tools for handling of IPv4 and IPv6 addresses and networks";
    homepage = "https://github.com/autocracy/python-ipy";
    license = lib.licenses.bsdOriginal;
  };
}
