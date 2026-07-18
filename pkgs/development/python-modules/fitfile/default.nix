{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fitfile";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "tcgoetz";
    repo = "fit";
    tag = version;
    hash = "sha256-NIshX/IkPmqviYRPT4wRF7evZwn9e7BdCI5x+2Pz7II=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "fitfile" ];

  meta = {
    description = "Python Fit file parser";
    homepage = "https://github.com/tcgoetz/fit";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
