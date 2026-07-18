{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipymarkup,
  navec,
  pymorphy2,
  pytestCheckHook,
  razdel,
  slovnet,
  yargy,
}:

buildPythonPackage rec {
  pname = "natasha";
  version = "1.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Rgguazgq06a8B9jeRnfHD5VTR+Xrd+8OCsQUfaGLEq0=";
  };

  propagatedBuildInputs = [
    pymorphy2
    navec
    razdel
    slovnet
    yargy
    ipymarkup
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  enabledTestPaths = [ "tests/" ];
  format = "setuptools";
  pythonImportsCheck = [ "natasha" ];

  meta = {
    description = "NLP framework for Russian language";
    homepage = "https://github.com/natasha/natasha";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ npatsakula ];
  };
}
