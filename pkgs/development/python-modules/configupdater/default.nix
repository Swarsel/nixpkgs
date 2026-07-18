{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "configupdater";
  version = "3.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-n9rFODHBsGKSm/OYtkm4fKMOfxpzXz+/SCBygEEGMGs=";
    pname = "ConfigUpdater";
  };

  nativeBuildInputs = [ setuptools-scm ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  format = "setuptools";
  pythonImportsCheck = [ "configupdater" ];

  meta = {
    description = "Parser like ConfigParser but for updating configuration files";
    homepage = "https://configupdater.readthedocs.io/en/latest/";

    license = with lib.licenses; [
      mit
      psfl
    ];

    maintainers = with lib.maintainers; [ ris ];
  };
}
