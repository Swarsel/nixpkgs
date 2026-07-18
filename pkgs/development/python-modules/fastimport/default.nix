{
  lib,
  buildPythonPackage,
  fetchPypi,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "fastimport";
  version = "0.9.16";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-agpvtWqjYH3nGtTnq9VRr+m9rJS6uNLddNjg+Y9S414=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "fastimport" ];

  meta = {
    description = "VCS fastimport/fastexport parser";
    homepage = "https://github.com/jelmer/python-fastimport";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ koral ];
  };
}
