{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "sgmllib3k";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eGj7HIv6dkwaxWPTzzacOB0TJdNhJJM6cm8p/NqoEuk=";
  };

  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  disabledTests = [ "test_declaration_junk_chars" ];
  format = "setuptools";
  pythonImportsCheck = [ "sgmllib" ];

  meta = {
    description = "Python 3 port of sgmllib";
    homepage = "https://pypi.org/project/sgmllib3k/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ lovesegfault ];
  };
}
