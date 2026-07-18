{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "morfessor";
  version = "2.0.6";

  src = fetchPypi {
    inherit version;
    sha256 = "bb3beac234341724c5f640f65803071f62373a50dba854d5a398567f9aefbab2";
    pname = "Morfessor";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools_80 ];

  enabledTestPaths = [
    "morfessor/test/*"
  ];

  pyproject = true;
  pythonImportsCheck = [ "morfessor" ];

  meta = {
    description = "Tool for unsupervised and semi-supervised morphological segmentation";
    homepage = "https://github.com/aalto-speech/morfessor";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ misuzu ];
  };
}
